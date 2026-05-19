# Cron Basics

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Checking Cron Service](#2-checking-cron-service)
- [3. Cron Directories](#3-cron-directories)
- [4. Creating Script Directories](#4-creating-script-directories)
- [5. Creating a Shell Script](#5-creating-a-shell-script)
- [6. Making Script Executable](#6-making-script-executable)
- [7. Running the Script](#7-running-the-script)
- [8. Creating a Cron Job](#8-creating-a-cron-job)
- [9. Understanding Cron Syntax](#9-understanding-cron-syntax)
- [10. Redirecting Output](#10-redirecting-output)
- [11. Verifying Cron Execution](#11-verifying-cron-execution)
- [12. Key Takeaways](#12-key-takeaways)

---

# 1. Introduction

Cron is a Linux time-based job scheduler used to automate recurring tasks.

Common use cases:
- backups
- monitoring
- maintenance
- cleanup scripts
- scheduled automation

---

# 2. Checking Cron Service

## Verify cron status

```bash
sudo systemctl status cron
```

Expected result:

```text
active (running)
```

---

# 3. Cron Directories

Linux includes predefined cron directories:

| Directory | Frequency |
|---|---|
| /etc/cron.hourly | hourly |
| /etc/cron.daily | daily |
| /etc/cron.weekly | weekly |
| /etc/cron.monthly | monthly |

These directories are automatically processed by cron.

---

# 4. Creating Script Directories

## Create folders

```bash
mkdir -p ~/scripts ~/logs
```

---

## Explanation

| Element | Meaning |
|---|---|
| mkdir | create directory |
| -p | create parent directories if needed |

The `-p` option also prevents errors if directories already exist.

---

# 5. Creating a Shell Script

## Create script

```bash
nano ~/scripts/system-health.sh
```

---

## Script content

```bash
#!/bin/bash

echo "===== SYSTEM HEALTH CHECK ====="
date

echo ""
echo "===== UPTIME ====="
uptime

echo ""
echo "===== MEMORY USAGE ====="
free -h

echo ""
echo "===== DISK USAGE ====="
df -h /
```

---

# 6. Making Script Executable

## Add execute permission

```bash
chmod +x ~/scripts/system-health.sh
```

---

## Explanation

| Command | Purpose |
|---|---|
| chmod | change permissions |
| +x | add execute permission |

---

# 7. Running the Script

## Manual test

```bash
~/scripts/system-health.sh
```

The script should display:
- current date
- uptime
- memory usage
- disk usage

---

# 8. Creating a Cron Job

## Open crontab

```bash
crontab -e
```

---

## Add cron entry

```cron
*/1 * * * * /home/krystian/scripts/system-health.sh >> /home/krystian/logs/system-health.log 2>&1
```

---

# 9. Understanding Cron Syntax

## Cron structure

```text
minute hour day month weekday
```

---

## Example

```cron
*/1 * * * *
```

Meaning:

```text
run every minute
```

---

# 10. Redirecting Output

## Append output to log file

```bash
>> /home/krystian/logs/system-health.log
```

---

## Explanation

| Symbol | Meaning |
|---|---|
| > | overwrite file |
| >> | append to file |

---

## Redirecting errors

```bash
2>&1
```

Explanation:

| Stream | Meaning |
|---|---|
| 1 | stdout |
| 2 | stderr |

`2>&1` redirects error output to the same destination as standard output.

This ensures:
- successful output
- error messages

are both written into the same log file.

---

# 11. Verifying Cron Execution

## Check log file

```bash
cat ~/logs/system-health.log
```

Example:

```text
===== SYSTEM HEALTH CHECK =====
Tue May 19 12:43:01 PM UTC 2026
```

Repeated timestamps confirm:
- cron execution
- recurring scheduling
- successful automation

---

# 12. Key Takeaways

- Cron automates recurring Linux tasks
- Shell scripts can be scheduled through crontab
- Output redirection is important for logging
- `2>&1` combines standard output and errors
- Cron jobs should always be tested manually first
