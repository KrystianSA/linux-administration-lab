# Uptime Kuma Monitoring Stack

Self-hosted monitoring stack deployed on Ubuntu Server using Docker Compose and Nginx Reverse Proxy.

---

# Project Overview

This project documents the deployment of Uptime Kuma in a Linux homelab environment.

The setup includes:

- [Docker Compose deployment](docs/Uptime-Kuma/deployment.md)
- [Nginx reverse proxy](docs/Uptime-Kuma/reverse.proxy.md)
- [Networking](docs/Uptime-Kuma/networking)
- [Security](docs/Uptime-Kuma/security.md)
- [Troubleshooting analysis](docs/Uptime-Kuma/troubleshooting.md)
- [Docker Compose](docs/Uptime-Kuma/docker-compose.yml)

---

# Architecture

```text
Browser
↓
Nginx Reverse Proxy
↓
127.0.0.1:3001
↓
Docker Container (Uptime Kuma)
