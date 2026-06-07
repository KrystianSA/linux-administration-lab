# Troubleshooting #6 — Process Listening on Wrong Port / Port Busy

## Key concept

Every service binds to a port — a socket waiting for connections. Only one process can occupy a port at a time. If two services try to use the same port, the second one fails with "address already in use".

---

## Find which process is using a port

```bash
ss -tulnp | grep :<port>     # show all TCP+UDP listening processes on port
lsof -i :<port>              # alternative — shows process name + PID
```

Flags for `ss`:
- `-t` — TCP
- `-u` — UDP  
- `-l` — listening only
- `-n` — don't resolve names (faster)
- `-p` — show PID and process name

**Why both TCP and UDP?** Some services use UDP (DNS port 53, NTP), others use TCP (SSH port 22, HTTP port 80). Use `-tulnp` to see both at once.

---

## Free up a port

```bash
systemctl stop <service>     # graceful — systemd cleans up properly (preferred)
kill <PID>                   # sends SIGTERM (same as kill -15) — less preferred
kill -9 <PID>                # SIGKILL — last resort, process can't clean up
```

### Signal hierarchy

```
systemctl stop   →  SIGTERM (graceful, systemd-aware, cleans PID files)
kill <PID>       →  SIGTERM (graceful, but systemd doesn't know what happened)
kill -9 <PID>    →  SIGKILL (immediate kill, no cleanup possible)
```

Always prefer `systemctl stop` — it does the same as SIGTERM but also informs systemd.
Use `kill -9` only when the process doesn't respond to normal signals.

---

## Change a service port on the fly

Edit the service config file:

```bash
# SSH example:
sudo nano /etc/ssh/sshd_config    # change Port 22 → Port 2222
```

Then apply the change:

```bash
systemctl reload <service>    # reload config without stopping (preferred on production)
systemctl restart <service>   # full stop + start (drops active connections)
```

**`reload` vs `restart`:**
- `reload` — service keeps running, only reloads config. Active connections are not dropped. Use on production.
- `restart` — full stop + start. All connections are dropped for a few seconds.

Not every service supports `reload` — test with `systemctl reload <service>`. If it errors, use `restart`.

---

## Troubleshooting flow

```
Service fails to start with "address already in use"
    ↓
ss -tulnp | grep :<port>       → find PID of process holding the port
    ↓
systemctl stop <service>       → free the port gracefully
    ↓
systemctl start <your service> → start your service
```

---

## Quick reference

```bash
ss -tulnp | grep :<port>       # find what's using a port
lsof -i :<port>                # alternative port check
systemctl stop <service>       # free port gracefully
systemctl reload <service>     # reload config (no downtime)
systemctl restart <service>    # full restart (brief downtime)
kill -9 <PID>                  # last resort
```
