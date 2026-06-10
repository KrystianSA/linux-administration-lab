# Troubleshooting #24 — Application Slow but CPU/RAM OK

## Why this is tricky

All obvious metrics look fine:
- CPU: low
- RAM: plenty free
- Disk: low iowait

But the application is slow. The bottleneck is **external dependencies** or **hidden waits**.

---

## USE Method — systematic approach

For every resource (CPU, RAM, disk, network) check three things:

| Check | Question | Tools |
|---|---|---|
| **Utilization** | How much of the resource is used? | top, free, iostat, iftop |
| **Saturation** | Is there a queue waiting? | vmstat r/b, load average, iostat await |
| **Errors** | Are there errors? | dmesg, journalctl, ip -s link |

Apply to every resource systematically instead of guessing:

```
CPU:    top %cpu (U), vmstat r column (S), dmesg (E)
RAM:    free -h (U), vmstat si/so swap (S), dmesg OOM (E)
Disk:   iostat %util (U), iostat await (S), dmesg I/O errors (E)
Network: iftop (U), ss -s (S), ip -s link errors (E)
```

---

## Common hidden bottlenecks

### 1. DNS latency

Every connection to `db.company.internal` starts with a DNS lookup.
If DNS is slow (100ms+) and app makes 100 queries/second → app is 100ms slower per query.

```bash
dig google.com +stats | grep "Query time"   # first query (no cache)
dig google.com +stats | grep "Query time"   # second query (from cache, should be ~0ms)
```

High first query time → DNS server slow or unreachable.

### 2. Slow database / backend connections

```bash
ss -tp                          # show TCP connections with process names
ss -tp | grep ESTABLISHED       # active connections
ss -tp | grep TIME_WAIT         # connections waiting to close (too many = problem)
```

High `TIME_WAIT` count = many connections being opened/closed rapidly → connection pooling needed.

### 3. Application waiting on I/O

```bash
strace -c -p <PID>              # summary of syscalls — time and call count
```

Look for:
- High `% time` on `read/write` → disk or network I/O slow
- High `usecs/call` on `connect` → slow connections to backend
- Many `poll/select` calls → app waiting for something

### 4. Network latency to backend

```bash
ping -c10 <backend_ip>          # check latency and packet loss
traceroute <backend_ip>         # find where latency is introduced
mtr <backend_ip>                # real-time traceroute
```

---

## Step-by-step flow

```bash
# Step 1 — Confirm CPU/RAM/Disk are OK
top                             # CPU and memory
iostat -x 1                     # disk utilization
vmstat 1                        # overall system

# Step 2 — Check network connections
ss -tp | grep <process>         # what connections does the app have open?

# Step 3 — DNS latency
dig <backend_hostname> +stats   # how long does DNS take?

# Step 4 — Trace the process
strace -c -p <PID>              # what syscalls take most time?

# Step 5 — Check backend latency
ping <db_ip>
ping <cache_ip>
```

---

## iostat vs vmstat — quick reminder

| | vmstat | iostat |
|---|---|---|
| Scope | Whole system | Disks only |
| Shows | CPU + RAM + swap + I/O + context switches | Per-device stats |
| Use for | "What's happening to the system?" | "Which disk is overloaded?" |
| Key columns | `r`=CPU queue, `b`=IO queue, `wa`=iowait | `%util`, `await`, `tps`, `kB_read/s` |

Use together: `vmstat` shows high `wa` → `iostat` tells you which disk.

---

## Quick reference

```bash
top / vmstat / iostat           # USE method — check all resources
dig <host> +stats               # DNS latency check
ss -tp                          # TCP connections with process names
strace -c -p <PID>              # syscall time breakdown
ping / traceroute / mtr         # network latency to backend
```
