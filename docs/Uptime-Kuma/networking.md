# Networking

## Table of Contents

- [Docker Port Binding](#docker-port-binding)
- [Localhost-only Exposure](#localhost-only-exposure)
- [Docker Internal Networking](#docker-internal-networking)
- [Docker Bridge IP Addresses](#docker-bridge-ip-addresses)
- [Container Traffic Flow](#container-traffic-flow)
- [Reverse Proxy Traffic Flow](#reverse-proxy-traffic-flow)
- [VirtualBox NAT Networking](#virtualbox-nat-networking)
- [Port Forwarding in NAT Mode](#port-forwarding-in-nat-mode)
- [NAT vs Bridged Adapter](#nat-vs-bridged-adapter)
- [IPv4 Failure on Bridged Adapter](#ipv4-failure-on-bridged-adapter)
- [Local DNS Resolution](#local-dns-resolution)
- [Networking Lessons Learned](#networking-lessons-learned)

---

# Docker Port Binding

Docker port binding maps a container port to the host operating system.

Example:

```yaml
ports:
  - "127.0.0.1:3001:3001"
```

Meaning:

| Host | Container |
|---|---|
| 127.0.0.1:3001 | 3001 |

---

# Localhost-only Exposure

The application was intentionally bound only to localhost.

```yaml
127.0.0.1:3001:3001
```

Benefits:

- Container hidden from LAN
- Reduced attack surface
- Traffic forced through reverse proxy
- Better access control

Without localhost binding:

```yaml
3001:3001
```

the application would become reachable directly from the network.

---

# Docker Internal Networking

Docker automatically creates an internal bridge network.

Containers receive private internal IP addresses.

Example:

```text
172.x.x.x
```

These addresses are internal to Docker and are not directly reachable from the local network.

---

# Docker Bridge IP Addresses

Observed container addresses included:

```text
172.18.0.2
```

This address existed only inside the Docker bridge network.

Traffic path:

```text
Ubuntu Host
↓
Docker Bridge Network
↓
Container
```

---

# Container Traffic Flow

Direct container communication:

```text
Host
↓
127.0.0.1:3001
↓
Docker Port Forwarding
↓
Container:3001
```

---

# Reverse Proxy Traffic Flow

Final deployment architecture:

```text
Browser
↓
Nginx Reverse Proxy
↓
127.0.0.1:3001
↓
Docker Container
```

The container itself remained inaccessible externally.

---

# VirtualBox NAT Networking

When VirtualBox NAT mode is enabled:

```text
MacBook
↓
VirtualBox NAT Router
↓
Ubuntu VM
```

The VM exists behind an internal NAT network.

The VM can access the internet, but external devices cannot directly initiate inbound connections.

---

# Port Forwarding in NAT Mode

To access SSH inside the VM, VirtualBox port forwarding was required.

Example:

| Setting | Value |
|---|---|
| Host IP | 127.0.0.1 |
| Host Port | 2222 |
| Guest Port | 2222 |

SSH flow:

```text
MacBook
↓
127.0.0.1:2222
↓
VirtualBox Port Forwarding
↓
Ubuntu VM:2222
```

---

# NAT vs Bridged Adapter

## NAT

Advantages:

- Simple configuration
- Better isolation
- Safer default behavior

Disadvantages:

- Requires port forwarding
- VM hidden behind NAT

---

## Bridged Adapter

Advantages:

- VM receives LAN IP address
- Direct access from local network
- More realistic network behavior

Disadvantages:

- Depends heavily on physical network
- More sensitive to router and WiFi issues

---

# IPv4 Failure on Bridged Adapter

A networking issue appeared after upgrading macOS Tahoe 26.5.

Observed behavior:

| Network Source | IPv4 |
|---|---|
| Phone hotspot | Working |
| Main router | Working |
| WiFi extender | Failed |

The VM received only IPv6 addresses while connected through the WiFi extender.

Possible causes:

- DHCP forwarding issues
- VirtualBox bridge instability
- WiFi extender limitations
- macOS networking changes

Observed result:

```text
IPv6 only
```

instead of:

```text
192.168.x.x
```

---

# Local DNS Resolution

The hostname:

```text
kuma.local
```

was created locally using:

```bash
/etc/hosts
```

Example entry:

```text
192.168.x.x kuma.local
```

This allowed browser access using:

```text
http://kuma.local
```

instead of raw IP addresses.

---

# Networking Lessons Learned

- Docker bridge addresses are internal only
- Localhost binding improves container security
- Reverse proxy simplifies application exposure
- VirtualBox NAT requires port forwarding
- Bridged networking depends on external infrastructure
- WiFi extenders can interfere with DHCP and bridge networking
- Local DNS improves homelab usability
