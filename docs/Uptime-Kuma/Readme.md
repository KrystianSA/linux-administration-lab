# Uptime Kuma Monitoring Stack

Self-hosted monitoring stack deployed on Ubuntu Server using Docker Compose and Nginx Reverse Proxy.

<img width="1921" height="515" alt="Zrzut ekranu 2026-05-28 o 11 40 01" src="https://github.com/user-attachments/assets/8de5186e-13f9-400c-9e8b-27e959033e4e" />

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
- [Configuration](configuration.md)

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
