# Uptime Kuma Monitoring Stack

Self-hosted monitoring stack deployed on Ubuntu Server using Docker Compose and Nginx Reverse Proxy.

---

# Project Overview

This project documents the deployment of Uptime Kuma in a Linux homelab environment.

The setup includes:

- [Docker Compose deployment](deployment.md)
- [Nginx reverse proxy](reverse-proxy.md)
- [Networking](networking.md)
- [Security](security.md)
- [Troubleshooting analysis](troubleshooting.md)
- [Docker Compose](docker-compose.yml)

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
