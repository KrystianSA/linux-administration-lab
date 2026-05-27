# Deployment

This document describes the deployment process of Uptime Kuma using Docker Compose on Ubuntu Server.

---

# Goal

Deploy a self-hosted monitoring application with:

- Docker Compose
- Persistent storage
- Nginx reverse proxy
- UFW firewall protection
- Localhost-only Docker exposure

---

# Install Docker Compose

```bash
sudo apt install docker-compose-plugin -y
```

Verify installation:

```bash
docker compose version
```

---

# Docker Repository Cleanup

During installation, the following warning appeared:

```text
W: Target Packages (stable/binary-arm64/Packages) is configured multiple times in:
/etc/apt/sources.list.d/docker.list:1
and
/etc/apt/sources.list.d/docker.sources:1
```

The issue was caused by duplicate Docker repository definitions.

The newer `.sources` format was kept because it uses the modern Deb822 format.

Backup the old repository file:

```bash
sudo cp /etc/apt/sources.list.d/docker.list ~/backups/docker.list.backup
```

Remove duplicated repository:

```bash
sudo rm /etc/apt/sources.list.d/docker.list
```

Update package index:

```bash
sudo apt update
```

---

# Create Project Directory

```bash
mkdir -p ~/uptime-kuma
cd ~/uptime-kuma
```

---

# Create Docker Compose File

Create the compose file:

```bash
nano docker-compose.yml
```

---

# Docker Compose Configuration

```yaml
services:
  uptime-kuma:
    image: louislam/uptime-kuma:2
    container_name: uptime-kuma
    restart: always

    ports:
      - "127.0.0.1:3001:3001"

    volumes:
      - /home/krystian/uptime-kuma/uptime-kuma-data:/app/data

    environment:
      - TZ=Europe/Warsaw
      - UMASK=0022

    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001"]
      interval: 30s
      retries: 3
      start_period: 10s
      timeout: 5s

    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

---

# Configuration Decisions

## Localhost-only Port Exposure

```yaml
ports:
  - "127.0.0.1:3001:3001"
```

The container is exposed only to localhost.

Benefits:

- Prevents direct external access
- Forces traffic through reverse proxy
- Improves security
- Reduces attack surface

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

---

## Persistent Volumes

```yaml
volumes:
  - /home/krystian/uptime-kuma/uptime-kuma-data:/app/data
```

Persistent storage ensures:

- Monitoring configuration survives container recreation
- Database survives reboot
- Screenshots and uploads remain available

---

## UMASK Configuration

```yaml
- UMASK=0022
```

UMASK controls default file permissions created by the application.

Resulting permissions:

- Owner: read/write
- Group: read
- Others: read

---

# Start Container

```bash
docker compose up -d
```

---

# Verify Container Status

```bash
docker compose ps
```

View logs:

```bash
docker logs uptime-kuma
```

---

# Verify Port Binding

```bash
ss -tulpn | grep 3001
```

Expected result:

```text
127.0.0.1:3001 LISTEN
```

---

# Verify Local Access

From Ubuntu VM:

```bash
curl http://127.0.0.1:3001
```

---

# Observations

## Docker Networking

The container received an internal Docker bridge IP address:

```text
172.x.x.x
```

This IP address is internal to Docker and not directly accessible from the local network.

---

## Healthcheck Behavior

The container reported healthy status even before initial web setup was completed.

Observed log:

```text
Waiting for user action...
```

This indicates the application was waiting for first-time configuration in the browser.

---

# Next Step

The next stage of deployment was exposing the application securely using Nginx reverse proxy.
