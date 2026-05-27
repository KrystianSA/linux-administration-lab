# Troubleshooting

## Table of Contents

- [Duplicate Docker Repository Warning](#duplicate-docker-repository-warning)
- [Docker Compose File Not Found](#docker-compose-file-not-found)
- [Duplicate default_server in Nginx](#duplicate-default_server-in-nginx)
- [Multiple Applications Behind Reverse Proxy](#multiple-applications-behind-reverse-proxy)
- [Docker Localhost Access Confusion](#docker-localhost-access-confusion)
- [SSH Connection Reset](#ssh-connection-reset)
- [IPv4 Failure on VirtualBox VM](#ipv4-failure-on-virtualbox-vm)
- [VirtualBox NAT Networking Confusion](#virtualbox-nat-networking-confusion)
- [Boot Hang on systemd-networkd-wait-onlineservice](#boot-hang-on-systemd-networkd-wait-onlineservice)
- [Lessons Learned](#lessons-learned)

---

# Duplicate Docker Repository Warning

## Problem

During package updates, the following warning appeared:

```text
W: Target Packages (stable/binary-arm64/Packages) is configured multiple times in:
/etc/apt/sources.list.d/docker.list:1
and
/etc/apt/sources.list.d/docker.sources:1
```

---

## Cause

Docker repository was configured twice:

- legacy `.list` format
- modern `.sources` format

---

## Solution

The newer Deb822 `.sources` format was kept.

Backup old file:

```bash
sudo cp /etc/apt/sources.list.d/docker.list ~/backups/docker.list.backup
```

Remove duplicated repository:

```bash
sudo rm /etc/apt/sources.list.d/docker.list
```

Update repositories:

```bash
sudo apt update
```

---

# Docker Compose File Not Found

## Problem

Docker Compose returned:

```text
no configuration file provided
```

---

## Cause

Compose file was incorrectly named:

```text
docker.compose.yml
```

Instead of:

```text
docker-compose.yml
```

---

## Solution

Rename the file:

```bash
mv docker.compose.yml docker-compose.yml
```

---

# Duplicate default_server in Nginx

## Problem

Nginx failed with:

```text
duplicate default server
```

---

## Cause

Nginx loaded all files from:

```nginx
include /etc/nginx/sites-available/*;
```

This included:

- active configurations
- backup files
- old configurations

---

## Solution

Use the standard Ubuntu layout:

```nginx
include /etc/nginx/sites-enabled/*;
```

This ensures only enabled configurations are loaded.

---

# Multiple Applications Behind Reverse Proxy

## Problem

Two reverse proxy configurations attempted to handle the same traffic.

Both configurations contained:

```nginx
server_name _;
```

---

## Cause

`server_name _;` acts as a catch-all virtual host.

Multiple catch-all configurations caused routing conflicts.

---

## Solution

Assign separate hostnames:

```nginx
server_name kuma.local;
server_name app.local;
```

Add matching local DNS entries in `/etc/hosts`.

---

# Docker Localhost Access Confusion

## Problem

The application was accessible through reverse proxy but not directly from another machine.

---

## Cause

Docker port binding used localhost-only exposure:

```yaml
127.0.0.1:3001:3001
```

This restricts access to the VM itself.

---

## Explanation

Traffic flow:

```text
Browser
↓
Nginx Reverse Proxy
↓
127.0.0.1:3001
↓
Docker Container
```

The container is intentionally hidden from the local network.

---

# SSH Connection Reset

## Problem

SSH connections failed with:

```text
kex_exchange_identification
Connection reset by peer
```

---

## Cause

The issue was related to networking and firewall behavior rather than SSH keys.

Observed causes included:

- incorrect UFW rules
- VirtualBox networking instability
- WiFi extender networking issues

---

## Solution

Verify SSH service:

```bash
sudo systemctl status ssh
```

Verify listening ports:

```bash
sudo ss -tulpn | grep 2222
```

Verify firewall rules:

```bash
sudo ufw status numbered
```

Add explicit allow rule:

```bash
sudo ufw allow from 192.168.x.x to any port 2222 proto tcp
```

---

# IPv4 Failure on VirtualBox VM

## Problem

The VM received only IPv6 addresses while connected through a WiFi extender.

---

## Observation

Behavior depended on network topology:

| Network Source | IPv4 |
|---|---|
| Phone hotspot | Working |
| Main router | Working |
| WiFi extender | Failed |

---

## Cause

The issue appeared after updating macOS Tahoe 26.5.

Likely causes:

- VirtualBox bridge instability
- DHCP forwarding issues
- WiFi extender limitations
- macOS networking changes

---

## Result

The VM received:

```text
IPv6 only
```

Instead of:

```text
192.168.x.x
```

---

# VirtualBox NAT Networking Confusion

## Problem

The VM container received addresses such as:

```text
10.0.2.x
```

or:

```text
172.x.x.x
```

but these addresses were not reachable directly from the host machine.

---

## Explanation

These addresses belong to:

- VirtualBox NAT internal network
- Docker bridge network

They are private internal networks and require:

- NAT translation
- port forwarding
- reverse proxy

---

# Boot Hang on systemd-networkd-wait-online.service

## Problem

The VM occasionally froze during boot.

Observed service:

```text
systemd-networkd-wait-online.service
```

---

## Cause

System boot waited indefinitely for network initialization.

This behavior became more visible after networking instability caused by the WiFi extender.

---

## Solution Option 1

Add timeout:

```bash
sudo nano /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service
```

Modify:

```text
ExecStart=/lib/systemd/systemd-networkd-wait-online --timeout=5
```

Reboot system:

```bash
sudo reboot
```

---

## Solution Option 2

Disable the service entirely:

```bash
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service
```

---

# Lessons Learned

- Reverse proxy simplifies local service exposure
- Localhost Docker binding improves security
- Nginx should load only enabled configurations
- WiFi extenders can break bridged networking
- Docker bridge addresses are not directly routable
- Networking issues are often external to Linux itself
