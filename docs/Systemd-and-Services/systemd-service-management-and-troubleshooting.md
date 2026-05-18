# Systemd Service Management and Troubleshooting

## Table of Contents

- [1. Understanding systemctl status](#1-understanding-systemctl-status)
- [2. Checking Service Autostart](#2-checking-service-autostart)
- [3. Restarting Services](#3-restarting-services)
- [4. Creating a Custom Systemd Service](#4-creating-a-custom-systemd-service)
- [5. Viewing Logs with journalctl](#5-viewing-logs-with-journalctl)
- [6. Simulating Service Failures](#6-simulating-service-failures)
- [7. Understanding Crash Loops](#7-understanding-crash-loops)
- [8. Cleaning Up Custom Services](#8-cleaning-up-custom-services)
- [9. Key Takeaways](#9-key-takeaways)

---

# 1. Understanding systemctl status

## Goal

Learn how to inspect Linux services using systemd.

## Command

```bash
systemctl status ssh
```

## Why This Matters

This command provides:
- service state
- process information
- logs
- boot behavior
- troubleshooting data

---

# 2. Checking Service Autostart

## Command

```bash
systemctl is-enabled ssh
```

## Observed Result

```text
disabled
```

## Analysis

The SSH service was:
- running currently
- not configured to start automatically after reboot

This could result in:
- loss of remote access after system restart

## Fix

```bash
sudo systemctl enable ssh
```

---

# 3. Restarting Services

## Command

```bash
sudo systemctl restart ssh
```

## Validation

Observed:
- new PID assigned
- service restarted successfully

## Important Insight

Restarting a service reloads:
- service configuration
- daemon state

This is required after modifying:
```text
/etc/ssh/sshd_config
```

---

# 4. Creating a Custom Systemd Service

## Goal

Create and manage a custom Linux service.

## Create Script

```bash
nano /tmp/hello.sh
```

## Script Content

```bash
#!/bin/bash

while true
do
    echo "Hello from systemd service"
    sleep 10
done
```

## Make Executable

```bash
chmod +x /tmp/hello.sh
```

---

# Create Systemd Unit

```bash
sudo nano /etc/systemd/system/hello.service
```

## Unit File

```ini
[Unit]
Description=Simple Hello Service

[Service]
ExecStart=/tmp/hello.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

---

# Reload Systemd

```bash
sudo systemctl daemon-reload
```

## Start Service

```bash
sudo systemctl start hello
```

---

# 5. Viewing Logs with journalctl

## Command

```bash
sudo journalctl -u hello
```

## Important Insight

Systemd automatically collects:
- stdout
- stderr
- service logs

This creates centralized logging for Linux services.

---

# 6. Simulating Service Failures

## Scenario 1 - Logical Failure

Modified:

```bash
sleep invalid
```

## Observed Behavior

Service remained:
```text
active (running)
```

But:
- logs showed repeated errors

## Important Insight

A service can:
- remain alive
- while still being logically broken

This demonstrates why logs are critical for troubleshooting.

---

# 7. Understanding Crash Loops

## Scenario 2 - Hard Failure

Modified script:

```bash
#!/bin/bash

exit 1
```

## Observed Behavior

Service entered:
- restart loop
- repeated failures
- automatic restart attempts

Eventually:

```text
Start request repeated too quickly
```

## Important Insight

Systemd protects the system from:
- infinite restart loops
- resource exhaustion

Final state:

```text
Active: failed
```

---

# 8. Cleaning Up Custom Services

## Stop Service

```bash
sudo systemctl stop hello
```

## Disable Autostart

```bash
sudo systemctl disable hello
```

## Remove Unit File

```bash
sudo rm /etc/systemd/system/hello.service
```

## Remove Script

```bash
rm /tmp/hello.sh
```

## Reload Systemd

```bash
sudo systemctl daemon-reload
```

---

# 9. Key Takeaways

- systemd manages Linux services
- `systemctl` controls service lifecycle
- `journalctl` provides centralized logs
- services can fail logically or completely
- systemd automatically restarts failed services
- restart protection prevents infinite crash loops
- service failures usually do not crash the entire system
- proper cleanup is important after testing
