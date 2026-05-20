# Nginx Reverse Proxy Basics

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Installing Nginx](#2-installing-nginx)
- [3. Verifying the Nginx Service](#3-verifying-the-nginx-service)
- [4. Initial Connectivity Problem](#4-initial-connectivity-problem)
- [5. UFW Firewall Rule](#5-ufw-firewall-rule)
- [6. Understanding Reverse Proxy Architecture](#6-understanding-reverse-proxy-architecture)
- [7. Docker Localhost Isolation](#7-docker-localhost-isolation)
- [8. Reverse Proxy Traffic Flow](#8-reverse-proxy-traffic-flow)
- [9. Security Benefits](#9-security-benefits)
- [10. Key Takeaways](#10-key-takeaways)

---

# 1. Introduction

This lab demonstrates:
- nginx installation
- reverse proxy concepts
- firewall troubleshooting
- Docker integration
- localhost-only container exposure
- secure service publishing

The goal was to understand:
how reverse proxies securely expose internal services.

---

# 2. Installing Nginx

## Install nginx

```bash
sudo apt install nginx -y
```

---

## Observation

The nginx package was successfully installed on:
the Ubuntu host system.

---

# 3. Verifying the Nginx Service

## Check nginx service status

```bash
systemctl status nginx
```

---

## Observation

The service status displayed:

```text
active (running)
```

This confirmed:
the nginx web server was operational.

---

# 4. Initial Connectivity Problem

The nginx service was not initially accessible from:
the local network.

Attempting to open:

```text
http://SERVER_IP
```

resulted in:
connection failure.

---

## Root Cause

The Linux firewall configuration used:
a default deny incoming policy.

Only SSH traffic on:
port 2222

was previously allowed.

---

# 5. UFW Firewall Rule

## Allow HTTP access from trusted machine

```bash
sudo ufw allow proto tcp from 192.168.0.83 to any port 80
```

---

## Rule Explanation

| Part | Meaning |
|---|---|
| proto tcp | TCP traffic |
| from 192.168.0.83 | trusted client IP |
| port 80 | HTTP service |

---

## Observation

After adding the firewall rule:
the nginx welcome page became accessible from:
the MacBook browser.

---

## Important Security Insight

Instead of exposing:
port 80 globally

the firewall rule restricted access to:
a specific trusted machine.

This represented:
a more secure network configuration.

---

# 6. Understanding Reverse Proxy Architecture

The environment used:
two separate nginx instances.

---

## Architecture Components

| Component | Role |
|---|---|
| Host nginx | reverse proxy |
| Docker nginx container | backend service |
| UFW | network access control |

---

## Important Observation

The Docker container itself was not publicly exposed.

Instead:
the host nginx server was intended to forward traffic to:
the internal Docker container.

---

# 7. Docker Localhost Isolation

The Docker container was intentionally configured using:
localhost-only binding.

---

## Example

```bash
docker run -d -p 127.0.0.1:8080:80 --name nginx-test nginx
```

---

## Important Insight

This configuration limited container exposure to:
the local Linux host only.

External machines could not directly access:
the container service.

---

## Validation

Accessible locally:

```bash
curl localhost:8080
```

Not accessible remotely:

```text
http://SERVER_IP:8080
```

---

# 8. Reverse Proxy Traffic Flow

The intended reverse proxy architecture:

```text
Browser
↓
Host nginx :80
↓
Reverse proxy forwarding
↓
localhost:8080
↓
Docker container :80
```

---

## Important Insight

The reverse proxy acts as:
an intermediary between:
external clients and internal services.

This architecture is commonly used for:
- Docker applications
- internal APIs
- monitoring systems
- self-hosted services
- backend applications

---

# 9. Security Benefits

The architecture improved security by:
- preventing direct container exposure
- limiting network attack surface
- centralizing external access
- controlling traffic through nginx
- integrating firewall restrictions

---

## Additional Observation

Docker networking can automatically expose services using:
iptables/nftables rules.

Restricting containers to:
localhost only

helps reduce unintended public exposure.

---

# 10. Key Takeaways

- nginx can operate as a reverse proxy
- UFW controls external network access
- Docker containers should not always be publicly exposed
- localhost-only binding improves security
- reverse proxies securely expose internal services
- firewall restrictions can limit trusted access
- Docker integrates deeply with Linux networking
- layered security improves infrastructure design
- reverse proxy architecture is widely used in production environments
