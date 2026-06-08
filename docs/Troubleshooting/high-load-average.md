# Troubleshooting #9 — High Load Average

## What is load average?

Load average = queue of processes waiting for CPU (running + waiting).
Three numbers = last 1 minute, 5 minutes, 15 minutes.

```bash
uptime
# or see it in top (first line)
```

## How to interpret

```
load average / number of cores = actual utilization

2 cores, load 1.0  → 50%  — fine
2 cores, load 2.0  → 100% — at capacity
2 cores, load 4.0  → 200% — overloaded, queue building up
```

Check number of cores:
```bash
nproc
```

## CPU-bound vs I/O-bound — critical distinction

High load average has two very different causes:

```bash
vmstat 1
```

| Look at | High value means |
|---|---|
| column `r` | many processes waiting for CPU → CPU-bound |
| column `b` | many processes in D state (waiting for I/O) → I/O-bound |
| `wa` in cpu section | CPU itself is waiting for disk → I/O-bound |

**Why does this matter?**
- CPU-bound → add more CPU, optimize the application
- I/O-bound → fix the disk (faster disk, fix hanging NFS, check iostat)

Adding CPU won't help an I/O-bound problem.

## Step-by-step

```bash
uptime                    # check load average vs nproc
top                       # find processes with high %CPU or in D state
vmstat 1                  # column r (CPU queue) vs column b (I/O queue)
iostat -x 1               # if wa is high — which disk is busy?
iotop                     # which process is hitting the disk?
```

## Quick reference

```bash
uptime                    # load average
nproc                     # number of CPU cores
vmstat 1 5                # r=CPU queue, b=IO queue, wa=iowait
top                       # process-level view
```
