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

bash id="gk29d1" grep -n PermitRootLogin /etc/ssh/sshd_config 

Observed configuration:

text id="n28sq0" #PermitRootLogin prohibit-password 

---

## 2. Modify SSH Configuration

Edit SSH daemon configuration:

bash id="7skf02" sudo nano /etc/ssh/sshd_config 

Change:

text id="0sl1az" #PermitRootLogin prohibit-password 

to:

text id="d0sqw1" PermitRootLogin no 

---

## 3. Validate SSH Configuration Syntax

bash id="h2kz91" sudo sshd -t 

Validation result:
- no output returned
- configuration syntax valid

---

## 4. Restart SSH Service

bash id="x9dka1" sudo systemctl restart ssh 

---

## 5. Verify Effective SSH Configuration

bash id="z8qj12" sudo sshd -T | grep permitrootlogin 

Expected result:

text id="f0a2sw" permitrootlogin no 

---

# Production Validation

Attempted direct root SSH login:

bash id="m2s8k2" ssh root@localhost -p 2222 

Observed result:

text id="j92ks1" Permission denied 

---

# SSH Log Analysis

Checked SSH authentication logs:

bash id="w2j9sl" sudo journalctl -u ssh -n 20 

Observed logs:

text id="s1k2mz" Failed password for root Accepted password for krystian 

---

# Validation Result

| Test | Result |
|---|---|
| Root SSH login | Blocked |
| Regular user SSH login | Working |
| SSH service status | Running |
| SSH listening port | 2222 |

---
