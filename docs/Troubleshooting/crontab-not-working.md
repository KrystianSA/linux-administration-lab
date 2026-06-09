# Troubleshooting #20 — Cron Not Working

## What is cron?

Cron is a scheduler — it runs tasks automatically according to a time schedule defined in `crontab`.

---

## Crontab syntax

```
m  h  dom  mon  dow  command
*  *   *    *    *   /path/to/script.sh
│  │   │    │    │
│  │   │    │    └── day of week (0-7, 0=Sunday)
│  │   │    └─────── month (1-12)
│  │   └──────────── day of month (1-31)
│  └──────────────── hour (0-23)
└─────────────────── minute (0-59)
```

Common examples:
```
*/1 * * * *     every minute
0 * * * *       every hour (at :00)
0 5 * * *       every day at 5:00 AM
0 5 * * 1       every Monday at 5:00 AM
```

---

## Step-by-step diagnosis

### Step 1 — Is cron service running?

```bash
systemctl status cron       # Ubuntu
systemctl status crond      # RHEL/Rocky
```

### Step 2 — Check cron logs

```bash
grep CRON /var/log/syslog   # Ubuntu
journalctl -u cron          # alternative
```

### Step 3 — Check crontab configuration

```bash
crontab -l                  # current user's crontab
crontab -l -u root          # root's crontab
cat /etc/crontab            # system-wide crontab
ls /etc/cron.d/             # additional cron configs
```

### Step 4 — Verify script output

Always redirect output in crontab to catch errors:
```
*/1 * * * * /path/script.sh >> /path/script.log 2>&1
```

Then check:
```bash
tail -f /path/script.log    # watch log in real time
```

---

## Common cron gotchas

### 1. PATH is minimal in cron

Cron's PATH is very limited — usually only `/usr/bin:/bin`.
Commands that work in your terminal may not work in cron.

**Wrong:**
```bash
docker ps
python3 script.py
```

**Correct — use full paths:**
```bash
/usr/local/bin/docker ps
/usr/bin/python3 script.py
```

Or define PATH at the top of crontab:
```
PATH=/usr/local/bin:/usr/bin:/bin
*/1 * * * * /home/user/script.sh
```

Find full path of any command:
```bash
which docker
which python3
```

### 2. Missing newline at end of crontab

Cron requires a newline (`\n`) at the end of the file to recognize the last job as complete.
Without it, the last line may be silently ignored.

**Fix:** always leave an empty line after the last cron job when editing with `crontab -e`.

### 3. % must be escaped

In crontab, `%` is a special character meaning "newline". If your command contains `%` (e.g. date formatting), it will fail silently.

**Wrong:**
```bash
0 0 * * * date +%Y-%m-%d >> /tmp/date.log
```

**Correct — escape % with backslash:**
```bash
0 0 * * * date +\%Y-\%m-\%d >> /tmp/date.log
```

Classic trap: script works manually but fails in cron — check for `%`.

---

## Full troubleshooting flow

```
Cron job not running
    ↓
systemctl status cron           → service running?
    ↓ yes
grep CRON /var/log/syslog       → any errors in logs?
    ↓
crontab -l                      → job defined correctly?
    ↓ yes
script.sh manually              → does it work manually?
    ↓ yes, but not in cron
which <command>                 → use full paths in script
check for % in command          → escape with \%
check last line has newline     → add empty line at end
```

---

## Quick reference

```bash
crontab -l                      # list cron jobs
crontab -e                      # edit cron jobs
systemctl status cron           # check cron service (Ubuntu)
grep CRON /var/log/syslog       # cron logs
journalctl -u cron              # alternative logs
which <command>                 # find full path of command
```
