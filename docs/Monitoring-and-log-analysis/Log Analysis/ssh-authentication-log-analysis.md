# SSH Authentication Log Analysis

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Authentication Logs](#2-authentication-logs)
- [3. Monitoring SSH Activity in Real Time](#3-monitoring-ssh-activity-in-real-time)
- [4. Successful SSH Authentication](#4-successful-ssh-authentication)
- [5. Failed Authentication Attempts](#5-failed-authentication-attempts)
- [6. Public Key Authentication](#6-public-key-authentication)
- [7. Sudo Activity Analysis](#7-sudo-activity-analysis)
- [8. Privilege Escalation Monitoring](#8-privilege-escalation-monitoring)
- [9. Filtering SSH Logs with grep](#9-filtering-ssh-logs-with-grep)
- [10. SOC-Style Security Monitoring](#10-soc-style-security-monitoring)
- [11. Key Takeaways](#11-key-takeaways)

---

# 1. Introduction

This lab demonstrates SSH authentication log analysis using:
- `auth.log`
- `tail`
- `grep`
- SSH login activity
- sudo monitoring
- privilege escalation analysis

The goal was to simulate basic SOC-style authentication monitoring.

---

# 2. Authentication Logs

Linux authentication events are stored in:

```text
/var/log/auth.log
```

The log contains:
- SSH logins
- failed logins
- sudo usage
- user switching
- privilege escalation attempts

---

# 3. Monitoring SSH Activity in Real Time

## Live monitoring

```bash
sudo tail -f /var/log/auth.log
```

---

## Explanation

| Part | Meaning |
|---|---|
| tail | show end of file |
| -f | follow/live mode |
| auth.log | authentication log |

---

## Observation

Real-time monitoring displayed:
- SSH logins
- sudo sessions
- cron activity
- failed authentication attempts

---

# 4. Successful SSH Authentication

## Example event

```text
Accepted publickey for krystian from 192.168.0.83
```

---

## Analysis

| Element | Meaning |
|---|---|
| Accepted publickey | successful login |
| krystian | authenticated user |
| 192.168.0.83 | source IP |
| ssh2 | SSH protocol version |
| ED25519 | SSH key type |

---

## Observation

The system used:
passwordless SSH authentication with public keys.

This demonstrates:
secure SSH hardening practices.

---

# 5. Failed Authentication Attempts

## Example event

```text
Failed password for invalid user admin from 192.168.0.50
```

---

## Analysis

| Element | Meaning |
|---|---|
| Failed password | authentication failed |
| invalid user | username does not exist |
| source IP | attack source |
| sshd | SSH daemon |

---

## Security Insight

Repeated failed logins may indicate:
- brute-force attacks
- password spraying
- unauthorized access attempts

---

# 6. Public Key Authentication

## Example event

```text
Accepted publickey for krystian
```

---

## Observation

The SSH server accepted:
- public key authentication
- ED25519 SSH keys

Benefits:
- stronger authentication
- resistance to brute-force attacks
- passwordless login workflow

---

# 7. Sudo Activity Analysis

## Example event

```text
sudo: krystian : COMMAND=/usr/bin/tail -f /var/log/auth.log
```

---

## Analysis

| Element | Meaning |
|---|---|
| sudo | privileged command |
| krystian | executing user |
| COMMAND | executed command |

---

## Observation

Linux logs:
- privileged command execution
- user identity
- executed commands
- session activity

This creates:
a detailed administrative audit trail.

---

# 8. Privilege Escalation Monitoring

## Example failed SU attempt

```text
FAILED SU (to root)
```

---

## Analysis

| Element | Meaning |
|---|---|
| FAILED SU | failed privilege escalation |
| to root | target account |
| authentication failure | incorrect credentials |

---

## Observation

Privilege escalation attempts are highly relevant in:
- SOC monitoring
- forensic analysis
- incident response

---

# 9. Filtering SSH Logs with grep

## Search successful SSH logins

```bash
sudo grep -ai "Accepted publickey" /var/log/auth.log
```

---

## Search failed login attempts

```bash
sudo grep -ai "Failed password" /var/log/auth.log
```

---

## Search sudo activity

```bash
sudo grep -ai "sudo:" /var/log/auth.log
```

---

## Search failed privilege escalation

```bash
sudo grep -ai "FAILED SU" /var/log/auth.log
```

---

## Explanation of flags

| Flag | Meaning |
|---|---|
| -a | treat binary as text |
| -i | ignore case |

---

# 10. SOC-Style Security Monitoring

The authentication logs created a security timeline showing:
- successful SSH access
- failed login attempts
- sudo activity
- privilege escalation attempts
- cron execution
- administrative actions

This simulated:
basic SOC-style authentication monitoring workflows.

---

# 11. Key Takeaways

- `auth.log` is critical for authentication monitoring
- Linux logs SSH activity in detail
- `tail -f` enables live monitoring
- `grep` simplifies event filtering
- Public key authentication improves SSH security
- Authentication logs support:
  - incident response
  - forensic analysis
  - troubleshooting
  - operational visibility
- Failed login attempts may indicate attack activity
- Sudo logs provide administrative audit visibility
