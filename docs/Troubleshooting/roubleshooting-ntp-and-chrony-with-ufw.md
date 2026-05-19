# Troubleshooting NTP and Chrony with UFW

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Initial Problem](#2-initial-problem)
- [3. Verifying Timezone](#3-verifying-timezone)
- [4. Investigating Time Synchronization](#4-investigating-time-synchronization)
- [5. Discovering Chrony](#5-discovering-chrony)
- [6. Root Cause Analysis](#6-root-cause-analysis)
- [7. Understanding NTP and NTS](#7-understanding-ntp-and-nts)
- [8. Fixing UFW Rules](#8-fixing-ufw-rules)
- [9. Verifying Synchronization](#9-verifying-synchronization)
- [10. Key Takeaways](#10-key-takeaways)

---

# 1. Introduction

This troubleshooting scenario focused on:
- timezone configuration
- time synchronization
- outbound firewall restrictions
- Chrony and NTP troubleshooting

---

# 2. Initial Problem

The timezone was configured correctly:

```bash
sudo timedatectl set-timezone Europe/Warsaw
```

However:
system time was still incorrect.

---

# 3. Verifying Timezone

## Checking time configuration

```bash
timedatectl
```

Observed output:

```text
Time zone: Europe/Warsaw
System clock synchronized: no
```

This confirmed:
- timezone was correct
- synchronization was failing

---

# 4. Investigating Time Synchronization

An attempt was made to verify:

```bash
sudo systemctl status systemd-timesyncd
```

Result:

```text
Unit systemd-timesyncd.service could not be found
```

This indicated:
the system was not using `systemd-timesyncd`.

---

# 5. Discovering Chrony

## Checking Chrony

```bash
sudo systemctl status chronyd
```

Chrony was installed and active.

Further inspection revealed:
the system relied on:
- Chrony
- NTP
- NTS

for time synchronization.

---

# 6. Root Cause Analysis

The system used:
a strict outbound firewall policy:

```text
deny outgoing
```

This blocked:
required NTP and NTS traffic.

---

# 7. Understanding NTP and NTS

## NTP

| Protocol | Port |
|---|---|
| UDP | 123 |

---

## NTS

NTS stands for:

```text
Network Time Security
```

NTS adds:
secure negotiation and authentication to NTP.

Observed configuration note:

```text
NTS uses an additional port to negotiate security: 4460/tcp
```

---

# 8. Fixing UFW Rules

## Allow NTP traffic

```bash
sudo ufw allow out 123/udp
```

---

## Allow NTS negotiation traffic

```bash
sudo ufw allow out 4460/tcp
```

---

## Restart Chrony

```bash
sudo systemctl restart chronyd
```

---

# 9. Verifying Synchronization

## Check synchronization status

```bash
chronyc tracking
```

Expected result:

```text
Leap status : Normal
```

---

## Verify system time

```bash
date
```

After allowing the required traffic:
time synchronization started functioning correctly.

---

# 10. Key Takeaways

- Timezone configuration and clock synchronization are separate concepts
- Linux systems may use Chrony instead of systemd-timesyncd
- Strict outbound firewall policies can break critical services
- NTP requires UDP 123
- NTS may require additional negotiation ports
- Troubleshooting often requires:
  - log analysis
  - protocol awareness
  - dependency analysis
- Security hardening can unintentionally disrupt system functionality
