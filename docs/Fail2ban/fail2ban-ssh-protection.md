# Fail2Ban SSH Protection

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Installing Fail2Ban](#2-installing-fail2ban)
- [3. Checking Service Status](#3-checking-service-status)
- [4. Checking Active Jails](#4-checking-active-jails)
- [5. SSH Jail Monitoring](#5-ssh-jail-monitoring)
- [6. Brute Force Simulation](#6-brute-force-simulation)
- [7. Understanding the Initial Problem](#7-understanding-the-initial-problem)
- [8. nftables Investigation](#8-nftables-investigation)
- [9. Configuring Custom SSH Port](#9-configuring-custom-ssh-port)
- [10. Retesting Fail2Ban](#10-retesting-fail2ban)
- [11. Unbanning an IP Address](#11-unbanning-an-ip-address)
- [12. Key Takeaways](#12-key-takeaways)

---

# 1. Introduction

Fail2Ban is a Linux security tool used to:
- monitor logs
- detect suspicious activity
- automatically block malicious IP addresses

In this lab:
Fail2Ban was configured to protect:
```text
SSH service running on custom port 2222
```

---

# 2. Installing Fail2Ban

## Installation

```bash
sudo apt install fail2ban -y
```

---

# 3. Checking Service Status

## Checking systemd service

```bash
sudo systemctl status fail2ban
```

Expected result:

```text
active (running)
```

---

# 4. Checking Active Jails

## Checking Fail2Ban application status

```bash
sudo fail2ban-client status
```

Example:

```text
Status
|- Number of jail: 1
`- Jail list: sshd
```

---

# 5. SSH Jail Monitoring

## Checking SSH jail

```bash
sudo fail2ban-client status sshd
```

Example output:

```text
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed: 0
`- Actions
   |- Currently banned: 0
```

---

# 6. Brute Force Simulation

## Test Scenario

The SSH service was tested by:
- attempting multiple failed logins
- using invalid usernames
- triggering repeated authentication failures

Example:

```bash
ssh fakeuser@192.168.0.84 -p 2222
```

---

## Result

Fail2Ban detected repeated failures and automatically banned the source IP.

Example:

```text
Currently banned: 1
Banned IP list: 192.168.0.83
```

---

# 7. Understanding the Initial Problem

Initially:
Fail2Ban appeared to detect attacks correctly,
but SSH connections were still possible.

---

## Investigation

Firewall inspection showed that:
Fail2Ban was blocking:
```text
port 22
```

while SSH had been configured on:
```text
port 2222
```

---

# 8. nftables Investigation

## Checking nftables rules

```bash
sudo nft list ruleset
```

Observed rule:

```text
tcp dport 22 ip saddr @addr-set-sshd reject
```

This confirmed that:
- Fail2Ban was functioning correctly
- the wrong SSH port was being protected

---

# 9. Configuring Custom SSH Port

## Editing configuration

```bash
sudo nano /etc/fail2ban/jail.local
```

---

## Added configuration

```ini
[sshd]
enabled = true
port = 2222
banaction = nftables
maxretry = 5
findtime = 10m
bantime = 1m
```

---

## Configuration Breakdown

| Option | Meaning |
|---|---|
| enabled | enables SSH jail |
| port | monitored SSH port |
| banaction | firewall backend |
| maxretry | allowed failed attempts |
| findtime | time window |
| bantime | ban duration |

---

## Restarting Fail2Ban

```bash
sudo systemctl restart fail2ban
```

---

# 10. Retesting Fail2Ban

After updating the configuration:
another brute-force simulation was performed.

---

## Result

This time:
Fail2Ban correctly blocked:
```text
SSH port 2222
```

---

## Observed Behavior

Valid users were also blocked after ban activation.

SSH attempts returned:

```text
Connection refused
```

This confirmed that:
- the ban was active
- nftables rules were applied correctly
- the source IP had been blocked

---

# 11. Unbanning an IP Address

## Manual unban

```bash
sudo fail2ban-client set sshd unbanip 192.168.0.83
```

---

## Result

The banned IP was removed from the jail,
allowing SSH access again.

Verification:

```bash
sudo fail2ban-client status sshd
```

Example:

```text
Currently banned: 0
```

---

# 12. Key Takeaways

- Fail2Ban dynamically blocks malicious IP addresses
- SSH protection depends on proper jail configuration
- custom SSH ports must also be configured in Fail2Ban
- nftables is commonly used as the backend on modern Ubuntu systems
- brute-force testing is useful for validating security configurations
- Fail2Ban integrates well with hardened SSH environments
- manual unban operations are an important recovery mechanism
