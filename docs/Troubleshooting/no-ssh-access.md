# Troubleshooting #9 — No SSH Access

## Diagnose from the client side first

Before touching the server, diagnose from your machine:

```bash
ssh -v user@<ip> -p <port>    # verbose — shows exactly where connection fails
```

### Reading the verbose output

| What you see | What it means |
|---|---|
| `Connection established` | TCP works, port is open, SSH is running |
| `Connection refused` | Port is open but nothing listening (SSH stopped) |
| Timeout (no response) | Firewall silently blocking, server unreachable |
| `Permission denied` | SSH works, auth problem (wrong key/password) |

---

## Common causes

### 1. SSH service not running

```bash
systemctl status ssh
systemctl start ssh
journalctl -u ssh -n50        # check why it crashed
```

### 2. Wrong IP or port

```bash
ip a                          # check current IP on server
grep Port /etc/ssh/sshd_config # check configured port
ss -tlnp | grep sshd          # verify which port sshd is actually on
```

### 3. Firewall blocking SSH port

```bash
sudo ufw status               # Ubuntu
sudo firewall-cmd --list-all  # RHEL

# ufw LIMIT means rate limiting (not blocking) — protects against brute force
# if locked out, check if your IP is in ALLOW rules
```

### 4. SSH key issues

```bash
ls -la ~/.ssh/                          # check permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys        # must be 600, not 644!
```

Wrong permissions on `authorized_keys` = SSH silently ignores the key.

### 5. MaxAuthTries / brute force lockout

```bash
grep MaxAuthTries /etc/ssh/sshd_config
journalctl -u ssh | grep "too many"
```

---

## When you can't SSH in at all (remote server)

Escalation path:
1. **Azure Serial Console** — browser-based console access, no SSH needed
2. **iDRAC / iLO** — physical server out-of-band management
3. **VirtualBox console** — local VM direct access

From the console, run normal diagnostics:
```bash
systemctl status ssh
ufw status
ip a
journalctl -u ssh -n50
```

---

## Full troubleshooting flow

```
ssh -v user@ip -p port
    ↓
Connection refused     → SSH not running → systemctl start ssh
Timeout                → firewall blocking → check ufw/firewalld
Permission denied      → auth issue → check keys/password
Connection established → but then fails → check sshd_config / logs
    ↓ can't connect at all
Use Serial Console / iDRAC / VirtualBox console
```

---

## Quick reference

```bash
ssh -v user@ip -p port              # verbose connection (diagnose from client)
systemctl status ssh                # is SSH running?
ss -tlnp | grep sshd                # which port is sshd on?
grep Port /etc/ssh/sshd_config      # configured port
sudo ufw status                     # firewall rules
journalctl -u ssh -n50              # SSH logs
chmod 600 ~/.ssh/authorized_keys    # fix key permissions
```
