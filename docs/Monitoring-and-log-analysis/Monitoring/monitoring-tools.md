# Monitoring Tools

## Quick reference — when to use what

| Tool | Use when | Shows |
|---|---|---|
| `top` / `htop` | First step, real-time overview | CPU, processes, memory |
| `free -h` | Quick memory check | RAM, swap, cache |
| `ps aux` | List all processes | Snapshot of all processes |
| `vmstat 1` | General diagnosis | CPU + memory + swap + I/O + context switches |
| `iostat` | Disk performance | Per-device read/write stats |
| `iotop` | Find which process eats disk | Process-level I/O |
| `sar` | Historical data, post-mortem | Everything, saved to disk |

---

## top

```bash
top
htop    # same but prettier, install with: sudo apt install htop
```

### Header lines explained

```
load average: 0.01, 0.02, 0.00     # queue of processes waiting for CPU (1m, 5m, 15m)
                                    # load / number of cores = % utilization
                                    # load 4.0 on 2 cores = 200% = overloaded

Tasks: 125 total, 1 running, 124 sleeping, 0 zombie
                                    # zombie = finished but parent didn't clean up
                                    # fix: restart the parent process

%Cpu(s): 0.7 us, 0.9 sy, 98.3 id, 0.2 wa
  us = user processes
  sy = kernel/system
  id = idle
  wa = waiting for I/O (high wa = disk bottleneck, not CPU problem!)

MiB Mem: total / free / used / buff/cache
MiB Swap: si (swap in) / so (swap out)
  # high si/so = thrashing = server running out of RAM
```

### Process columns

| Column | Meaning |
|---|---|
| `PID` | Process ID |
| `PR` | Priority (kernel-calculated) |
| `NI` | Nice value (you set this: -20 highest, +19 lowest) |
| `VIRT` | Virtual memory reserved by process |
| `RES` | Resident memory actually used |
| `%CPU` | Current CPU usage |
| `%MEM` | Current memory usage |
| `TIME+` | Total CPU time consumed since start |
| `S` | Status: R=running, S=sleeping, D=uninterruptible, Z=zombie, I=idle kernel thread |

### Process states

- `R` Running — actively using CPU
- `S` Sleeping — waiting, can be interrupted
- `D` Uninterruptible sleep — waiting for I/O, **kill -9 won't work**
- `Z` Zombie — finished but parent hasn't cleaned up
- `I` Idle kernel thread — normal, ignore

### Change process priority

```bash
renice +10 -p <PID>    # lower priority
renice -5 -p <PID>     # higher priority (requires sudo)
```

---

## free -h

```bash
free -h
```

```
               total    used    free    buff/cache    available
Mem:           3.3Gi   651Mi   1.8Gi        1.0Gi       2.7Gi
```

**Always look at `available`, not `free`:**
- `free` — literally empty
- `available` = free + reclaimable buff/cache (kernel gives this back when needed)

---

## vmstat

```bash
vmstat 1 5    # 5 readings, 1 second apart
```

**Always ignore the first line** — it's cumulative data since boot, not per-second.

### Key columns

```
procs:  r = processes waiting for CPU (= load average)
        b = processes in D state (stuck on I/O)

swap:   si = swap in (disk → RAM)
        so = swap out (RAM → disk)
        # high si/so = thrashing!

io:     bi = blocks read from disk
        bo = blocks written to disk
        # first line is cumulative (high), rest are per-second

system: in = interrupts per second (hardware signals to CPU)
        cs = context switches per second
        # very high cs = CPU wasting time switching between processes

cpu:    us sy id wa — same as top
```

---

## iostat

```bash
iostat          # snapshot
iostat 1 5      # 5 readings, 1 second apart
iostat -x       # extended stats (utilization %)
```

Shows per-device disk statistics. Useful when `wa` is high in `top`.

```
Device   tps    kB_read/s    kB_wrtn/s
dm-0    30.49    1187.23      286.50     ← LVM device (device mapper)
sdc     22.17    1243.82      286.67     ← physical disk
```

- `tps` — transactions per second
- `kB_read/s` / `kB_wrtn/s` — throughput
- `%iowait` in avg-cpu section — CPU waiting for disk (same as `wa` in top)

High `kB_read/s` + high `%iowait` = disk is a bottleneck.

---

## iotop

```bash
sudo apt install iotop
sudo iotop          # real-time, shows which process reads/writes
sudo iotop -o       # only show processes actively doing I/O
```

Use `iostat` to find the busy disk, then `iotop` to find which process is causing it.

---

## sar — historical data

```bash
sudo apt install sysstat    # install if missing
```

```bash
sar -u 1 5                              # CPU, 5 readings
sar -r 1 5                              # memory
sar -b 1 5                              # I/O
sar -u -f /var/log/sysstat/sa$(date +%d) # today's history
sar -u -f /var/log/sysstat/sa01          # history from 1st of month
```

### Why sar matters

`top`, `vmstat`, `iostat` show the present — data is gone when you close the terminal.
`sar` saves data every few minutes to disk. You can look back at what happened at 3:00 AM.

> "When I get an alert that the server was slow overnight, I check `sar` to see CPU, memory, and I/O metrics at that exact time — without `sar` there's no way to reconstruct what happened."

### sar vs journalctl

| | sar | journalctl |
|---|---|---|
| Shows | Metrics (CPU %, RAM %, iowait) | Events (service crashed, SSH login) |
| Analogy | Lab test results (blood pressure 180/110) | Doctor's notes (patient complained of pain) |
| Use for | **When** was the problem and how bad | **What** happened at that time |

Use both together for complete post-mortem analysis.

---

## Troubleshooting flow for high CPU

```
top → find process with high %CPU or TIME+
    ↓ high wa (iowait)?
iostat → which disk is busy?
iotop  → which process is causing it?
    ↓ happened in the past?
sar -u -f /var/log/sysstat/saXX → check historical metrics
journalctl --since "2026-06-08 03:00" → what events happened then?
```
