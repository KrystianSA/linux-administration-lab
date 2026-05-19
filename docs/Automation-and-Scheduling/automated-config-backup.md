# Automated Configuration Backup with Cron

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Creating Backup Directory](#2-creating-backup-directory)
- [3. Creating Backup Script](#3-creating-backup-script)
- [4. Understanding the Script](#4-understanding-the-script)
- [5. Making the Script Executable](#5-making-the-script-executable)
- [6. Testing the Backup Script](#6-testing-the-backup-script)
- [7. Automating Backups with Cron](#7-automating-backups-with-cron)
- [8. Log Management](#8-log-management)
- [9. Backup Rotation](#9-backup-rotation)
- [10. Key Takeaways](#10-key-takeaways)

---

# 1. Introduction

This lab demonstrates how to automate Linux configuration backups using:
- shell scripting
- cron jobs
- compressed archives
- automated log handling

The backup process includes:
- `/etc`
- custom scripts
- log files

---

# 2. Creating Backup Directory

## Create backup folder

```bash
mkdir -p ~/backups
```

---

# 3. Creating Backup Script

## Create script file

```bash
nano ~/script/backup-system.sh
```

---

## Backup script

```bash
#!/bin/bash

TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")

BACKUP_DIR="/home/krystian/backups"
LOG_FILE="/home/krystian/logs/backup.log"

exec >> $LOG_FILE 2>&1

BACKUP_NAME="backup-$TIMESTAMP.tar.gz"

echo "===== BACKUP STARTED ====="
date

tar -czf $BACKUP_DIR/$BACKUP_NAME \
/etc \
/home/krystian/script \
/home/krystian/logs

echo "Backup created: $BACKUP_NAME"

find $BACKUP_DIR -type f -mtime +7 -delete

echo "Old backups cleaned"

echo "===== BACKUP FINISHED ====="
echo ""
```

---

# 4. Understanding the Script

## Variables

| Variable | Purpose |
|---|---|
| TIMESTAMP | unique backup timestamp |
| BACKUP_DIR | backup storage location |
| LOG_FILE | backup log file |
| BACKUP_NAME | generated archive name |

---

## Tar command

```bash
tar -czf
```

| Flag | Meaning |
|---|---|
| c | create archive |
| z | gzip compression |
| f | archive filename |

---

## Redirecting Logs

```bash
exec >> $LOG_FILE 2>&1
```

This redirects:
- standard output (`stdout`)
- errors (`stderr`)

into the same log file.

---

# 5. Making the Script Executable

## Add execute permission

```bash
chmod +x ~/script/backup-system.sh
```

---

# 6. Testing the Backup Script

## Manual test

```bash
sudo ~/script/backup-system.sh
```

---

## Verify backups

```bash
ls -lh ~/backups
```

---

## Verify logs

```bash
cat ~/logs/backup.log
```

---

# 7. Automating Backups with Cron

## Open root crontab

```bash
sudo crontab -e
```

---

## Add cron entry

```cron
1 7 * * * /home/krystian/script/backup-system.sh
```

---

## Cron schedule explanation

| Field | Value |
|---|---|
| minute | 1 |
| hour | 7 |
| day | * |
| month | * |
| weekday | * |

Meaning:

```text
Run every day at 07:01
```

---

# 8. Log Management

The backup script automatically writes logs into:

```text
/home/krystian/logs/backup.log
```

The log file contains:
- backup start time
- archive creation
- cleanup actions
- possible errors

---

# 9. Backup Rotation

Old backups are automatically deleted:

```bash
find $BACKUP_DIR -type f -mtime +7 -delete
```

Explanation:

| Option | Meaning |
|---|---|
| -type f | regular files |
| -mtime +7 | older than 7 days |
| -delete | remove files |

---

# 10. Key Takeaways

- Cron can automate recurring backups
- Shell scripts simplify Linux automation
- `tar` enables compressed archive creation
- `stdout` and `stderr` can be centralized into one log file
- Backup rotation helps manage disk usage
- Automated backups are an important operational practice
