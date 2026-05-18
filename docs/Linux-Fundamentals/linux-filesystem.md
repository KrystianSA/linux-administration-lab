# Working with the Linux Filesystem Through SSH

## Table of Contents

- [Goal](#goal)
- [Commands Used](#commands-used)
  - [Permissions Management](#permissions-management)
  - [Filesystem Navigation](#filesystem-navigation)
  - [File Searching](#file-searching)
  - [Reading Large Files](#reading-large-files)
  - [Disk Usage Analysis](#disk-usage-analysis)
- [Linux Filesystem Concepts](#linux-filesystem-concepts)
  - [Absolute vs Relative Paths](#absolute-vs-relative-paths)
  - [Hidden Files](#hidden-files)
  - [Sticky Bit](#sticky-bit)
- [Real Linux Administration Use Cases](#real-linux-administration-use-cases)
- [Troubleshooting](#troubleshooting)

---

# Goal

Understand:
- where Linux stores configuration files
- where logs are located
- where user data is stored
- where programs are installed
- how the Linux filesystem is organized
- how Linux permissions work

The environment was accessed remotely using SSH.

---

# Commands Used

## Permissions Management

### chmod — Change Permissions

Used to modify file and directory permissions.

Examples:

```bash
chmod +x script.sh
chmod g-x script.sh
```

---

### chown — Change Owner

Used to change the file owner.

Example:

```bash
sudo chown krystian file.txt
```

---

### chgrp — Change Group

Used to change the group assigned to a file or directory.

Example:

```bash
sudo chgrp developers file.txt
```

---

## Filesystem Navigation

| Command | Purpose |
|---|---|
| pwd | Display current directory |
| ls | List files and directories |
| ls -la | Show detailed listing including hidden files |
| cd | Change directory |
| mkdir | Create directory |
| touch | Create file |
| cp | Copy files |
| mv | Move or rename files |
| rm | Remove files |
| cat | Display file contents |
| less | Read large files interactively |

---

## File Searching

### find

Used to search for files and directories.

Example:

```bash
find / -name sshd_config 2>/dev/null
```

Purpose:
Search for SSH configuration files within the filesystem.

---

## Reading Large Files

Commands commonly used by Linux administrators for logs and configuration analysis.

| Command | Purpose |
|---|---|
| less | Interactive file viewer |
| head | Display first lines of a file |
| tail | Display last lines of a file |
| tail -f | Monitor logs in real time |

Examples:

```bash
tail -f /var/log/syslog
head /etc/passwd
```

---

## Disk Usage Analysis

Real production issue example:

```text
Server stopped working
Reason: Disk full
```

Commands used:

| Command | Purpose |
|---|---|
| df -h | Display filesystem usage |
| du -sh | Display directory size summary |
| du -ah | Display sizes of all files and directories |

Examples:

```bash
df -h
du -sh /var/log
```

---

# Linux Filesystem Concepts

## Absolute vs Relative Paths

### Absolute Path

A full filesystem path starting from the root filesystem:

```text
/etc/ssh/sshd_config
```

---

### Relative Path

A path relative to the current working directory.

Example:

```bash
cd Documents
```

---

## Hidden Files

Files beginning with `.` are hidden files.

Examples:

```text
.bashrc
.profile
.ssh
```

Purpose:
Linux stores many configuration files as hidden files.

Display hidden files:

```bash
ls -la
```

---

## Sticky Bit

Special permission commonly used on shared directories such as `/tmp`.

Example:

```text
drwxrwxrwt
```

Purpose:
Users can create files in the directory but cannot delete files owned by other users.

---

# Real Linux Administration Use Cases

Examples of practical filesystem-related Linux administration tasks:

- locating configuration files
- checking disk usage
- troubleshooting storage issues
- reading system logs
- managing permissions
- controlling file ownership
- monitoring filesystem growth

---

# Troubleshooting

## Problem

Permission denied errors while checking disk usage.

---

## Cause

Some system directories are restricted for non-root users.

Examples:

```text
/proc
/var/log/private
```

---

## Solution

Use elevated privileges when required.

Example:

```bash
sudo du -sh /var/log
```

---

## Observed Behavior

Example output:

```text
Permission denied
```

This is expected Linux security behavior.
