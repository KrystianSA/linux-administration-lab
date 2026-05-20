# Docker Networking and Port Forwarding

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Running an Nginx Container](#2-running-an-nginx-container)
- [3. Docker Port Forwarding](#3-docker-port-forwarding)
- [4. Container Networking Basics](#4-container-networking-basics)
- [5. Testing Container Connectivity](#5-testing-container-connectivity)
- [6. Docker and Firewall Behavior](#6-docker-and-firewall-behavior)
- [7. nftables and Docker Rules](#7-nftables-and-docker-rules)
- [8. Restricting Container Exposure](#8-restricting-container-exposure)
- [9. Localhost Binding Security](#9-localhost-binding-security)
- [10. Key Takeaways](#10-key-takeaways)

---

# 1. Introduction

This lab demonstrates:
- Docker networking basics
- container port forwarding
- Docker bridge networking
- nftables integration
- localhost-only binding
- container exposure security

The goal was to understand:
how Docker exposes services and modifies Linux networking behavior.

---

# 2. Running an Nginx Container

## Start nginx container

```bash
docker run -d -p 8080:80 --name nginx-test nginx
```

---

## Command Breakdown

| Part | Meaning |
|---|---|
| docker run | create container |
| -d | detached/background mode |
| -p 8080:80 | host-to-container port mapping |
| --name nginx-test | custom container name |
| nginx | Docker image |

---

## Observation

Docker automatically:
- downloaded the nginx image
- created the container
- started nginx
- exposed the service on port 8080

---

# 3. Docker Port Forwarding

## Port Mapping Format

```text
HOST_PORT:CONTAINER_PORT
```

Example:

```text
8080:80
```

Meaning:

| Port | Description |
|---|---|
| 8080 | Linux host port |
| 80 | nginx port inside the container |

---

## Traffic Flow

```text
Browser
↓
Linux Host :8080
↓
Docker Port Forwarding
↓
Container :80
↓
nginx
```

---

## Important Insight

Containers operate inside:
their own isolated network namespaces.

The nginx container internally listens only on:
port 80.

Docker performs:
the forwarding between:
the host and container.

---

# 4. Container Networking Basics

Docker automatically creates:
virtual networking components.

---

## Example Components

| Component | Purpose |
|---|---|
| docker0 | Docker bridge interface |
| 172.17.0.x | container IP range |
| NAT rules | traffic forwarding |

---

## Observation

The nginx container received:
its own private IP address.

Example:

```text
172.17.0.2
```

---

# 5. Testing Container Connectivity

## Verify running container

```bash
docker ps
```

---

## Local validation

```bash
curl localhost:8080
```

This returned:
the nginx HTML page.

---

## Remote validation

The service was also accessible from:
another machine on the network.

Example:

```text
http://SERVER_IP:8080
```

---

# 6. Docker and Firewall Behavior

The Linux firewall configuration only allowed:
SSH access on port 2222.

Despite this:
the nginx service on port 8080 was still reachable.

---

## Important Observation

Docker automatically created:
its own nftables/iptables rules.

This behavior bypassed:
expected UFW restrictions.

---

## Security Insight

Docker networking may expose services even when:
the administrator expects the firewall to block them.

This is an important:
real-world operational and security consideration.

---

# 7. nftables and Docker Rules

## Display nftables rules

```bash
sudo nft list ruleset
```

---

## Example Rule

```text
iifname != "docker0" tcp dport 8080 dnat to 172.17.0.2:80
```

---

## Rule Analysis

| Part | Meaning |
|---|---|
| tcp dport 8080 | incoming traffic on port 8080 |
| dnat | destination NAT |
| 172.17.0.2 | container IP address |
| :80 | nginx port inside the container |

---

## Important Insight

Docker dynamically modifies:
Linux networking rules using:
iptables/nftables integration.

---

# 8. Restricting Container Exposure

The original container exposed:
port 8080 publicly.

To improve security:
the container was recreated using:
localhost-only binding.

---

## Stop and remove container

```bash
docker stop nginx-test
docker rm nginx-test
```

---

## Create localhost-only container

```bash
docker run -d -p 127.0.0.1:8080:80 --name nginx-test nginx
```

---

# 9. Localhost Binding Security

## Observation

After binding to:
`127.0.0.1`

the service:
- remained accessible locally
- was no longer reachable from external machines

---

## Validation

Working locally:

```bash
curl localhost:8080
```

No longer accessible remotely:

```text
http://SERVER_IP:8080
```

---

## Important Security Insight

Binding services to:
localhost only

is a common production security practice.

This pattern is frequently used for:
- internal APIs
- monitoring dashboards
- databases
- backend services
- containers behind reverse proxies

---

## Additional Insight

By default:

```bash
-p 8080:80
```

binds to:

```text
0.0.0.0
```

Meaning:
all network interfaces.

Using:

```bash
-p 127.0.0.1:8080:80
```

limits exposure to:
localhost only.

---

# 10. Key Takeaways

- Docker automatically creates networking rules
- Containers operate inside isolated network namespaces
- Docker uses NAT and bridge networking
- Port forwarding exposes container services on the host
- Docker may bypass expected UFW behavior
- nftables dynamically reflects Docker networking changes
- Public container exposure should be intentional
- Localhost-only binding improves security
- Reverse proxies are commonly used to securely expose local services
- Docker networking integrates deeply with Linux networking subsystems