# Troubleshooting #4 — Service Won't Start

## First steps

```bash
systemctl status <service>       # general status + last few log lines
journalctl -u <service> -n50     # last 50 log lines (errors are at the end)
```

`systemctl status` vs `ps aux | grep <service>`:
- `systemctl status` — full picture: enabled/active state, logs, PID, memory, error reason
- `ps aux | grep` — only tells you if the process is alive right now

---

## Common causes

### 1. Bad configuration file

Most services have a config test command:

```bash
nginx -t                          # nginx
sshd -t                           # sshd
apache2ctl configtest             # apache
systemd-analyze verify <unit>     # systemd unit file
```

### 2. Port already in use

Another process is listening on the same port:

```bash
ss -tlnp | grep <port>
lsof -i :<port>
```

Fix: kill the process holding the port or change the service port.

### 3. Missing binary (wrong ExecStart path)

```bash
systemctl cat <service>    # check ExecStart= line
ls -la <binary path>       # does the binary exist?
which <binary>             # where is it?
```

### 4. Permission denied

Service trying to open a file/directory it doesn't own:

```bash
ls -la /path/to/file       # check ownership and permissions
namei -l /path/to/file     # check permissions along the full path
```

### 5. Crash loop ("start request repeated too quickly")

systemd gives up restarting if service crashes too fast:

```bash
journalctl -u <service>         # find the actual crash reason
systemctl reset-failed <service> # reset the failure counter
systemctl start <service>        # try again
```

To prevent future crash loops, add to unit file:
```ini
[Service]
RestartSec=5
StartLimitBurst=3
StartLimitIntervalSec=60
```

---

## Full troubleshooting flow

```
systemctl status <service>
    ↓ not enough info
journalctl -u <service> -n50
    ↓ check error message
Bad config?    → run config test command
Port busy?     → ss -tlnp | grep <port>
Missing binary?→ systemctl cat <service> → ls -la <path>
Permission?    → ls -l / namei -l
Crash loop?    → systemctl reset-failed → check StartLimitBurst
```

---

## Quick reference

```bash
systemctl status <service>         # status + recent logs
journalctl -u <service> -n50       # last 50 log lines
systemctl cat <service>            # show unit file (check ExecStart)
systemctl reset-failed <service>   # reset crash counter
ss -tlnp | grep :<port>            # check if port is busy
```
