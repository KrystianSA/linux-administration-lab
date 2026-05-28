# Configuration

<img width="1910" height="978" alt="Zrzut ekranu 2026-05-28 o 12 40 39" src="https://github.com/user-attachments/assets/c5ece12f-5aaf-46cc-a218-5e99d55cec97" />

---

# Deployment Goal

The deployment was designed to provide full Linux telemetry monitoring inside the homelab environment.

The stack complements Uptime Kuma by providing infrastructure-level visibility instead of endpoint-only monitoring.

---

# Docker Compose Deployment

Create project directory:

bash mkdir netdata cd netdata 

Create compose file:

bash nano docker-compose.yml 

Start container:

bash docker compose up -d 

---

# Netdata Docker Compose Configuration

yaml version: '3'  services:   netdata:     image: netdata/netdata     container_name: netdata      pid: host     network_mode: host      restart: unless-stopped      cap_add:       - SYS_PTRACE       - SYS_ADMIN      security_opt:       - apparmor:unconfined      volumes:       - netdataconfig:/etc/netdata       - netdatalib:/var/lib/netdata       - netdatacache:/var/cache/netdata        - /:/host/root:ro,rslave       - /etc/passwd:/host/etc/passwd:ro       - /etc/group:/host/etc/group:ro       - /etc/localtime:/etc/localtime:ro       - /proc:/host/proc:ro       - /sys:/host/sys:ro       - /etc/os-release:/host/etc/os-release:ro       - /var/log:/host/var/log:ro       - /var/run/docker.sock:/var/run/docker.sock:ro       - /run/dbus:/run/dbus:ro  volumes:   netdataconfig:   netdatalib:   netdatacache: 

---

# Host Networking

The container used:

yaml network_mode: host 

Purpose:

- direct access to Linux networking stack
- host-level telemetry visibility
- simplified metrics collection
- reduced networking overhead

This allowed Netdata to monitor the host directly instead of operating inside an isolated Docker bridge network.

---

# Host System Access

Multiple Linux system paths were mounted into the container.

Examples:

yaml - /proc:/host/proc:ro - /sys:/host/sys:ro - /var/log:/host/var/log:ro 

Purpose:

- process monitoring
- filesystem telemetry
- Linux metrics collection
- Docker visibility
- infrastructure monitoring

Most mounts were configured as read-only.

---

# Reverse Proxy Configuration

Netdata was exposed through Nginx reverse proxy.

Create configuration file:

bash sudo nano /etc/nginx/sites-available/netdata-reverse-proxy 

Nginx configuration:

nginx server {     listen 80;      server_name netdata.local;      location / {         proxy_pass http://127.0.0.1:19999;          proxy_set_header Host $host;         proxy_set_header X-Real-IP $remote_addr;     } } 

Enable configuration:

bash sudo ln -s /etc/nginx/sites-available/netdata-reverse-proxy /etc/nginx/sites-enabled/ 

Test configuration:

bash sudo nginx -t 

Reload Nginx:

bash sudo systemctl reload nginx 

---

# Local DNS Configuration

A local hostname was configured inside:

bash /etc/hosts 

Example:

text 192.168.x.x netdata.local 

This allowed browser access through:

text http://netdata.local 

---

# Monitoring Scope

Netdata was used for:

- CPU monitoring
- RAM monitoring
- disk usage
- process monitoring
- Docker metrics
- filesystem telemetry
- network activity

The deployment complements Uptime Kuma which was focused only on endpoint availability monitoring.

---

# Security Considerations

The deployment required elevated container permissions.

Examples:

yaml pid: host SYS_ADMIN SYS_PTRACE 

This was necessary to collect detailed Linux telemetry.

Security-related decisions included:

- reverse proxy as single entrypoint
- local DNS usage
- read-only mounts where possible
- separated monitoring layers

---
