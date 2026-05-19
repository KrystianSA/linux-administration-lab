# System Health Monitoring with Cron

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Monitoring Script](#2-monitoring-script)
- [3. Metrics Collected](#3-metrics-collected)
- [4. Automating with Cron](#4-automating-with-cron)
- [5. Logging Results](#5-logging-results)
- [6. Monitoring Workflow](#6-monitoring-workflow)
- [7. Example Output](#7-example-output)
- [8. Key Takeaways](#8-key-takeaways)

---

# 1. Introduction

This lab demonstrates how to automate basic Linux system monitoring using:
- shell scripting
- cron jobs
- log files

The goal was to create a lightweight recurring health check.

---

# 2. Monitoring Script

## Script

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

# 3. Metrics Collected

| Command | Purpose |
|---|---|
| date | current timestamp |
| uptime | uptime and load averages |
| free -h | RAM usage |
| df -h / | disk usage |

---

# 4. Automating with Cron

## Cron entry

```cron
*/1 * * * * /home/krystian/scripts/system-health.sh >> /home/krystian/logs/system-health.log 2>&1
```

---

## Explanation

| Part | Meaning |
|---|---|
| */1 * * * * | run every minute |
| >> | append output |
| 2>&1 | include errors |

---

# 5. Logging Results

Output was redirected into:

```text
~/logs/system-health.log
```

This creates:
- recurring monitoring records
- historical logs
- troubleshooting visibility

---

# 6. Monitoring Workflow

```text
cron
    ↓
shell script
    ↓
system metrics
    ↓
log file
```

---

# 7. Example Output

```text
===== SYSTEM HEALTH CHECK =====
Tue May 19 12:43:01 PM UTC 2026

===== UPTIME =====
12:43:01 up 1:15, 4 users, load average: 0.00, 0.00, 0.00

===== MEMORY USAGE =====
Mem: 3.3Gi used 452Mi free 2.3Gi

===== DISK USAGE =====
/dev/mapper/ubuntu--vg-ubuntu--lv 33%
```

---

# 8. Key Takeaways

- Cron can automate lightweight monitoring
- Shell scripts are useful for recurring health checks
- Log files provide historical monitoring visibility
- Redirecting output is essential for troubleshooting
- Small automation tasks can simulate real monitoring workflows
