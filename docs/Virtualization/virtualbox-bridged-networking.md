# VirtualBox Bridged Networking

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. NAT vs Bridged Networking](#2-nat-vs-bridged-networking)
- [3. Why Bridged Networking Matters](#3-why-bridged-networking-matters)
- [4. Configuring Bridged Adapter](#4-configuring-bridged-adapter)
- [5. VirtualBox Network Parameters](#5-virtualbox-network-parameters)
- [6. Verifying Network Connectivity](#6-verifying-network-connectivity)
- [7. SSH Access Over LAN](#7-ssh-access-over-lan)
- [8. Key Takeaways](#8-key-takeaways)

---

# 1. Introduction

By default, VirtualBox virtual machines commonly use:
```text
NAT networking
```

In this mode:
- the VM has internet access
- the VM is hidden behind VirtualBox NAT
- direct LAN communication is limited

To simulate a more realistic server environment:
```text
Bridged Networking
```

was configured.

This allows the VM to:
- appear as a real device in the local network
- receive a real LAN IP address
- communicate directly with other devices

---

# 2. NAT vs Bridged Networking

| Mode | Behavior |
|---|---|
| NAT | VM hidden behind VirtualBox NAT |
| Bridged | VM visible directly in local network |

## NAT Networking

Characteristics:
- easy setup
- outbound internet access
- limited inbound connectivity
- commonly uses port forwarding

Example:
```text
ssh krystian@localhost -p 2222
```

---

## Bridged Networking

Characteristics:
- VM receives real LAN IP
- VM behaves like physical machine
- direct SSH access possible
- better for homelabs and server testing

Example:
```text
ssh krystian@<ip> -p 2222
```

---

# 3. Why Bridged Networking Matters

Bridged networking creates a more realistic infrastructure environment.

Benefits:
- realistic firewall testing
- LAN communication testing
- direct SSH administration
- service exposure validation
- network troubleshooting practice
- real-world server simulation

This approach is commonly used in:
- homelabs
- server labs
- virtualization environments
- infrastructure testing

---

# 4. Configuring Bridged Adapter

## Steps

### 1. Open VirtualBox Settings

```text
VirtualBox → Settings → Network
```

---

### 2. Change Adapter Mode

Changed:

```text
NAT
```

to:

```text
Bridged Adapter
```

---

### 3. Select Physical Interface

Selected:

```text
en0: Wi-Fi
```

This bridges the VM directly to the host Wi-Fi network.

---

# 5. VirtualBox Network Parameters

## Adapter Type

```text
Intel PRO/1000 MT Desktop (82540EM)
```

### Why

This adapter:
- is stable
- highly compatible
- commonly recommended for Linux guests

---

## Promiscuous Mode

```text
Deny
```

### Why

Promiscuous mode allows:
- packet sniffing
- visibility into third-party traffic

Not required for standard VM networking.

Commonly used for:
- Wireshark
- IDS/IPS
- penetration testing

---

## Virtual Cable Connected

```text
Enabled
```

### Why

Simulates:
```text
physical network cable connected
```

If disabled:
- the VM loses network connectivity

---

# 6. Verifying Network Connectivity

After booting the VM:
the network configuration was verified.

## Command

```bash
hostname -I
```

Alternative:

```bash
ip a
```

---

## Observed Result

```text
<ip>
```

## Analysis

The VM successfully:
- obtained a LAN IP address
- joined the local network
- became directly reachable from other devices

---

# 7. SSH Access Over LAN

## Previous NAT Access

```bash
ssh krystian@localhost -p 2222
```

---

## New Bridged Access

```bash
ssh krystian@<ip> -p 2222
```

## Important Insight

This configuration now behaves similarly to:
- a physical Linux server
- a remote VPS
- a homelab node

Firewall rules and networking behavior become:
- more realistic
- easier to troubleshoot
- closer to production environments

---

# 8. Key Takeaways

- bridged networking exposes the VM directly to the LAN
- the VM receives a real local IP address
- SSH access becomes more realistic
- bridged mode is better for homelab infrastructure
- firewall testing becomes meaningful
- VirtualBox networking can closely simulate real servers
- `hostname -I` and `ip a` help verify network configuration
