# UFW Hardening

## Hardened Firewall Configuration

### Final UFW Policy

| Direction | Policy |
|---|---|
| Incoming | deny |
| Outgoing | deny |
| Routed | disabled |

---

### Allowed Traffic

| Rule | Purpose |
|---|---|
| 2222/tcp LIMIT IN from trusted IP | restricted SSH access |
| 443/tcp ALLOW OUT | HTTPS outbound traffic |

---

### Security Goals

The firewall configuration was designed to:
- restrict SSH access to a single trusted host
- block all unnecessary incoming traffic
- restrict outbound traffic
- reduce attack surface
- mitigate brute-force attempts
- simulate production-style firewall hardening

---

## Table of Contents

- [1. Restricting SSH Access by Source IP](#1-restricting-ssh-access-by-source-ip)
- [2. Removing Broad Firewall Rules](#2-removing-broad-firewall-rules)
- [3. Bridged Networking for Real LAN Testing](#3-bridged-networking-for-real-lan-testing)
- [4. Understanding Firewall Filtering Logic](#4-understanding-firewall-filtering-logic)
- [5. Default Deny Policies](#5-default-deny-policies)
- [6. Outbound Traffic Restrictions](#6-outbound-traffic-restrictions)
- [7. SSH Rate Limiting](#7-ssh-rate-limiting)
- [8. Real Device Testing](#8-real-device-testing)
- [9. Observed Behavior](#9-observed-behavior)
- [10. Key Takeaways](#10-key-takeaways)

---

# 1. Restricting SSH Access by Source IP

Initially:
SSH access was allowed from:
```text
Anywhere
```

This configuration was replaced with:
```text
single trusted source IP
```

---

## Checking Existing Rules

```bash
sudo ufw status numbered
```

---

## Removing Existing Rule

```bash
sudo ufw delete 1
```

---

## Adding Restricted SSH Rule

```bash
sudo ufw allow proto tcp from 192.168.0.83 to any port 2222
```

---

## Result

SSH access became available only from:
```text
trusted local machine
```

All other hosts were blocked by the firewall.

---

# 2. Removing Broad Firewall Rules

The original configuration:
```text
ALLOW Anywhere
```

was considered too permissive.

The goal of hardening was to:
- reduce exposure
- limit attack surface
- follow least privilege principles

---

# 3. Bridged Networking for Real LAN Testing

VirtualBox networking was changed from:
```text
NAT
```

to:
```text
Bridged Adapter
```

This allowed:
- real LAN communication
- realistic firewall testing
- external SSH validation

The VM received a real LAN address:

```text
192.168.0.84
```

---

# 4. Understanding Firewall Filtering Logic

UFW filters:
- source IP addresses
- destination ports
- protocols

UFW does not filter:
- Linux users
- local accounts
- shell sessions

---

## Important Observation

Connections initiated locally on the VM:
may bypass external firewall testing scenarios.

This was observed when:
- multiple Linux users on the same VM
- could still access local services

because:
the traffic originated from the same machine.

---

# 5. Default Deny Policies

## Incoming Policy

```bash
sudo ufw default deny incoming
```

Blocks:
- unsolicited incoming traffic
- unknown external connections

---

## Outgoing Policy

```bash
sudo ufw default deny outgoing
```

Restricts:
- outbound connections
- service communication
- external traffic

This configuration is significantly stricter than:
```text
default allow outgoing
```

---

# 6. Outbound Traffic Restrictions

Only HTTPS outbound traffic was explicitly allowed.

## Rule

```bash
sudo ufw allow out 443/tcp
```

---

## Purpose

Allows:
- HTTPS websites
- secure package downloads
- encrypted outbound communication

Blocks:
- unnecessary outbound traffic
- non-whitelisted ports

---

# 7. SSH Rate Limiting

The standard SSH allow rule was replaced with:
```text
LIMIT
```

---

## Removing Existing Rule

```bash
sudo ufw delete 1
```

---

## Adding Rate-Limited Rule

```bash
sudo ufw limit proto tcp from 192.168.0.83 to any port 2222
```

---

## Behavior

UFW automatically:
- monitors SSH connection attempts
- rate-limits repeated connections
- mitigates brute-force attempts

---

## Important Limitation

`ufw limit`
uses:
```text
fixed threshold behavior
```

Default behavior:
```text
6 attempts within 30 seconds
```

Granular tuning requires:
- iptables
- nftables
- fail2ban

---

# 8. Real Device Testing

Firewall rules were validated using:
- external LAN devices
- iPhone with Termius
- bridged network connectivity

---

## Result

Connection attempts from:
```text
non-whitelisted IP addresses
```

were successfully blocked.

---

# 9. Observed Behavior

## Key Findings

- firewall filtering operates on network traffic
- firewall rules are port-based
- local VM traffic behaves differently than external traffic
- outbound filtering is more restrictive than inbound filtering
- `default deny outgoing` can easily break system functionality
- bridged networking creates realistic infrastructure behavior

---

# 10. Key Takeaways

- source IP restriction significantly reduces SSH exposure
- default deny policies reduce attack surface
- outbound filtering increases security but requires careful planning
- `ufw limit` provides basic brute-force mitigation
- bridged networking improves realism in homelab environments
- firewall hardening should follow least privilege principles
- testing from external devices is critical for validation- [7. SSH Rate Limiting](#7-ssh-rate-limiting)
- [8. Real Device Testing](#8-real-device-testing)
- [9. Observed Behavior](#9-observed-behavior)
- [10. Key Takeaways](#10-key-takeaways)

---

# 1. Restricting SSH Access by Source IP

Initially:
SSH access was allowed from:
```text
Anywhere
```

This configuration was replaced with:
```text
single trusted source IP
```

---

## Checking Existing Rules

```bash
sudo ufw status numbered
```

---

## Removing Existing Rule

```bash
sudo ufw delete 1
```

---

## Adding Restricted SSH Rule

```bash
sudo ufw allow proto tcp from 192.168.0.83 to any port 2222
```

---

## Result

SSH access became available only from:
```text
trusted local machine
```

All other hosts were blocked by the firewall.

---

# 2. Removing Broad Firewall Rules

The original configuration:
```text
ALLOW Anywhere
```

was considered too permissive.

The goal of hardening was to:
- reduce exposure
- limit attack surface
- follow least privilege principles

---

# 3. Bridged Networking for Real LAN Testing

VirtualBox networking was changed from:
```text
NAT
```

to:
```text
Bridged Adapter
```

This allowed:
- real LAN communication
- realistic firewall testing
- external SSH validation

The VM received a real LAN address:

```text
192.168.0.84
```

---

# 4. Understanding Firewall Filtering Logic

UFW filters:
- source IP addresses
- destination ports
- protocols

UFW does not filter:
- Linux users
- local accounts
- shell sessions

---

## Important Observation

Connections initiated locally on the VM:
may bypass external firewall testing scenarios.

This was observed when:
- multiple Linux users on the same VM
- could still access local services

because:
the traffic originated from the same machine.

---

# 5. Default Deny Policies

## Incoming Policy

```bash
sudo ufw default deny incoming
```

Blocks:
- unsolicited incoming traffic
- unknown external connections

---

## Outgoing Policy

```bash
sudo ufw default deny outgoing
```

Restricts:
- outbound connections
- service communication
- external traffic

This configuration is significantly stricter than:
```text
default allow outgoing
```

---

# 6. Outbound Traffic Restrictions

Only HTTPS outbound traffic was explicitly allowed.

## Rule

```bash
sudo ufw allow out 443/tcp
```

---

## Purpose

Allows:
- HTTPS websites
- secure package downloads
- encrypted outbound communication

Blocks:
- unnecessary outbound traffic
- non-whitelisted ports

---

# 7. SSH Rate Limiting

The standard SSH allow rule was replaced with:
```text
LIMIT
```

---

## Removing Existing Rule

```bash
sudo ufw delete 1
```

---

## Adding Rate-Limited Rule

```bash
sudo ufw limit proto tcp from <ip> to any port 2222
```

---

## Behavior

UFW automatically:
- monitors SSH connection attempts
- rate-limits repeated connections
- mitigates brute-force attempts

---

## Important Limitation

`ufw limit`
uses:
```text
fixed threshold behavior
```

Default behavior:
```text
6 attempts within 30 seconds
```

Granular tuning requires:
- iptables
- nftables
- fail2ban

---

# 8. Real Device Testing

Firewall rules were validated using:
- external LAN devices
- iPhone with Termius
- bridged network connectivity

---

## Result

Connection attempts from:
```text
non-whitelisted IP addresses
```

were successfully blocked.

---

# 9. Observed Behavior

## Key Findings

- firewall filtering operates on network traffic
- firewall rules are port-based
- local VM traffic behaves differently than external traffic
- outbound filtering is more restrictive than inbound filtering
- `default deny outgoing` can easily break system functionality
- bridged networking creates realistic infrastructure behavior

---

# 10. Key Takeaways

- source IP restriction significantly reduces SSH exposure
- default deny policies reduce attack surface
- outbound filtering increases security but requires careful planning
- `ufw limit` provides basic brute-force mitigation
- bridged networking improves realism in homelab environments
- firewall hardening should follow least privilege principles
- testing from external devices is critical for validation
