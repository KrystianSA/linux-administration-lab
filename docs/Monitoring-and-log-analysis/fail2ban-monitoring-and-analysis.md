# Fail2Ban Monitoring and Analysis

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Understanding Fail2Ban](#2-understanding-fail2ban)
- [3. Checking Fail2Ban Status](#3-checking-fail2ban-status)
- [4. Viewing Active Jails](#4-viewing-active-jails)
- [5. Monitoring Failed SSH Attempts](#5-monitoring-failed-ssh-attempts)
- [6. Triggering a Ban](#6-triggering-a-ban)
- [7. Viewing Banned IP Addresses](#7-viewing-banned-ip-addresses)
- [8. Monitoring Fail2Ban Logs](#8-monitoring-fail2ban-logs)
- [9. nftables Integration](#9-nftables-integration)
- [10. Adjusting Ban Time](#10-adjusting-ban-time)
- [11. Unbanning an IP Address](#11-unbanning-an-ip-address)
- [12. SOC-Style Security Monitoring](#12-soc-style-security-monitoring)
- [13. Key Takeaways](#13-key-takeaways)

---

# 1. Introduction

This lab demonstrates:
- Fail2Ban monitoring
- brute-force protection
- SSH attack detection
- automatic IP banning
- log analysis
- active defense monitoring

The goal was to simulate basic blue-team and SOC-style defensive workflows.

---

# 2. Understanding Fail2Ban

Fail2Ban monitors log files and automatically blocks IP addresses after repeated authentication failures.

In this setup:
- SSH logs were monitored
- failed login attempts triggered bans
- bans were enforced through nftables/UFW integration

---

# 3. Checking Fail2Ban Status

## Verify service status

```bash
sudo systemctl status fail2ban
```

---

## Check Fail2Ban client status

```bash
sudo fail2ban-client status
```

---

## Observation

The output displayed:
- active jails
- monitored services
- current status information

---

# 4. Viewing Active Jails

## Display configured jails

```bash
sudo fail2ban-client status
```

---

## Example output

```text
Jail list: sshd
```

---

## Display detailed SSH jail information

```bash
sudo fail2ban-client status sshd
```

---

## Observation

The SSH jail displayed:
- failed attempt count
- currently banned IPs
- monitored log files

---

# 5. Monitoring Failed SSH Attempts

## Live monitoring of authentication logs

```bash
sudo tail -f /var/log/auth.log
```

---

## Example failed authentication

```text
Failed password for invalid user admin from 192.168.0.50
```

---

## Observation

Repeated failed SSH attempts were visible in:
- `auth.log`
- Fail2Ban monitoring

This demonstrated:
real-time brute-force detection.

---

# 6. Triggering a Ban

A brute-force simulation was performed by intentionally entering incorrect SSH credentials multiple times.

After exceeding the configured retry threshold:
Fail2Ban automatically blocked the source IP address.

---

## Example behavior

```text
Connection refused
```

---

## Observation

The testing machine was temporarily blocked after repeated failed login attempts.

This confirmed:
- active SSH protection
- automatic ban enforcement
- defensive automation functionality

---

# 7. Viewing Banned IP Addresses

## Check banned IPs

```bash
sudo fail2ban-client status sshd
```

---

## Example output

```text
Banned IP list: 192.168.0.83
```

---

## Observation

The source IP appeared inside the active ban list.

---

# 8. Monitoring Fail2Ban Logs

## View Fail2Ban logs

```bash
sudo tail -f /var/log/fail2ban.log
```

---

## Example event

```text
Ban 192.168.0.83
```

---

## Observation

The logs showed:
- detected attacks
- active bans
- unban events
- jail activity

---

# 9. nftables Integration

The system used:
- nftables
- UFW
- Fail2Ban integration

Fail2Ban dynamically inserted firewall rules to block malicious IP addresses.

---

## Observation

The banning mechanism operated through:
dynamic firewall rule manipulation.

---

# 10. Adjusting Ban Time

The default configuration blocked IP addresses after:
multiple failed attempts within a short time period.

The ban duration was adjusted to simplify testing and recovery.

---

## Example configuration

```ini
bantime = 5m
maxretry = 3
findtime = 10m
```

---

## Explanation

| Option | Meaning |
|---|---|
| bantime | ban duration |
| maxretry | allowed failed attempts |
| findtime | detection time window |

---

# 11. Unbanning an IP Address

## Remove banned IP manually

```bash
sudo fail2ban-client set sshd unbanip 192.168.0.83
```

---

## Observation

After unbanning:
SSH access functionality was restored immediately.

---

# 12. SOC-Style Security Monitoring

This lab simulated:
- brute-force attack detection
- authentication monitoring
- active defense mechanisms
- firewall automation
- incident visibility

The workflow connected:
- SSH logs
- auth.log analysis
- firewall rules
- automatic blocking
- security monitoring

This created:
a basic blue-team defensive pipeline.

---

# 13. Key Takeaways

- Fail2Ban provides automated brute-force protection
- SSH authentication failures can trigger automatic bans
- `auth.log` is critical for attack detection
- Fail2Ban integrates with firewall systems
- nftables can dynamically enforce bans
- Authentication logs support:
  - monitoring
  - incident response
  - attack detection
  - defensive automation
- Fail2Ban helps reduce SSH attack exposure
