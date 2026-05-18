# SSH Permissions Troubleshooting

## Goal

Understand how Linux permissions influence SSH key authentication and how SSH validates directory security.

---

# Why?

SSH uses strict permission validation for:
- .ssh directories
- authorized_keys
- private keys

If permissions are too permissive:
- SSH refuses authentication
- public key login fails

This is a critical Linux security mechanism.

---

# Initial Validation

Check current SSH permissions:

bash id="k2m8s1" ls -la ~/.ssh 

Expected secure permissions:

| Object | Permission |
|---|---|
| .ssh | 700 |
| authorized_keys | 600 |

---

# Permission Explanation

## Secure .ssh Directory

drwx------ 

Equivalent numeric permission:

700 

Meaning:
- owner: read, write, execute
- group: no access
- others: no access

---

## Secure authorized_keys File

-rw------- 

Equivalent numeric permission:

600 

Meaning:
- owner: read, write
- group: no access
- others: no access

---

# Failure Scenario

## 1. Break SSH Directory Permissions

chmod 777 ~/.ssh 

This grants:
- full read/write/execute access
- to all users on the system

Equivalent permission:

rwxrwxrwx 

---

## 2. Test SSH Authentication

ssh krystian@localhost -p 2222 

Observed result:

Permission denied (publickey) 

---

# Why Authentication Failed

SSH detected insecure permissions on the .ssh directory.

Because all users could theoretically:
- modify authorized_keys
- inject malicious SSH keys
- compromise the account

SSH refused to trust the directory.

---

# Log Analysis

Inspect SSH logs:

sudo journalctl -u ssh -n 20 

Observed log:

Authentication refused: bad ownership or modes for directory /home/krystian/.ssh 

---

# Root Cause

The .ssh directory permissions were too permissive:

777 

SSH security validation failed.

---

# Recovery

Restore secure permissions:

chmod 700 ~/.ssh 

---

# Validation

Reconnect using SSH:

ssh krystian@localhost -p 2222 

Observed result:
- successful login
- SSH key authentication restored

---

# Troubleshooting Workflow

| Step | Action |
|---|---|
| Break permissions | chmod 777 ~/.ssh |
| Observe failure | SSH login denied |
| Analyze logs | journalctl -u ssh |
| Identify cause | bad ownership or modes |
| Restore permissions | chmod 700 ~/.ssh |
| Validate recovery | SSH login successful |

---
