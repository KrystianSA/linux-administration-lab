# Security

## Table of Contents

- [Security Goals](#security-goals)
- [Localhost-only Docker Exposure](#localhost-only-docker-exposure)
- [Reverse Proxy as Public Entry Point](#reverse-proxy-as-public-entry-point)
- [UFW Firewall Rules](#ufw-firewall-rules)
- [Restricted SSH Access](#restricted-ssh-access)
- [Docker Container Isolation](#docker-container-isolation)
- [Persistent Volume Permissions](#persistent-volume-permissions)
- [UMASK Configuration](#umask-configuration)
- [Nginx Configuration Separation](#nginx-configuration-separation)
- [Security Observations](#security-observations)
- [Security Lessons Learned](#security-lessons-learned)

---

# Security Goals

The deployment was designed with the following goals:

- Reduce external attack surface
- Restrict direct container access
- Use reverse proxy as single public entrypoint
- Limit SSH exposure
- Separate active and inactive Nginx configurations
- Preserve persistent data securely

---

# Localhost-only Docker Exposure

The container was intentionally exposed only on localhost.

Docker Compose configuration:

```yaml
ports:
  - "127.0.0.1:3001:3001"
```

This prevents direct LAN access to the container.

Without localhost binding:

```yaml
3001:3001
```

the service would become reachable directly from the local network.

---

# Reverse Proxy as Public Entry Point

Nginx acted as the only public-facing service.

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

Benefits:

- Single controlled entrypoint
- Easier future TLS implementation
- Simplified traffic filtering
- Better isolation between services

---

# UFW Firewall Rules

Firewall rules were used to restrict access to exposed services.

Example SSH allow rule:

```bash
sudo ufw allow from 192.168.x.x to any port 2222 proto tcp
```

Observed UFW configuration concepts:

- allow specific IPs
- limit SSH brute force attempts
- restrict unnecessary inbound traffic

---

# Restricted SSH Access

SSH was configured on a non-default port:

```text
2222
```

Benefits:

- Reduced automated scanning noise
- Easier firewall separation
- Better visibility of intentional connections

Firewall restrictions were later added to limit SSH access to trusted devices only.

---

# Docker Container Isolation

The application container was isolated using:

- localhost-only binding
- Docker internal bridge networking
- reverse proxy routing

Observed internal Docker address:

```text
172.18.0.2
```

This address existed only inside the Docker bridge network.

---

# Persistent Volume Permissions

Persistent application data was stored outside the container:

```yaml
volumes:
  - /home/krystian/uptime-kuma/uptime-kuma-data:/app/data
```

Benefits:

- Data survives container recreation
- Easier backups
- Better file visibility
- Improved recovery options

---

# UMASK Configuration

Docker Compose configuration:

```yaml
- UMASK=0022
```

Purpose:

Control default file permissions created by the application.

Resulting permissions:

| Entity | Permissions |
|---|---|
| Owner | read/write |
| Group | read |
| Others | read |

Observed Linux behavior:

Default file creation starts from:

```text
666
```

then UMASK removes permissions.

Example:

```text
666 - 022 = 644
```

Directories typically start from:

```text
777
```

Example:

```text
777 - 022 = 755
```

---

# Nginx Configuration Separation

An important security and maintainability lesson was learned regarding Nginx configuration structure.

Incorrect configuration:

```nginx
include /etc/nginx/sites-available/*;
```

This caused backup files and inactive configurations to be loaded unintentionally.

Correct configuration:

```nginx
include /etc/nginx/sites-enabled/*;
```

Benefits:

- Only active configurations are loaded
- Backup files remain inactive
- Reduced configuration conflicts
- Cleaner operational model

---

# Security Observations

## Docker Networking

Docker containers may appear hidden even when services are technically reachable internally.

Observed behavior:

- TCP connection succeeded
- HTTP response failed
- Reverse proxy still functioned correctly

This highlighted the separation between:

- transport connectivity
- application-level behavior

---

## Reverse Proxy Isolation

Using reverse proxy significantly simplified service exposure.

Instead of exposing multiple applications directly:

```text
App → LAN
```

all traffic was centralized through:

```text
Browser
↓
Nginx
↓
Application
```

---

# Security Lessons Learned

- Localhost Docker binding significantly reduces exposure
- Reverse proxy should be the only public entrypoint
- UFW rules should be explicit and minimal
- SSH access should be restricted whenever possible
- `sites-enabled` is safer than loading all configurations
- Docker bridge networks provide useful isolation by default
- Persistent volumes require proper permission management
