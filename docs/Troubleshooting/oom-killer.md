# Troubleshooting #12 — OOM Killer Killing Processes

## What is OOM Killer?

OOM = Out Of Memory. When system runs out of RAM and swap, the kernel activates the **OOM Killer** — it kills processes to free memory and prevent total system freeze.

Analogy: a sinking ship throwing cargo overboard to stay afloat.

---

## How OOM Killer decides what to kill

Every process has an `oom_score` (0-1000). Higher score = more likely to be killed.

Score is higher for processes that:
- Use a lot of memory
- Are recently started
- Are not critical to the system

```bash
cat /proc/1/oom_score        # systemd = 0, never killed
cat /proc/$$/oom_score       # your shell = high, candidate for killing
cat /proc/<PID>/oom_score    # check any process
```

`$$` = PID of current shell (shortcut, no need to type the number manually).

---

## Detect OOM killer activity

```bash
dmesg | grep -i oom
journalctl -k | grep -i oom    # -k = kernel messages, full history
```

Example output when OOM killer fired:
```
Out of memory: Killed process 1234 (java) total-vm:2048000kB, anon-rss:1500000kB
```

Shows: which process, how much memory it used, when it was killed.

---

## Prevent OOM killer from firing

### 1. Add swap

Swap acts as a buffer — before OOM killer starts killing, system can offload unused pages to disk.

```bash
# Create a 2GB swap file
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

Add to `/etc/fstab` to persist after reboot:
```
/swapfile none swap sw 0 0
```

### 2. MemoryMax in systemd (per-service limit)

Limits memory for a specific service. If it exceeds the limit, only that service is killed — rest of system is safe.

```ini
[Service]
MemoryMax=512M
```

Apply:
```bash
sudo systemctl edit <service>    # add MemoryMax
sudo systemctl daemon-reload
sudo systemctl restart <service>
```

### 3. vm.overcommit (kernel memory policy)

By default, kernel "promises" more memory than it has (overcommit), assuming not all processes will use their allocation at once — like a bank giving out more loans than it has in reserve.

```bash
# Check current setting
sysctl vm.overcommit_memory

# 0 = default (heuristic overcommit)
# 1 = always overcommit (risky)
# 2 = never overcommit beyond physical RAM + swap
sysctl vm.overcommit_memory=2
```

To persist after reboot:
```bash
echo "vm.overcommit_memory=2" >> /etc/sysctl.conf
sysctl -p
```

---

## Full troubleshooting flow

```
Processes mysteriously dying / service keeps restarting
    ↓
dmesg | grep -i oom             → OOM killer fired?
journalctl -k | grep -i oom     → full kernel log history
    ↓ confirmed OOM
free -h                         → how much RAM/swap available?
cat /proc/<PID>/oom_score       → which processes are at risk?
    ↓ prevention
Add swap                        → buffer before OOM kicks in
MemoryMax in systemd            → cap per-service memory
vm.overcommit_memory=2          → stop over-promising memory
```

---

## Quick reference

```bash
dmesg | grep -i oom                    # check if OOM fired
journalctl -k | grep -i oom           # kernel log history
cat /proc/<PID>/oom_score             # process kill score (0-1000)
free -h                                # RAM + swap status (look at 'available'!)
sysctl vm.overcommit_memory           # current overcommit policy
```
