# Troubleshooting #1 — Disk Full (df shows 100%)

## The two root causes

| Cause | Tool to find it |
|---|---|
| Large files/directories eating space | `du` or `ncdu` |
| Deleted files held open by processes (ghost files) | `lsof +L1` |

---

## Step-by-step approach

### Step 1 — Which filesystem is full?

```bash
df -h
```

Look at `Use%` column. Key filesystems to watch:
- `/` — root filesystem (most common)
- `/var` — logs, databases, Docker data
- `/home` — user data

### Step 2 — Where is the space used? (existing files)

Descend the directory tree from root:

```bash
sudo du -sh /*
```

Filter to only show GB-sized directories:

```bash
sudo du -sh /* | grep G
```

Then go deeper into the biggest directory:

```bash
sudo du -sh /var/*
sudo du -sh /var/lib/* | grep G
```

Keep descending until you find the culprit.

### Step 3 — Are there ghost files? (deleted but held open)

```bash
sudo lsof +L1
```

A deleted file (`+L1` = link count less than 1) held open by a process still occupies disk space. The space is only freed when the process releases the file handle.

Fix: restart the process holding the file.

---

## ncdu — the smart way

`ncdu` is an interactive disk usage browser — it does everything above in one tool, sorted by size with keyboard navigation.

```bash
sudo apt install ncdu -y   # Ubuntu/Debian
sudo ncdu /                # scan from root
```

Navigate with arrow keys, press `d` to delete. Shows the full directory tree sorted largest-first — what you did manually with 5 commands, ncdu shows in 10 seconds.

---

## Common culprits

| Location | What hides there |
|---|---|
| `/var/log` | Application logs, journal |
| `/var/lib/docker` | Docker images and containers |
| `/var/lib/containerd` | Container runtime layers |
| `/var/lib/mysql` or `/var/lib/postgresql` | Database data |
| `/tmp` | Temp files (should auto-clear) |
| `/home` | User files, downloads |

## Docker-specific cleanup

If Docker/containerd is the culprit:

```bash
docker images          # list images
docker ps -a           # list all containers (including stopped)
docker system prune    # remove unused images/containers/networks
docker system prune -a # remove ALL images — use with caution on production!
```

---

## Key insight

`df` and `du` can disagree — `df` shows 100% but `du` shows little usage. This means ghost files (`lsof +L1`) are the cause. The kernel keeps the space allocated until all processes close their file handles.

```
df -h shows 100%
    ↓
du -sh /* | grep G    → big directories? → go deeper with du
    ↓ nothing found
lsof +L1              → ghost files? → restart the process
```
