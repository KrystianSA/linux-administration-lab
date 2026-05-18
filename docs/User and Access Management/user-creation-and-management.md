# User Creation and Management

## Goal

Learn how Linux user management works:
- creating users
- user IDs
- groups
- home directories
- switching users
- login environments

---

# Create New User

## Command

```bash
sudo adduser developer
```

---

# What `adduser` Does

The command automatically:
- creates a new Linux user
- creates a matching group
- creates a home directory
- sets default shell
- configures password

---

# Password Setup

During creation:
Linux prompts for:
- password
- password confirmation

Optional fields:
- Full Name
- Room Number
- Phone
- Other

These fields can be skipped.

---

# User Verification

## Command

```bash
id developer
```

---

# Example Output

```text
uid=1001(developer) gid=1001(developer) groups=1001(developer),100(users)
```

---

# Understanding UID and GID

| Element | Meaning |
|---|---|
| uid | User ID |
| gid | Primary Group ID |
| groups | User group membership |

---

# Important Linux Concept

Linux internally identifies users using:
- UID
- GID

Not usernames.

---

# Default UID Ranges

| Range | Purpose |
|---|---|
| 0 | root |
| 1-999 | system/service accounts |
| 1000+ | regular users |

---

# User Home Directory

## Validation

```bash
ls -ld /home/developer
```

---

# Example Output

```text
drwxr-x--- 2 developer developer 4096 May 18 12:15 /home/developer
```

---

# Analysis

| Element | Meaning |
|---|---|
| owner | developer |
| group | developer |
| permissions | home directory access |

---

# User and Group Mapping

Linux stores user information in:

| File | Purpose |
|---|---|
| `/etc/passwd` | users |
| `/etc/group` | groups |

---

# View Users

```bash
cat /etc/passwd
```

---

# View Groups

```bash
cat /etc/group
```

---

# Switching Users

## Basic User Switch

```bash
su developer
```

---

# Observed Behavior

Result:
- switched user
- retained previous environment

Example:
- previous working directory remained unchanged

---

# Full Login Session

## Command

```bash
su - developer
```

---

# Observed Behavior

Result:
- full login shell loaded
- switched to developer home directory
- environment variables refreshed

---

# Important Difference

| Command | Behavior |
|---|---|
| `su developer` | switch user only |
| `su - developer` | full login session |

---

# Why `su -` Matters

`su -` loads:
- login shell
- user environment
- profile configuration
- home directory
- PATH variables

---

# Verification

## Current User

```bash
whoami
```

---

# Current Directory

```bash
pwd
```

---

# Example

```text
developer
/home/developer
```

---

# Security Insight

Linux is designed as a:
- multi-user operating system

Access control relies heavily on:
- users
- groups
- ownership
- permissions

---

# Key Takeaways

- `adduser` automates Linux account creation
- Linux internally uses UID/GID identifiers
- users automatically receive home directories
- `su -` creates a proper login session
- groups are central to Linux access control
- user management is a core Linux administration skill
