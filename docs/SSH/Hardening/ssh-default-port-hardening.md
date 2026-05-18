# SSH Default Port Hardening

## Goal

Secure remote SSH access by changing the default SSH port and troubleshooting service configuration issues.

---

## SSH Architecture

SSH uses two main configuration files:

| File | Purpose |
|---|---|
| ssh_config | SSH client configuration |
| sshd_config | SSH server daemon configuration |

---

## Task

Change the default SSH port from 22 to 2222.

### Why?

Changing the default SSH port:
- reduces automated scans
- improves basic SSH hardening
- helps protect remote administration services

---

## Configuration Steps

### 1. Backup SSH Configuration

bash sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup 

### Why?

Linux administrators should never modify production configuration files without creating a backup first.

---

### 2. Modify SSH Port

Edit SSH daemon configuration:

bash sudo nano /etc/ssh/sshd_config 

Change:

text #Port 22 

to:

text Port 2222 

---

### 3. Validate SSH Configuration

bash sudo sshd -t 

### Validation Result

No output returned → configuration syntax valid.

---

### 4. Restart SSH Service

bash sudo systemctl restart ssh 

---

### 5. Verify SSH Service Status

bash sudo systemctl status ssh 

---

### 6. Verify Listening Port

bash sudo ss -tulpn | grep ssh 

Expected result:

text 0.0.0.0:2222 

---

## VirtualBox NAT Port Forwarding

Updated NAT rule:

| Host Port | Guest Port |
|---|---|
| 2222 | 2222 |

SSH connection command:

bash ssh krystian@localhost -p 2222 

---

# Troubleshooting

## Problem 1

Modified backup configuration file instead of the active production configuration file.

### Cause

The backup file:

text /etc/ssh/sshd_config.backup 

was edited instead of:

text /etc/ssh/sshd_config 

### Resolution

Updated the correct production configuration file and restarted the SSH service.

---

## Problem 2

SSH continued listening on port 22 despite modifying sshd_config.

### Cause

Ubuntu was using:

text systemd socket activation 

The active listening port was controlled by:

text ssh.socket 

instead of:

text sshd_config 

### Diagnosis

bash systemctl status ssh.socket sudo ss -tulpn | grep ssh 

### Resolution

Disabled socket activation:

bash sudo systemctl disable --now ssh.socket sudo systemctl restart ssh 

---

## Problem 3

SSH connection failed after changing the SSH port.

### Symptoms

text kex_exchange_identification: read: Connection reset by peer 

### Cause

VirtualBox NAT Port Forwarding configuration changes were not saved.

### Resolution

Saved updated NAT Port Forwarding configuration:

| Host Port | Guest Port |
|---|---|
| 2222 | 2222 |

---
