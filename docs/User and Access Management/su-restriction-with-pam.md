# Restricting su Access with PAM

## Goal

Restrict usage of the `su` command only to privileged users.

---

# Why?

By default:
- users can attempt privilege escalation with `su`
- unrestricted user switching increases attack surface

Restricting `su`:
- improves security
- reduces lateral movement
- supports least privilege principles

---

# PAM Configuration

## Edit PAM su Configuration

```bash
sudo nano /etc/pam.d/su
```

---

# Restriction Rule

Uncomment:

```text
auth required pam_wheel.so
```

---

# Initial Problem

Ubuntu does not create the `wheel` group by default.

Validation:

```bash
grep wheel /etc/group
```

Result:
- group did not exist

---

# Observed Behavior

After enabling:

```text
auth required pam_wheel.so
```

No users could use `su`:
- developer ❌
- krystian ❌

Reason:
- PAM expected a `wheel` group
- group was missing

---

# Solution

## Create wheel Group

```bash
sudo groupadd wheel
```

---

## Add Administrative User

```bash
sudo usermod -aG wheel krystian
```

---

# Validation

## Allowed User

```bash
su developer
```

Result:
- successful login

---

## Restricted User

```bash
su krystian
```

Executed as:
- developer

Result:
- Permission denied

---

# Troubleshooting Scenario

## Critical PAM Misconfiguration

A mistaken character was accidentally inserted at the beginning of:

```text
/etc/pam.d/su
```

Example:

```text
ź#
```

This corrupted the PAM configuration and caused:
- complete `su` failure
- authentication denial

---

# Root Cause

PAM configuration files are extremely sensitive to:
- invalid syntax
- encoding issues
- unexpected characters

---

# Recovery

Removed the invalid character from the configuration file.

---

# Important Lesson

Before modifying authentication-related configuration:

Create backups:

```bash
sudo cp /etc/pam.d/su /etc/pam.d/su.bak
```

---

# Security Benefits

This configuration:
- restricts privilege escalation
- limits user switching
- improves access control
- supports least privilege security models

---

# Key Takeaways

- PAM controls Linux authentication behavior
- `pam_wheel.so` restricts `su`
- Ubuntu requires manual wheel group creation
- PAM misconfiguration can break authentication
- backups are critical before editing security files
