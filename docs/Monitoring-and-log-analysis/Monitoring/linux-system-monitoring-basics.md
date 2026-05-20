# Linux System Monitoring Basics

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Understanding System Monitoring](#2-understanding-system-monitoring)
- [3. Using top](#3-using-top)
- [4. Understanding top Output](#4-understanding-top-output)
- [5. Using htop](#5-using-htop)
- [6. Comparing top and htop](#6-comparing-top-and-htop)
- [7. Process Priorities and nice Values](#7-process-priorities-and-nice-values)
- [8. Monitoring Real System Services](#8-monitoring-real-system-services)
- [9. Key Takeaways](#9-key-takeaways)

---

# 1. Introduction

This lab demonstrates basic Linux system monitoring using:
- `top`
- `htop`
- process analysis
- CPU monitoring
- memory monitoring
- process priorities

The goal was to understand how Linux displays real-time system activity.

---

# 2. Understanding System Monitoring

Linux monitoring tools provide:
- real-time CPU usage
- memory usage
- running processes
- system load
- process priorities
- active services

System monitoring is essential for:
- troubleshooting
- performance analysis
- operational visibility
- server administration

---

# 3. Using top

## Launch top

```bash
top
```

---

## Description

The `top` program provides:
a dynamic real-time view of a running Linux system.

---

## Observations

The output displayed:
- CPU utilization
- RAM usage
- process count
- system uptime
- active processes

Example:

```text
load average: 0.00, 0.00, 0.00
```

This indicated:
very low system load.

---

# 4. Understanding top Output

## Example metrics

| Metric | Meaning |
|---|---|
| load average | current system load |
| Tasks | active processes |
| Cpu(s) | CPU usage statistics |
| Mem | RAM usage |
| Swap | swap memory usage |

---

## Example process entry

```text
fail2ban-server
```

This confirmed:
the Fail2Ban service was actively running.

---

## Process states

| State | Meaning |
|---|---|
| R | running |
| S | sleeping |
| Z | zombie |
| T | stopped |

---

# 5. Using htop

## Launch htop

```bash
htop
```

---

## Description

`htop` is:
a cross-platform ncurses-based process viewer.

It provides:
- interactive navigation
- colorized output
- mouse support
- process hierarchy view
- improved usability

---

## Observations

Compared to `top`:
`htop` provided:
- clearer visualization
- easier navigation
- interactive process management
- organized process lists

---

## Useful htop shortcuts

| Key | Action |
|---|---|
| F5 | tree view |
| F6 | sorting |
| F9 | kill process |
| / | search |
| q | quit |

---

# 6. Comparing top and htop

| Feature | top | htop |
|---|---|---|
| Interactive UI | basic | advanced |
| Mouse support | no | yes |
| Color support | limited | yes |
| Tree view | no | yes |
| Ease of use | moderate | high |

---

# 7. Process Priorities and nice Values

Linux uses:
process priorities to determine CPU scheduling behavior.

---

## nice value range

| nice value | Priority |
|---|---|
| -20 | highest priority |
| 0 | default priority |
| 19 | lowest priority |

---

## Observation

Processes displayed:
- `PR` → scheduler priority
- `NI` → nice value

Example:

```text
PR  NI
20   0
```

This represented:
a normal process priority.

---

## Example usage

```bash
nice -n 10 backup.sh
```

This launches:
the process with lower CPU priority.

---

# 8. Monitoring Real System Services

The monitoring tools displayed real Linux services such as:
- Fail2Ban
- SSH sessions
- systemd
- chronyd
- rsyslog
- unattended-upgrades

This demonstrated:
real operational visibility into the running system.

---

# 9. Key Takeaways

- `top` provides real-time Linux monitoring
- `htop` improves usability and visualization
- Linux systems expose detailed process information
- Process priorities influence CPU scheduling
- Monitoring tools help identify:
  - resource usage
  - active services
  - performance issues
  - system activity
- `htop` is commonly preferred by Linux administrators
- Monitoring is essential for troubleshooting and operations
