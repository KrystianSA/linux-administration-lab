# Journalctl Basics

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Understanding journalctl](#2-understanding-journalctl)
- [3. Viewing System Logs](#3-viewing-system-logs)
- [4. Navigation Inside journalctl](#4-navigation-inside-journalctl)
- [5. Filtering Logs](#5-filtering-logs)
- [6. Viewing Service Logs](#6-viewing-service-logs)
- [7. Viewing Error Logs](#7-viewing-error-logs)
- [8. Viewing Current Boot Logs](#8-viewing-current-boot-logs)
- [9. Viewing Kernel Logs](#9-viewing-kernel-logs)
- [10. Time-Based Filtering](#10-time-based-filtering)
- [11. Troubleshooting and Observations](#11-troubleshooting-and-observations)
- [12. Key Takeaways](#12-key-takeaways)

---

# 1. Introduction

This lab demonstrates basic Linux log analysis using:

- `journalctl`
- systemd journal logs
- service filtering
- kernel log analysis
- time-based filtering

The goal was to simulate modern Linux troubleshooting and SOC-style monitoring workflows.

---

# 2. Understanding journalctl

`journalctl` is the logging utility used by `systemd`.

Unlike traditional plain text logs:
- `journalctl` stores structured logs
- logs include metadata
- logs can be filtered dynamically

The journal contains:
- system logs
- kernel logs
- service logs
- cron activity
- authentication events

---

# 3. Viewing System Logs

## Display all journal logs

```bash
journalctl
```

---

## Observation

By default:
`journalctl` opens inside the `less` pager.

This allows:
- scrolling
- searching
- navigating large logs

---

# 4. Navigation Inside journalctl

| Key | Action |
|---|---|
| q | quit |
| / | search |
| n | next search result |
| Shift + G | jump to end |

---

# 5. Filtering Logs

## View logs since today

```bash
journalctl --since today
```

---

## View logs since a specific time

```bash
journalctl --since "2026-05-20 11:00"
```

---

## Observation

Time-based filtering allowed:
- timeline reconstruction
- cron activity analysis
- service troubleshooting

---

# 6. Viewing Service Logs

## View SSH service logs

```bash
journalctl -u ssh
```

---

## Explanation

| Flag | Meaning |
|---|---|
| -u | filter by systemd unit/service |

This displays:
only logs related to the SSH service.

---

# 7. Viewing Error Logs

## Display only error-level logs

```bash
journalctl -p err
```

---

## Explanation

| Flag | Meaning |
|---|---|
| -p | priority filter |
| err | error severity |

---

# 8. Viewing Current Boot Logs

## Display current boot session logs

```bash
journalctl -b
```

---

## Observation

The output included:
- Linux boot sequence
- EFI initialization
- ACPI detection
- memory allocation
- system startup activity

---

# 9. Viewing Kernel Logs

## Display kernel-only logs

```bash
journalctl -k
```

---

## Observation

Kernel logs included:
- boot initialization
- NUMA configuration
- memory mapping
- ACPI configuration
- kernel hardware detection

---

# 10. Time-Based Filtering

## Example

```bash
journalctl --since "2026-05-20 11:50"
```

---

## Observed events

The logs revealed:
- recurring cron executions
- systemd service activity
- chronyd synchronization events
- automated monitoring scripts

Example:

```text
CRON[3244]: (krystian) CMD (/home/krystian/script/system-health.sh)
```

---

# 11. Troubleshooting and Observations

## Incorrect syntax example

Incorrect:

```bash
journalctl -since today
```

Result:

```text
invalid option -- 's'
```

---

## Correct syntax

```bash
journalctl --since today
```

---

## Incorrect quotation example

Incorrect:

```bash
journalctl --since "2026-05-20 10:00""
```

This caused:
the shell to wait for unfinished input.

---

## Correct command

```bash
journalctl --since "2026-05-20 10:00"
```

---

# 12. Key Takeaways

- `journalctl` provides centralized Linux logging
- systemd journals are more advanced than plain text logs
- logs can be filtered by:
  - service
  - severity
  - time
  - boot session
- `journalctl` is essential for:
  - troubleshooting
  - monitoring
  - incident analysis
  - operational visibility
- Time filtering enables timeline reconstruction
- Kernel logs provide low-level system visibility
```
