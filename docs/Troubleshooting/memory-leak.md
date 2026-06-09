# Troubleshooting #14 — Memory Leak

## What is a memory leak?

A memory leak happens when a process **allocates memory but never frees it** after it's done.

Analogy: a worker takes paper from the printer for tasks but never puts it back. Over time the desk fills up with paper no one needs, and others can't use the printer.

**Key characteristic:** memory grows **over time** — not a sudden spike, a slow continuous increase until RAM runs out.

---

## Detect a memory leak

### Step 1 — Watch memory usage over time

```bash
watch 'ps aux --sort=-%mem | head'
```

Breaking it down:
- `watch` — refreshes the command every 2 seconds (default)
- `ps aux` — list all processes
- `--sort=-%mem` — sort by memory usage, highest first
- `head` — show only top 10 lines

If a process's `%MEM` or `RSS` column keeps growing → memory leak.

```bash
watch -n 5 'ps aux --sort=-%mem | head'   # refresh every 5 seconds
```

### Step 2 — Inspect process memory map

```bash
pmap -x <PID>                          # memory map — regions, libraries, sizes
cat /proc/<PID>/smaps | grep -i heap   # look at heap size specifically
```

**Heap** = dynamic memory area where programs allocate data at runtime.
With a memory leak, the heap grows continuously.

### Step 3 — Track over time

```bash
# Check RSS (Resident Set Size) of a specific PID every 5 seconds
watch -n 5 'cat /proc/<PID>/status | grep VmRSS'
```

`VmRSS` = actual physical RAM used by the process right now.
If this number keeps climbing → memory leak confirmed.

---

## What to do when you find a memory leak

1. **Restart the process** — quick fix, buys time
2. **Report to developers** — memory leak is a code bug, needs a fix
3. **Add MemoryMax in systemd** — cap memory so OOM killer kills only this service

```ini
[Service]
MemoryMax=512M    # process gets killed if it exceeds this
```

On production: combine restart + MemoryMax as temporary mitigation while waiting for a fix.

---

## memory leak vs OOM

| | Memory Leak | OOM |
|---|---|---|
| What happens | Process slowly eats RAM | System runs out of RAM |
| Symptom | Process RSS grows over time | Processes randomly die |
| Where to look | `watch ps`, `pmap`, `/proc/smaps` | `dmesg`, `journalctl -k` |
| Fix | Restart process, fix code | Add swap, MemoryMax |

Memory leak often **causes** OOM — if left unchecked, the leaking process eventually triggers OOM killer.

---

## Full troubleshooting flow

```
Service keeps crashing / system getting slower over time
    ↓
watch 'ps aux --sort=-%mem | head'    → any process growing?
    ↓ yes
pmap -x <PID>                         → memory map overview
cat /proc/<PID>/smaps | grep heap     → heap growing?
watch -n 5 'cat /proc/<PID>/status | grep VmRSS'  → confirm growth over time
    ↓ confirmed leak
systemctl restart <service>           → temporary fix
Add MemoryMax to unit file            → prevent OOM while waiting for code fix
```

---

## Quick reference

```bash
watch 'ps aux --sort=-%mem | head'          # monitor memory over time
pmap -x <PID>                               # memory map of process
cat /proc/<PID>/smaps | grep -i heap        # heap size
watch -n 5 'cat /proc/<PID>/status | grep VmRSS'  # track RSS over time
```
