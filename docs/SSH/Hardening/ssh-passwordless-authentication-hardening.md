# SSH Key Authentication

<img width="1585" height="388" alt="Zrzut ekranu 2026-05-18 o 13 04 17" src="https://github.com/user-attachments/assets/69a88eba-ba9b-447e-a7e0-9a6eb98cff56" />

## Goal

Configure secure SSH authentication using SSH keys instead of passwords.

---

# Why?

SSH key authentication:
- is more secure than password authentication
- protects against brute-force attacks
- is a production standard in Linux administration environments
---

# Configuration Steps

## 1. Check Existing SSH Keys

ls ~/.ssh 

Observed result:

known_hosts 

No existing SSH key pair was present.

---

## 2. Generate SSH Key Pair

ssh-keygen -t ed25519 

### Why ed25519?

ed25519 is a modern recommended SSH key algorithm:
- secure
- fast
- widely supported

---

## 3. Copy Public Key to Ubuntu Server

ssh-copy-id -p 2222 krystian@localhost 

### What this command does

Automatically:
- copies the public key
- creates the .ssh directory
- creates the authorized_keys file
- sets correct permissions

---

## 4. Validate Passwordless Login

ssh krystian@localhost -p 2222 

Validation result:
- successful login
- no password prompt displayed

---

# Disable Password Authentication

## 1. Modify SSH Daemon Configuration

Edit SSH server configuration:

sudo nano /etc/ssh/sshd_config 

Change:

PasswordAuthentication yes 

to:

PasswordAuthentication no 

---

## 2. Validate SSH Configuration

sudo sshd -t 

No output returned:
- configuration syntax valid

---

## 3. Restart SSH Service

sudo systemctl restart ssh 

---

# Troubleshooting

## Problem

Password authentication remained enabled despite modifying sshd_config.

---

## Symptoms

Users were still able to log in using passwords.

Runtime configuration validation showed:

sudo sshd -T | grep passwordauthentication 

Observed result:

passwordauthentication yes 

---

## Cause

Ubuntu was using layered SSH configuration files.

The setting in:

/etc/ssh/sshd_config 

was overridden by:

/etc/ssh/sshd_config.d/50-cloud-init.conf 

---

## Diagnosis

Search all SSH configuration files:

sudo grep -R PasswordAuthentication /etc/ssh/ 

Observed override:

/etc/ssh/sshd_config.d/50-cloud-init.conf:PasswordAuthentication yes 

---

## Resolution

Edit override configuration:

sudo nano /etc/ssh/sshd_config.d/50-cloud-init.conf 

Change:

PasswordAuthentication yes 

to:

PasswordAuthentication no 

Restart SSH service:

sudo systemctl restart ssh 

---

# Final Validation

Validate effective runtime configuration:

sudo sshd -T | grep passwordauthentication 

Expected result:

passwordauthentication no 

---

# Security Validation

Force password authentication attempt:

ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no krystian@localhost -p 2222 

Observed result:

Permission denied (publickey) 

---

# Validation Result

| Feature | Status |
|---|---|
| SSH key authentication | Working |
| Password authentication | Disabled |
| SSH daemon validation | Successful |
| Effective runtime configuration | Verified |
