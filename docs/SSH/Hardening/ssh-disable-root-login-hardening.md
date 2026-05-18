# Disable Root SSH Login

## Goal

Disable direct root SSH login to improve server security and follow least privilege administration principles.

---

## Why?

Allowing direct root SSH access increases attack surface and exposes the server to:
- brute-force attacks
- credential stuffing
- unauthorized privileged access

Best practice:
- log in using a regular user account
- elevate privileges using sudo

---

# Configuration Steps

## 1. Check Current Root Login Configuration

grep -n PermitRootLogin /etc/ssh/sshd_config 

Observed configuration:

#PermitRootLogin prohibit-password 

---

## 2. Modify SSH Configuration

Edit SSH daemon configuration:

sudo nano /etc/ssh/sshd_config 

Change:

#PermitRootLogin prohibit-password 

to:

PermitRootLogin no 

---

## 3. Validate SSH Configuration Syntax

sudo sshd -t 

Validation result:
- no output returned
- configuration syntax valid

---

## 4. Restart SSH Service

sudo systemctl restart ssh 

---

## 5. Verify Effective SSH Configuration

sudo sshd -T | grep permitrootlogin 

Expected result:

ermitrootlogin no 

---

# Production Validation

Attempted direct root SSH login:

ssh root@localhost -p 2222 

Observed result:

Permission denied 

---

# SSH Log Analysis

Checked SSH authentication logs:

sudo journalctl -u ssh -n 20 

Observed logs:

Failed password for root Accepted password for krystian 

<img width="1137" height="245" alt="Zrzut ekranu 2026-05-18 o 11 53 38" src="https://github.com/user-attachments/assets/03b7554c-6de9-4c5f-9f8d-4a835e410abd" />

---

# Validation Result

| Test | Result |
|---|---|
| Root SSH login | Blocked |
| Regular user SSH login | Working |
| SSH service status | Running |
| SSH listening port | 2222 |

---
