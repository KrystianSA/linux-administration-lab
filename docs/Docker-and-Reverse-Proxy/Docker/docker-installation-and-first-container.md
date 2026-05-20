# Docker Installation and First Container

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Updating the System](#2-updating-the-system)
- [3. Installing Docker Engine](#3-installing-docker-engine)
- [4. Verifying Docker Service](#4-verifying-docker-service)
- [5. Docker Architecture Basics](#5-docker-architecture-basics)
- [6. Running the First Container](#6-running-the-first-container)
- [7. Understanding Containers](#7-understanding-containers)
- [8. Docker Permissions and Groups](#8-docker-permissions-and-groups)
- [9. Useful Docker Commands](#9-useful-docker-commands)
- [10. Docker Information Analysis](#10-docker-information-analysis)
- [11. Key Takeaways](#11-key-takeaways)

---

# 1. Introduction

This lab demonstrates:
- Docker Engine installation
- official Docker repository configuration
- Docker service verification
- first container deployment
- Docker permissions management
- basic container analysis

The goal was to understand:
how Docker operates on a Linux system.

---

# 2. Updating the System

## Update package lists

```bash
sudo apt update
```

---

## Observation

The system successfully refreshed:
APT repositories and available package information.

Example:

```text
5 packages can be upgraded
```

This confirmed:
the system package manager was functioning correctly.

---

# 3. Installing Docker Engine

Docker was installed using:
the official Docker installation method.

Documentation used:

https://docs.docker.com/engine/install/ubuntu/

---

## Installation Process

The following steps were completed:
- configured Docker apt repository
- added Docker signing key
- installed Docker Engine packages
- installed Docker CLI
- installed Docker Compose plugin

---

## Installed Components

| Component | Purpose |
|---|---|
| Docker Engine | container runtime |
| Docker CLI | command line management |
| containerd | container runtime backend |
| Docker Compose | multi-container management |

---

# 4. Verifying Docker Service

## Verify Docker daemon status

```bash
sudo systemctl status docker
```

---

## Verify Docker version

```bash
docker version
```

---

## Observation

The output confirmed:
- Docker client was installed
- Docker daemon was running
- Docker Engine version was active

Example:

```text
Server Version: 29.5.1
```

---

# 5. Docker Architecture Basics

Docker consists of:
multiple components working together.

---

## Core Components

| Component | Role |
|---|---|
| Docker Client | command line interface |
| Docker Daemon (`dockerd`) | manages containers |
| containerd | runtime backend |
| Image | container template |
| Container | running isolated process |

---

## Important Insight

Containers are:
isolated Linux processes.

When the process exits:
the container stops.

---

# 6. Running the First Container

## Run test container

```bash
docker run hello-world
```

---

## Observation

Docker automatically:
- downloaded the image
- created a container
- executed the process
- displayed output
- stopped the container

---

## Example Output

```text
Hello from Docker!
```

This confirmed:
Docker was functioning correctly.

---

# 7. Understanding Containers

## Display running containers

```bash
docker ps
```

---

## Observation

No running containers were displayed because:
the `hello-world` container exited after execution.

---

## Display all containers

```bash
docker ps -a
```

---

## Observation

The stopped container appeared in the output.

Example:

```text
Exited (0)
```

This indicated:
successful container execution.

---

## Important Insight

Containers behave similarly to:
Linux processes.

When the main process terminates:
the container stops.

---

# 8. Docker Permissions and Groups

Initially:
Docker commands required:
`sudo`.

Example error:

```text
permission denied while trying to connect to the Docker API socket
```

---

## Cause

Docker communicates using:

```text
/var/run/docker.sock
```

This socket is owned by:
the `docker` group.

---

## Solution

The main user was added to:
the Docker group.

```bash
sudo usermod -aG docker $USER
```

---

## Verification

```bash
grep docker /etc/group
```

Example:

```text
docker:x:984:krystian
```

---

## Important Observation

A new SSH session was required after:
modifying group membership.

After reconnecting:
Docker commands worked without `sudo`.

---

# 9. Useful Docker Commands

| Command | Purpose |
|---|---|
| `docker ps` | running containers |
| `docker ps -a` | all containers |
| `docker images` | local images |
| `docker version` | Docker version |
| `docker info` | Docker system information |

---

# 10. Docker Information Analysis

## Display Docker system information

```bash
docker info
```

---

## Observation

The output displayed:
- storage driver
- logging driver
- runtimes
- cgroup version
- CPU count
- memory allocation
- Docker root directory

---

## Example Information

| Field | Value |
|---|---|
| Storage Driver | overlayfs |
| Logging Driver | json-file |
| Cgroup Version | 2 |
| CPUs | 2 |
| Total Memory | 3.3GiB |

---

## Important Insight

Docker integrates deeply with:
Linux kernel technologies such as:
- cgroups
- namespaces
- overlay filesystems

---

# 11. Key Takeaways

- Docker was installed using the official repository
- Docker Engine and Docker CLI were successfully configured
- Containers are isolated Linux processes
- `hello-world` verified correct Docker functionality
- `docker ps` only shows running containers
- `docker ps -a` displays all containers
- Docker permissions are managed through the `docker` group
- Docker relies heavily on Linux kernel features
- Docker simplifies application isolation and deployment
- Containers stop automatically when their main process exits
