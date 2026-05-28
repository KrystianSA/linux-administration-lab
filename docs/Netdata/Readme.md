# Netdata Monitoring Stack

Self-hosted real-time Linux monitoring stack deployed with Docker Compose and exposed through Nginx Reverse Proxy.

<img width="1842" height="870" alt="Zrzut ekranu 2026-05-28 o 12 48 54" src="https://github.com/user-attachments/assets/86873d1f-df4b-4fed-8429-93d42bac0872" />

---

# Project Overview

This deployment was created to provide full Linux telemetry monitoring for the homelab environment.

Monitoring responsibilities were separated:

| Tool | Purpose |
|---|---|
| Netdata | Linux system metrics and telemetry |

---

# Features

- Real-time Linux monitoring
- Dockerized deployment
- Host-level telemetry collection
- Reverse proxy integration
- Local DNS hostname
- Docker monitoring
- Filesystem monitoring
- Process monitoring
- CPU and RAM telemetry

---

# Architecture

text Browser ↓ Nginx Reverse Proxy ↓ 127.0.0.1:19999 ↓ Netdata Container ↓ Linux Host Metrics 

---

# Technologies Used

- Ubuntu Server
- Docker
- Docker Compose
- Nginx
- Netdata
- UFW
- VirtualBox
