# Linux Log Analysis Basics

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Understanding auth.log](#2-understanding-authlog)
- [3. Live Log Monitoring](#3-live-log-monitoring)
- [4. Using grep for Log Filtering](#4-using-grep-for-log-filtering)
- [5. Common Security Events](#5-common-security-events)
- [6. Binary File Detection Issue](#6-binary-file-detection-issue)
- [7. Understanding grep Flags](#7-understanding-grep-flags)
- [8. SOC-Style Monitoring](#8-soc-style-monitoring)
- [9. Key Takeaways](#9-key-takeaways)

---

# 1. Introduction

This lab demonstrates basic Linux log analysis techniques using:
- `tail`
- `grep`
- `auth.log`

The goal was to simulate basic SOC-style monitoring and security event analysis.

---

# 2. Understanding auth.log

The file:

```text
/var/log/auth.log
```

contains authentication-related events such as:
- SSH logins
- failed logins
- sudo activity
- user switching
- privilege escalation attempts

---

# 3. Live Log Monitoring

## Monitoring logs in real time

```bash
sudo tail -f /var/log/auth.log
```

---

## Command explanation

| Part | Meaning |
|---|---|
| tail | show end of file |
| -f | follow/live mode |
| auth.log | authentication log file |

---

## Observation

After logging into SSH from another terminal:
new authentication events immediately appeared in the log.

This demonstrates:
real-time Linux security monitoring.

---

# 4. Using grep for Log Filtering

## Searching failed privilege escalation attempts

```bash
sudo grep -ai "FAILED SU" /var/log/auth.log
```

---

## Searching successful SSH logins

```bash
sudo grep -ai "Accepted publickey" /var/log/auth.log
```

---

## Searching sudo activity

```bash
sudo grep -ai "sudo:" /var/log/auth.log
```

---

# 5. Common Security Events

## Successful SSH authentication

Example:

```text
Accepted publickey for krystian from 192.168.0.83
```

Meaning:
- successful login
- SSH public key authentication
- source IP recorded

---

## Failed privilege escalation

Example:

```text
FAILED SU (to root)
```

Meaning:
- failed attempt to switch to root
- incorrect credentials used
- authentication failure recorded

---

## Sudo command execution

Example:

```text
sudo: krystian : COMMAND=/usr/bin/tail -f /var/log/auth.log
```

Meaning:
- user executed privileged command
- sudo activity was logged
- full command history is visible

---

# 6. Binary File Detection Issue

During filtering:

```bash
sudo grep "FAILED SU" /var/log/auth.log
```

the following message appeared:

```text
grep: /var/log/auth.log: binary file matches
```

---

## Cause

`grep` incorrectly detected the log file as a binary file.

Possible reasons:
- non-printable characters
- rotated logs
- encoding issues
- control characters

---

## Solution

The `-a` flag forces `grep` to treat the file as text:

```bash
sudo grep -ai "FAILED SU" /var/log/auth.log
```

---

# 7. Understanding grep Flags

| Flag | Meaning |
|---|---|
| -a | treat binary as text |
| -i | ignore case |
| -r | recursive search |
| -n | show line numbers |

---

## Common grep usage

```bash
grep -rin "error"
```

This recursively searches for:
- `error`
- case insensitive
- with line numbers

---

# 8. SOC-Style Monitoring

The log analysis process simulated basic SOC workflows:
- live monitoring
- authentication analysis
- failed login investigation
- sudo activity tracking
- SSH access visibility

The logs created a security timeline showing:
- successful logins
- failed authentication attempts
- privileged command execution
- recurring cron activity

---

# 9. Key Takeaways

- Linux logs provide detailed operational visibility
- `auth.log` is critical for authentication monitoring
- `tail -f` enables live monitoring
- `grep` is essential for filtering large logs
- Authentication events create a security timeline
- Linux systems log:
  - SSH access
  - sudo activity
  - failed authentication
  - privilege escalation attempts
- Basic log analysis resembles real SOC workflows
