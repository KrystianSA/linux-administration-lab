# Disk and Memory Monitoring

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Disk Usage Monitoring with df](#2-disk-usage-monitoring-with-df)
- [3. Directory Usage Monitoring with du](#3-directory-usage-monitoring-with-du)
- [4. Memory Monitoring with free](#4-memory-monitoring-with-free)
- [5. Understanding Linux RAM Cache](#5-understanding-linux-ram-cache)
- [6. Real-Time Monitoring with watch](#6-real-time-monitoring-with-watch)
- [7. Block Device Analysis with lsblk](#7-block-device-analysis-with-lsblk)
- [8. Understanding LVM](#8-understanding-lvm)
- [9. Filesystem and Mount Analysis](#9-filesystem-and-mount-analysis)
- [10. Monitoring Permissions and sudo](#10-monitoring-permissions-and-sudo)
- [11. Key Takeaways](#11-key-takeaways)

---

# 1. Introduction

This lab demonstrates:
- disk monitoring
- memory monitoring
- filesystem analysis
- LVM inspection
- real-time monitoring
- Linux storage visibility

The goal was to understand how Linux manages:
- storage
- memory
- filesystems
- mounted devices

---

# 2. Disk Usage Monitoring with df

## Display filesystem usage

```bash
df -h
```

---

## Explanation

| Flag | Meaning |
|---|---|
| df | disk filesystem usage |
| -h | human readable output |

---

## Observation

The command displayed:
- total disk size
- used storage
- available space
- filesystem mount points

Example:

```text
/dev/mapper/ubuntu--vg-ubuntu--lv   11G   3.4G   6.8G   33%   /
```

This represented:
the root filesystem usage.

---

## Important Insight

Linux systems frequently experience operational problems due to:
disk exhaustion.

High disk usage may cause:
- failed package updates
- logging failures
- service crashes
- Docker failures
- temporary file issues

---

# 3. Directory Usage Monitoring with du

## Analyze directory sizes

```bash
sudo du -sh /*
```

---

## Explanation

| Flag | Meaning |
|---|---|
| du | disk usage |
| -s | summary |
| -h | human readable |

---

## Observation

The command displayed:
the largest directories inside the filesystem.

Example:

```text
2.8G /usr
611M /var
```

---

## Additional Observation

Some directories generated:

```text
Permission denied
```

or:

```text
No such file or directory
```

This occurred because:
- sensitive directories require elevated permissions
- `/proc` is a live virtual filesystem
- processes may terminate during scanning

---

# 4. Memory Monitoring with free

## Display memory usage

```bash
free -h
```

---

## Explanation

| Column | Meaning |
|---|---|
| total | total RAM |
| used | RAM used by processes |
| free | completely unused RAM |
| buff/cache | filesystem cache |
| available | realistically available RAM |

---

## Example Output

```text
total        3.3Gi
used         516Mi
free         2.0Gi
buff/cache   974Mi
available    2.8Gi
```

---

# 5. Understanding Linux RAM Cache

Linux aggressively uses unused RAM for:
filesystem cache and buffers.

This improves:
- application responsiveness
- filesystem performance
- disk read speeds

---

## Important Insight

Linux considers:
unused RAM as wasted RAM.

Instead of leaving memory empty:
Linux stores:
- recently accessed files
- binaries
- filesystem metadata
- cached disk blocks

inside RAM.

---

## Key Observation

`buff/cache` memory:
is not permanently reserved.

Linux can immediately reclaim it if:
applications require additional memory.

---

## Critical Difference

| Metric | Meaning |
|---|---|
| free | fully unused RAM |
| available | realistically usable RAM |

The `available` value is usually more important than `free`.

---

# 6. Real-Time Monitoring with watch

## Monitor RAM continuously

```bash
watch free -h
```

---

## Explanation

`watch` repeatedly executes commands at fixed intervals.

Default refresh interval:
2 seconds.

---

## Example

```bash
watch -n 1 free -h
```

This refreshes:
every second.

---

## Additional Observation

Using:

```bash
watch "sudo fail2ban-client status sshd"
```

caused repeated password prompts.

This occurred because:
`watch` repeatedly launched new commands.

---

## Correct Approach

```bash
sudo watch fail2ban-client status sshd
```

This applies `sudo` to:
the entire monitoring session.

---

# 7. Block Device Analysis with lsblk

## Display block devices

```bash
lsblk
```

---

## Observation

The output displayed:
- disks
- partitions
- logical volumes
- mount points

Example:

```text
sda
├─sda1
├─sda2
└─sda3
  └─ubuntu--vg-ubuntu--lv
```

---

## Partition Analysis

| Partition | Purpose |
|---|---|
| sda1 | EFI boot partition |
| sda2 | Linux boot partition |
| sda3 | Linux system partition/LVM |

---

# 8. Understanding LVM

The system used:
Logical Volume Manager (LVM).

---

## LVM Structure

| Layer | Description |
|---|---|
| Physical Disk | `sda` |
| Partition | `sda3` |
| Volume Group | `ubuntu-vg` |
| Logical Volume | `ubuntu-lv` |

---

## Benefits of LVM

LVM enables:
- flexible storage allocation
- easier filesystem resizing
- snapshots
- improved storage management

---

# 9. Filesystem and Mount Analysis

## Display mounted filesystems

```bash
mount | head
```

---

## Observation

Linux mounts:
- disks
- virtual filesystems
- kernel interfaces
- temporary filesystems

Examples included:
- `proc`
- `sysfs`
- `tmpfs`

---

## Important Insight

Linux treats many internal system interfaces as:
virtual filesystems.

---

# 10. Monitoring Permissions and sudo

Many monitoring commands required:
`sudo`.

This occurred because:
Linux restricts access to:
- sensitive files
- process information
- system internals
- protected directories

---

## Example

```text
Permission denied
```

This behavior is:
normal Linux security functionality.

---

# 11. Key Takeaways

- `df` displays filesystem usage
- `du` identifies large directories
- `free` displays RAM usage
- Linux uses RAM aggressively for filesystem caching
- `available` memory is more important than `free`
- `watch` enables simple real-time monitoring
- `lsblk` visualizes storage structure
- LVM provides flexible storage management
- Linux exposes internal components through virtual filesystems
- Monitoring often requires elevated privileges
