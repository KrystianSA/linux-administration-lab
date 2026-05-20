# Exposing Local Containers Securely with Nginx Reverse Proxy

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Goal](#2-goal)
- [3. Reverse Proxy Configuration](#3-reverse-proxy-configuration)
- [4. Nginx Variables](#4-nginx-variables)
- [5. Enabling the Configuration](#5-enabling-the-configuration)
- [6. Configuration Validation](#6-configuration-validation)
- [7. Nginx Default Site Conflict](#7-nginx-default-site-conflict)
- [8. Troubleshooting the Reverse Proxy](#8-troubleshooting-the-reverse-proxy)
- [9. Reverse Proxy Validation](#9-reverse-proxy-validation)
- [10. Final Architecture](#10-final-architecture)
- [11. Security Benefits](#11-security-benefits)
- [12. Key Takeaways](#12-key-takeaways)

---

# 1. Introduction

This lab demonstrates:
- nginx reverse proxy configuration
- exposing localhost-only Docker containers
- enabling nginx virtual hosts
- troubleshooting nginx conflicts
- validating reverse proxy behavior
- secure service exposure

The goal was to:
securely expose a local Docker container using:
nginx reverse proxy.

---

# 2. Goal

The Docker container was intentionally bound to:
localhost only.

Example:

```bash
docker run -d -p 127.0.0.1:8080:80 --name nginx-test nginx
```

This prevented:
direct external access to the container.

The objective was:
to expose the container securely through:
host nginx.

---

# 3. Reverse Proxy Configuration

## Create new nginx configuration

```bash
sudo nano /etc/nginx/sites-available/docker-reverse-proxy
```

---

## Configuration Content

```nginx
server {
    listen 80;

    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## Configuration Breakdown

| Directive | Purpose |
|---|---|
| listen 80 | listen for HTTP traffic |
| server_name _ | catch-all virtual host |
| proxy_pass | forward requests to Docker container |
| Host $host | preserve original hostname |
| X-Real-IP $remote_addr | preserve client IP |

---

# 4. Nginx Variables

Nginx includes:
built-in variables used during request processing.

---

## Variables Used

| Variable | Meaning |
|---|---|
| $host | original hostname from client request |
| $remote_addr | client IP address |

---

## Important Insight

Without:
`X-Real-IP`

the backend service would only see:
the reverse proxy IP.

Forwarding the real client IP is:
a common reverse proxy practice.

---

# 5. Enabling the Configuration

Nginx uses:
two important directories.

| Directory | Purpose |
|---|---|
| sites-available | stored configurations |
| sites-enabled | active configurations |

---

## Create symbolic link

```bash
sudo ln -s /etc/nginx/sites-available/docker-reverse-proxy /etc/nginx/sites-enabled/
```

---

## Important Insight

Creating the configuration file alone:
does not activate the site.

Nginx only loads:
configurations present in:
`sites-enabled`.

---

# 6. Configuration Validation

## Test nginx configuration

```bash
sudo nginx -t
```

---

## Successful Result

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

---

## Reload nginx

```bash
sudo systemctl reload nginx
```

---

# 7. Nginx Default Site Conflict

A warning appeared during:
configuration validation.

Example:

```text
conflicting server name "_" on 0.0.0.0:80
```

---

## Root Cause

Ubuntu nginx installation already included:
the default nginx site.

Both configurations attempted to use:

```nginx
server_name _;
```

This created:
a virtual host conflict.

---

## Existing Files

```bash
ls -la /etc/nginx/sites-enabled/
```

Output included:
the default nginx site.

---

## Backup Existing Configuration

```bash
sudo cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.backup
```

---

## Remove Default Site

```bash
sudo rm /etc/nginx/sites-enabled/default
```

---

## Important Insight

Creating a backup before:
removing configuration files

is a safer administrative practice.

---

# 8. Troubleshooting the Reverse Proxy

Initially:
the reverse proxy appeared functional.

However:
the Docker container and host nginx displayed:
the same nginx welcome page.

This made validation difficult.

---

## Troubleshooting Method

The Docker container was intentionally stopped.

```bash
docker stop nginx-test
```

---

## Result

The browser displayed:

```text
502 Bad Gateway
```

---

## Important Insight

This confirmed:
requests were truly passing through:
the nginx reverse proxy.

Traffic flow:

```text
Browser
↓
Host nginx
↓
proxy_pass
↓
localhost:8080
↓
Docker container
```

When the backend container stopped:
the reverse proxy could no longer reach:
the upstream service.

---

# 9. Reverse Proxy Validation

## Start container again

```bash
docker start nginx-test
```

---

## Result

The nginx welcome page returned successfully.

This confirmed:
the reverse proxy architecture was fully operational.

---

# 10. Final Architecture

```text
MacBook Browser
↓
Host nginx :80
↓
proxy_pass
↓
127.0.0.1:8080
↓
Docker nginx container
```

---

## Important Observation

The Docker container itself:
was never publicly exposed.

Only:
the nginx reverse proxy accepted:
external traffic.

---

# 11. Security Benefits

This architecture improved security by:
- hiding internal container services
- preventing direct container exposure
- centralizing public access
- allowing firewall control on nginx
- reducing accidental exposure risks

---

## Additional Insight

This architecture is commonly used for:
- Grafana
- Portainer
- Gitea
- monitoring dashboards
- internal APIs
- self-hosted services

---

# 12. Key Takeaways

- nginx can securely expose local containers
- reverse proxies forward traffic to backend services
- localhost-only binding improves security
- symbolic links activate nginx virtual hosts
- nginx configurations should always be validated
- default nginx sites may create conflicts
- 502 Bad Gateway can help validate reverse proxy behavior
- backups should be created before removing configurations
- reverse proxies are widely used in production environments
- Docker and nginx integrate closely with Linux networking
