# Troubleshooting #11 — High iowait, System Sluggish

## What is iowait?

`iowait` (`wa` in top) = percentage of time CPU is idle while waiting for disk I/O.

High `iowait` ≠ CPU problem. It means the **disk is the bottleneck**.
Adding more CPU won't help — fix the disk issue instead.

---

## Step-by-step flow

### Step 1 — Confirm iowait is the problem

```bash
top                    # look for high wa% in cpu line
vmstat 1               # column b = processes stuck in D state (waiting for I/O)
```

### Step 2 — Which disk is busy?

```bash
iostat -x 1
```

Key columns:
- `%util` — disk utilization (close to 100% = saturated)
- `await` — average wait time per I/O request (ms)
- `tps` — transactions per second (high tps + low kB = many small operations)

### Step 3 — Which process is causing it?

```bash
sudo iotop              # real-time, shows per-process I/O
sudo iotop -o           # only show processes actively doing I/O
```

### Step 4 — What is the process doing?

```bash
strace -c -p <PID>      # summary of syscalls — shows write/read call counts
strace -e trace=file -p <PID>  # only file operations
lsof -p <PID>           # which files does the process have open?
```

`strace -c` is the most useful — gives a table of "what the process did most":
```
% time     calls  syscall
 60.00    100000  write     ← writing 100k times = likely the problem
 30.00     50000  read
```

---

## When iotop shows no culprit

Sometimes `iowait` is high but `iotop` shows nothing obvious. Four possible causes:

### 1. NFS (network filesystem) lost connection

Processes stuck waiting for a network filesystem that stopped responding.
Check:
```bash
mount | grep nfs          # any NFS mounts?
vmstat 1                  # column b — many processes in D state?
df -h                     # hangs on NFS mount? = confirms NFS issue
```

Fix: unmount the NFS share or restore network connectivity.

### 2. Many processes in D state

```bash
ps aux | grep " D "       # find processes in uninterruptible sleep
vmstat 1                  # column b = count of D state processes
```

`kill -9` won't work on D state processes — they return to normal when I/O completes or times out.

### 3. Millions of small I/O operations (e.g. database)

Database doing thousands of small transactions — each one tiny but sum is large.
Symptom: high `tps` in `iostat` but low `kB_read/s` and `kB_wrtn/s`.

```bash
iostat -x 1               # high tps, low throughput = many small ops
strace -c -p <PID>        # high fsync/write call count confirms it
```

Fix: tune database (bigger write buffer, batch commits, faster disk/SSD).

### 4. Dying disk (hardware failure)

```bash
dmesg | grep -i error     # kernel I/O errors
dmesg | grep -i sda       # errors on specific disk
smartctl -a /dev/sda      # SMART health data (requires: sudo apt install smartmontools)
```

SMART shows: temperature, read error count, reallocated sectors, predicted failure.
If SMART shows errors → replace the disk ASAP.

---

## Full troubleshooting flow

```
top → high wa%
    ↓
vmstat 1 → column b (D state processes?)
    ↓
iostat -x 1 → which disk? (%util, await)
    ↓
iotop -o → which process?
    ↓ process found
strace -c -p <PID> → what is it doing?
    ↓ no process found
mount | grep nfs   → NFS issue?
dmesg | grep error → dying disk?
iostat tps high    → many small ops (database)?
```

---

## Quick reference

```bash
top                        # wa% = iowait
vmstat 1                   # b column = D state processes
iostat -x 1                # disk utilization per device
sudo iotop -o              # which process hits disk
strace -c -p <PID>         # what syscalls is process making
lsof -p <PID>              # which files does process have open
dmesg | grep -i error      # kernel/disk errors
smartctl -a /dev/sda       # disk health (SMART)
mount | grep nfs           # check NFS mounts
```
