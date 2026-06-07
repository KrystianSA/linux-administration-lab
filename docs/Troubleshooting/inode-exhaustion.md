# Troubleshooting #2 — Inode Exhaustion (df full but du shows little)

## What is an inode?

Every file and directory on Linux has an inode — a metadata record containing:
- Owner, permissions, timestamps
- File size, pointers to data blocks
- **Everything except the filename**

Each filesystem has a **fixed number of inodes** set at creation time. When they run out, you cannot create new files — even if there's plenty of free disk space.

---

## The key symptom

```bash
df -h   # Use%  40%  ← plenty of space!
df -i   # IUse% 100% ← no inodes left!
```

Error message: `No space left on device` — even though df -h looks fine.

**Always check both `df -h` AND `df -i` when you see "no space left".**

---

## Step-by-step approach

### Step 1 — Confirm it's inode exhaustion

```bash
df -i
```

Look at `IUse%` column. If any filesystem shows 100% → inode exhaustion.

### Step 2 — Find which directory has millions of small files

```bash
find / -xdev -printf '%h\n' 2>/dev/null | sort | uniq -c | sort -rn | head -20
```

Breaking this down:
- `find / -xdev` — find all files, stay on same filesystem (don't cross to /proc etc.)
- `-printf '%h\n'` — print only the parent directory for each file
- `2>/dev/null` — discard errors
- `sort` — required before uniq (uniq only detects adjacent duplicates)
- `uniq -c` — count how many times each directory appears = number of files
- `sort -rn` — sort numerically, largest first
- `head -20` — show top 20

### Step 3 — Clean up

**Old kernel headers** (common culprit — thousands of .h files):
```bash
sudo apt autoremove    # safely removes old kernels, keeps at least 2
```

**Build dependencies** (node_modules, pip cache, maven):
```bash
rm -rf node_modules           # JavaScript
pip cache purge               # Python
mvn dependency:purge-local-repository  # Java/Maven
```

**Session/cache files** (PHP sessions, app cache):
```bash
find /var/lib/php/sessions -type f -mtime +7 -delete  # older than 7 days
```

---

## Common culprits

| Location | What causes it |
|---|---|
| `/usr/src/linux-headers-*/include/config` | Old kernel headers |
| `node_modules` | JavaScript dependencies |
| `/var/lib/dpkg/info` | apt package metadata |
| `/tmp` or `/var/tmp` | Temp files from apps |
| PHP session dirs | Uncleaned session files |
| Email queues (`/var/spool/mail`) | Undelivered mail |

---

## disk full vs inode exhaustion — key difference

| | Disk Full | Inode Exhaustion |
|---|---|---|
| `df -h` | 100% | Normal (e.g. 40%) |
| `df -i` | Normal | 100% |
| Cause | Large files, ghost files | Millions of small files |
| Fix | Delete large files, restart processes | Delete directories with many small files |
| Error message | `No space left on device` | `No space left on device` (same!) |

---

## Quick reference

```bash
df -h                          # check disk space
df -i                          # check inode usage
find / -xdev -printf '%h\n' 2>/dev/null | sort | uniq -c | sort -rn | head -20  # find inode hogs
sudo apt autoremove            # clean old kernels
``````

**Session/cache files** (PHP sessions, app cache):
```bash
find /var/lib/php/sessions -type f -mtime +7 -delete  # older than 7 days
```

---

## Common culprits

| Location | What causes it |
|---|---|
| `/usr/src/linux-headers-*/include/config` | Old kernel headers |
| `node_modules` | JavaScript dependencies |
| `/var/lib/dpkg/info` | apt package metadata |
| `/tmp` or `/var/tmp` | Temp files from apps |
| PHP session dirs | Uncleaned session files |
| Email queues (`/var/spool/mail`) | Undelivered mail |

---

## disk full vs inode exhaustion — key difference

| | Disk Full | Inode Exhaustion |
|---|---|---|
| `df -h` | 100% | Normal (e.g. 40%) |
| `df -i` | Normal | 100% |
| Cause | Large files, ghost files | Millions of small files |
| Fix | Delete large files, restart processes | Delete directories with many small files |
| Error message | `No space left on device` | `No space left on device` (same!) |

---

## Quick reference

```bash
df -h                          # check disk space
df -i                          # check inode usage
find / -xdev -printf '%h\n' 2>/dev/null | sort | uniq -c | sort -rn | head -20  # find inode hogs
sudo apt autoremove            # clean old kernels
```
