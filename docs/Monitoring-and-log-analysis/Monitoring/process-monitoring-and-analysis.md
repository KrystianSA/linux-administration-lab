# Process Monitoring and Analysis

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Understanding Linux Processes](#2-understanding-linux-processes)
- [3. Monitoring Processes with top](#3-monitoring-processes-with-top)
- [4. Interactive Monitoring with htop](#4-interactive-monitoring-with-htop)
- [5. Understanding Process States](#5-understanding-process-states)
- [6. Process Priorities and nice Values](#6-process-priorities-and-nice-values)
- [7. Real Service Monitoring](#7-real-service-monitoring)
- [8. Process Hierarchy](#8-process-hierarchy)
- [9. Monitoring Commands with watch](#9-monitoring-commands-with-watch)
- [10. Permissions and sudo](#10-permissions-and-sudo)
- [11. Key Takeaways](#11-key-takeaways)

---

# 1. Introduction

This lab demonstrates:
- Linux process monitoring
- CPU analysis
- memory analysis
- process hierarchy inspection
- scheduler priorities
- live monitoring

The goal was to understand how Linux manages running processes and system activity.

---

# 2. Understanding Linux Processes

Linux treats nearly everything as:
a process.

Examples include:
- SSH sessions
- Fail2Ban
- cron jobs
- systemd services
- shell sessions
- monitoring tools

Processes consume:
- CPU time
- memory
- system resources

Monitoring processes is essential for:
- troubleshooting
- performance analysis
- operational visibility
- incident investigation

---

# 3. Monitoring Processes with top

## Launch top

```bash
top
```

---

## Observation

The command displayed:
- CPU usage
- RAM usage
- uptime
- process count
- load average
- active processes

---

## Example metrics

```text
load average: 0.00, 0.00, 0.00
```

This indicated:
very low system load.

---

## Important Insight

Load average represents:
- runnable processes
- CPU wait time
- IO wait time

It does not only represent:
CPU utilization.

---

## Load Average Interpretation

| Load | Meaning |
|---|---|
| 0.00 | idle system |
| 1.00 | approximately one busy CPU core |
| higher than CPU core count | possible overload |

---

# 4. Interactive Monitoring with htop

## Launch htop

```bash
htop
```

---

## Observation

Compared to `top`:
`htop` provided:
- colorized interface
- interactive navigation
- process hierarchy view
- easier sorting
- better usability

---

## Useful Shortcuts

| Key | Action |
|---|---|
| F5 | tree view |
| F6 | sorting |
| F9 | kill process |
| / | search |
| q | quit |

---

## Additional Observation

The process list displayed:
real Linux services such as:
- Fail2Ban
- systemd
- chronyd
- rsyslog
- unattended-upgrades
- SSH sessions

---

# 5. Understanding Process States

Linux processes operate in different states.

---

## Common Process States

| State | Meaning |
|---|---|
| R | running |
| S | sleeping |
| T | stopped |
| Z | zombie |

---

## Observation

The monitoring output displayed:
active, sleeping, and stopped processes.

---

## Important Insight

Stopped processes are commonly created using:
`CTRL + Z`.

Zombie processes represent:
terminated child processes waiting for cleanup.

---

# 6. Process Priorities and nice Values

Linux uses scheduler priorities to determine:
CPU allocation behavior.

---

## nice Value Range

| nice value | Meaning |
|---|---|
| -20 | highest priority |
| 0 | default priority |
| 19 | lowest priority |

---

## Observation

Monitoring tools displayed:
- `PR` → scheduler priority
- `NI` → nice value

Example:

```text
PR  NI
20   0
```

This represented:
default process priority.

---

## Launching Low-Priority Processes

```bash
nice -n 10 backup.sh
```

This launched:
the process with reduced CPU priority.

---

## Important Insight

The `nice` mechanism acts as:
a scheduling hint for the Linux scheduler.

---

# 7. Real Service Monitoring

The monitoring tools displayed:
real active services including:
- Fail2Ban
- SSH sessions
- cron
- systemd
- chronyd

This demonstrated:
real operational visibility.

---

## Example Process

```text
/usr/bin/python3 /usr/bin/fail2ban-server
```

This confirmed:
the Fail2Ban service was actively running.

---

# 8. Process Hierarchy

## Tree View in htop

Press:

```text
F5
```

inside `htop`.

---

## Observation

The tree view displayed:
- parent processes
- child processes
- systemd hierarchy
- SSH session relationships

---

## Important Insight

Linux processes exist inside:
a hierarchical process tree.

This structure helps:
- troubleshoot services
- identify spawned processes
- analyze sessions
- understand system behavior

---

# 9. Monitoring Commands with watch

## Monitor memory usage

```bash
watch free -h
```

---

## Observation

`watch` repeatedly executed:
the specified command.

Default refresh interval:
2 seconds.

---

## Example with custom interval

```bash
watch -n 1 free -h
```

This refreshed:
every second.

---

## Important Insight

`watch` repeatedly launches:
new command instances.

---

## sudo Example

Incorrect:

```bash
watch "sudo fail2ban-client status sshd"
```

Correct:

```bash
sudo watch fail2ban-client status sshd
```

This avoids:
repeated password prompts.

---

# 10. Permissions and sudo

Some monitoring commands required:
elevated privileges.

This occurred because:
Linux restricts access to:
- sensitive process information
- protected files
- privileged services
- system internals

---

## Example

```text
Permission denied
```

This behavior represented:
normal Linux security protections.

---

# 11. Key Takeaways

- Linux systems expose detailed process visibility
- `top` provides basic real-time monitoring
- `htop` improves usability and visualization
- Load average reflects overall system pressure
- Linux processes operate in multiple states
- Scheduler priorities influence CPU allocation
- `watch` enables lightweight live monitoring
- Process trees help analyze service relationships
- Monitoring often requires elevated permissions
- Process monitoring is essential for:
  - troubleshooting
  - incident response
  - performance analysis
  - operations
