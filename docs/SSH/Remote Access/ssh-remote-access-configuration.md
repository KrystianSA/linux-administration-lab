# SSH Remote Access Configuration

<img width="1000" height="400" alt="established connection ssh local to mw" src="https://github.com/user-attachments/assets/169f0e13-6145-48dd-b5e0-d9c4911da898" />

## Goal

Connect to the Ubuntu Server remotely from the local macOS terminal using SSH.

---

## Table of Contents

- [Steps](#steps)
  - [1. Identify Ubuntu Server IP Address](#1-identify-ubuntu-server-ip-address)
  - [2. Verify SSH Service Status](#2-verify-ssh-service-status)
  - [3. Attempt SSH Connection from Local Terminal](#3-attempt-ssh-connection-from-local-terminal)
- [Troubleshooting](#troubleshooting)
  - [Problem](#problem)
  - [Cause](#cause)
  - [Diagnosis](#diagnosis)
  - [Solution](#solution)
  - [Result](#result)

## Steps

### 1. Identify Ubuntu Server IP Address

Command used:

```bash
ip a
```

Important information:
- active network interface: `enp0s8`
- IPv4 address found under: `inet`

Purpose:
Identify the server IP address required for SSH communication.

---

### 2. Verify SSH Service Status

Command used:

```bash
systemctl status ssh
```

Observed behavior:

```text
Active: inactive (dead)
TriggeredBy: ssh.socket
```

Explanation:
Modern Ubuntu versions use `systemd socket activation`.

The SSH daemon starts automatically when an incoming SSH connection is detected.

---

### 3. Attempt SSH Connection from Local Terminal

Command used:

```bash
ssh krystian@<server-ip>
```

Initial result:
SSH connection timeout.

---

# Troubleshooting

## Problem

Unable to establish an SSH connection from the host machine to the Ubuntu VM.

---

## Cause

The VM was configured with NAT networking.

NAT allows outbound internet access but blocks direct inbound connections from the host system.

---

## Diagnosis

Observed behavior:
- SSH client hangs during connection attempt
- VM accessible internally
- SSH service installed correctly

---

## Solution

Configured NAT Port Forwarding in VirtualBox.

Configuration:
- Host Port: `2222`
- Guest Port: `22`

Final connection command:

```bash
ssh krystian@localhost -p 2222
```

---

## Result

Successful remote SSH connection established between:
- macOS terminal
- Ubuntu Server VM

---
