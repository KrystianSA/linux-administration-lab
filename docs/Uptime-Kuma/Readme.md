# Uptime Kuma Monitoring Stack

Self-hosted monitoring stack deployed on Ubuntu Server using Docker Compose and Nginx Reverse Proxy.

---

# Project Overview

This project documents the deployment of Uptime Kuma in a Linux homelab environment.

The setup includes:

- Docker Compose deployment
- Persistent Docker volumes
- Nginx reverse proxy
- Local DNS resolution
- UFW firewall rules
- Localhost-only Docker port exposure
- Troubleshooting and networking analysis

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
