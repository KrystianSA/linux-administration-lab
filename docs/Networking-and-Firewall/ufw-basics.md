# UFW Basics

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Installing and Enabling UFW](#2-installing-and-enabling-ufw)
- [3. Allowing SSH Connections](#3-allowing-ssh-connections)
- [4. Checking Firewall Status](#4-checking-firewall-status)
- [5. Understanding Default Firewall Behavior](#5-understanding-default-firewall-behavior)
- [6. Checking Listening Ports](#6-checking-listening-ports)
- [7. Understanding Listening Addresses](#7-understanding-listening-addresses)
- [8. Understanding ss Output](#8-understanding-ss-output)
- [9. Key Takeaways](#9-key-takeaways)

---

# 1. Introduction

UFW (Uncomplicated Firewall) is a simplified frontend for:
```text
iptables
```

It allows administrators to:
- manage firewall rules
- control incoming traffic
- control outgoing traffic
- secure exposed services

UFW is commonly used in:
- Linux servers
- VPS environments
- homelabs
- development infrastructure

---

# 2. Installing and Enabling UFW

## Enable UFW

```bash
sudo ufw enable
```

## Important Warning

```text
Command may disrupt existing ssh connections.
```

SSH access may be interrupted if:
- SSH port is not allowed before enabling UFW
- incorrect firewall rules are applied

---

# 3. Allowing SSH Connections

Before enabling UFW:
SSH access should be explicitly allowed.

## Example

```bash
sudo ufw allow 2222/tcp
```

## Breakdown

| Element | Meaning |
|---|---|
| allow | allow traffic |
| 2222 | SSH custom port |
| tcp | TCP protocol |

---

# 4. Checking Firewall Status

## Basic Status

```bash
sudo ufw status
```

---

## Verbose Status

```bash
sudo ufw status verbose
```

Example output:

```text
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing)
```

---

# 5. Understanding Default Firewall Behavior

By default:
UFW commonly uses the following policy:

| Direction | Default Behavior |
|---|---|
| Incoming | deny |
| Outgoing | allow |

## Meaning

### Incoming Traffic

```text
deny incoming
```

Blocks unsolicited incoming connections.

Example:
- external SSH attempts
- HTTP requests
- database access

---

### Outgoing Traffic

```text
allow outgoing
```

Allows the server to:
- access websites
- install packages
- communicate with external services

---

# 6. Checking Listening Ports

## Command

```bash
sudo ss -tulpn
```

This command displays:
- listening ports
- active sockets
- protocols
- listening addresses
- processes using ports

---

# 7. Understanding Listening Addresses

## Example

```text
0.0.0.0:2222
```

## Meaning

```text
listen on all local interfaces
```

The service accepts connections from:
- localhost
- LAN interfaces
- bridged interfaces
- external network interfaces

---

## Localhost Example

```text
127.0.0.1:2222
```

Meaning:
```text
service available only locally
```

---

# 8. Understanding ss Output

## Example

```text
tcp LISTEN 0 128 0.0.0.0:2222
```

---

## Column Breakdown

| Column | Meaning |
|---|---|
| tcp | transport protocol |
| LISTEN | service waiting for connections |
| Recv-Q | receive queue |
| Send-Q | send queue |
| Local Address | listening IP and port |
| Peer Address | remote endpoint |
| Process | process using the socket |

---

## Important Insight

Linux treats:
- sockets
- devices
- terminals
- pipes

similarly to files.

This is why sockets are associated with:
```text
file descriptors
```

---

# 9. Key Takeaways

- UFW simplifies Linux firewall management
- SSH access should be allowed before enabling UFW
- `ufw status` verifies firewall configuration
- `ss -tulpn` helps inspect listening services
- `0.0.0.0` means listening on all interfaces
- firewall rules operate on ports and protocols
- Linux networking is heavily socket-based
