# Troubleshooting #23 — Too Many Open Files

## What are "open files" in Linux?

In Linux, everything is a file — not just files on disk:
- Regular files and directories
- Network connections (TCP/UDP sockets)
- Pipes
- Devices (`/dev/sda`)

Every open file, network connection, or pipe consumes a **file descriptor (FD)**.
Each process has a limit on how many FDs it can have open at once.

**Error:** `Too many open files` — process hit its FD limit.

**Most common victims:** web servers (nginx, apache), databases — each client connection = one FD.

---

## Standard file descriptors (every process has these)

| FD | Name | Purpose |
|---|---|---|
| 0 | stdin | input |
| 1 | stdout | output |
| 2 | stderr | error output |
| 255 | terminal | terminal control |

---

## Check current limits and usage

### Check limit

```bash
ulimit -n                        # FD limit for current session
cat /proc/<PID>/limits           # FD limit for specific process
```

### Check actual usage

```bash
lsof -p <PID> | wc -l            # count open files for process
ls /proc/<PID>/fd | wc -l        # alternative
ls /proc/$$/fd | wc -l           # for current shell ($$=current PID)
ls -la /proc/<PID>/fd            # show what's actually open
```

---

## Fix

### Temporary (current session only)

```bash
ulimit -n 65536
```

Disappears after logout.

### Permanent — /etc/security/limits.conf

```bash
sudo nano /etc/security/limits.conf
```

Add:
```
nginx    soft    nofile    65536
nginx    hard    nofile    65536
*        soft    nofile    65536    # all users
*        hard    nofile    65536
```

- `soft` — default limit, user can raise up to hard limit
- `hard` — absolute maximum, only root can increase
- `nofile` — number of open files

### Permanent — systemd unit file

For services managed by systemd:

```ini
[Service]
LimitNOFILE=65536
```

Apply:
```bash
sudo systemctl daemon-reload
sudo systemctl restart <service>
```

### System-wide limit

```bash
sysctl fs.file-max               # current system-wide max
sudo sysctl -w fs.file-max=200000  # increase temporarily
echo "fs.file-max=200000" >> /etc/sysctl.conf  # persist
```

---

## Full troubleshooting flow

```
"Too many open files" error
    ↓
ulimit -n                        → what's the current limit?
cat /proc/<PID>/limits           → what's the limit for this process?
    ↓
lsof -p <PID> | wc -l           → how many FDs is it actually using?
    ↓ at or near limit
/etc/security/limits.conf        → increase permanent limit
systemd unit LimitNOFILE         → for systemd services
```

---

## Quick reference

```bash
ulimit -n                        # current session FD limit
ulimit -n 65536                  # increase for current session
lsof -p <PID> | wc -l            # count open FDs for process
ls /proc/<PID>/fd | wc -l        # alternative count
cat /proc/<PID>/limits           # all limits for process
sysctl fs.file-max               # system-wide FD limit
```
