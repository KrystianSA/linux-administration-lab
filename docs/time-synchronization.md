# Troubleshooting #22 — Server Time Drift

## Why time matters

Wrong server time breaks:
- **Logs** — events out of order across servers
- **JWT tokens** — based on timestamps, wrong time = expired tokens
- **TLS certificates** — validity period checked against system time
- **Cron jobs** — run at wrong times
- **Kerberos/AD authentication** — max 5 minute drift allowed

---

## Check current time status

```bash
timedatectl
```

Example output:
```
               Local time: Tue 2026-06-09 21:09:07 CEST
           Universal time: Tue 2026-06-09 19:09:07 UTC
                 RTC time: Tue 2026-06-09 19:18:01
                Time zone: Europe/Warsaw (CEST, +0200)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```

Key fields:
- `System clock synchronized: yes` → time is synced ✅
- `NTP service: active` → NTP running ✅
- `RTC in local TZ: no` → RTC stores UTC (correct for Linux)

**RTC vs Local time difference** — RTC (hardware clock on motherboard) stores UTC, system displays local time. Normal if difference = timezone offset. Problem if difference is random.

---

## Check NTP servers

```bash
# systemd-timesyncd
timedatectl timesync-status

# chrony (more common on servers)
chronyc sources
```

Reading `chronyc sources`:
```
^* ntp-server    2   6   377   42   -1187us    ← active server (*)
^- ntp-server2   2   6   377   43   +5440us    ← available but not selected
```

- `^*` — currently active NTP server
- `Stratum` — hierarchy level (1=atomic clock, 2=synced from stratum 1)
- `Reach: 377` — all last 8 packets arrived ✅
- `Last sample` — time offset (microseconds = good, seconds = problem)

---

## Common causes and fixes

### 1. Firewall blocking NTP (port 123 UDP)

```bash
sudo ufw status | grep 123
ss -ulnp | grep :123
```

Fix:
```bash
sudo ufw allow out 123/udp
```

### 2. NTP server unreachable — change server

```bash
sudo nano /etc/chrony.conf          # chrony
sudo nano /etc/systemd/timesyncd.conf  # systemd-timesyncd
```

Force immediate sync:
```bash
sudo chronyc makestep               # chrony
sudo systemctl restart chrony       # restart chrony
sudo timedatectl set-ntp true       # enable NTP if disabled
```

### 3. Wrong timezone

```bash
timedatectl                         # check current timezone
timedatectl list-timezones | grep Warsaw   # find correct timezone
sudo timedatectl set-timezone Europe/Warsaw
```

### 4. RTC (hardware clock) drifted

After reboot, system may take time from RTC. Sync RTC with current system time:

```bash
sudo hwclock --systohc    # write system time → RTC
sudo hwclock --show       # check RTC time
```

---

## Full troubleshooting flow

```
Time is wrong / services complaining about time
    ↓
timedatectl                      → NTP active? clock synchronized?
    ↓ NTP not syncing
chronyc sources                  → any server reachable? offset ok?
    ↓ no servers reachable
ufw status | grep 123            → firewall blocking UDP 123?
    ↓ servers reachable but not syncing
/etc/chrony.conf                 → change NTP server
chronyc makestep                 → force immediate sync
    ↓ time correct but timezone wrong
timedatectl set-timezone         → fix timezone
    ↓ time drifts after reboot
hwclock --systohc                → sync RTC with system time
```

---

## Quick reference

```bash
timedatectl                          # time status overview
chronyc sources                      # NTP servers status
sudo chronyc makestep                # force immediate sync
sudo timedatectl set-ntp true        # enable NTP
sudo timedatectl set-timezone Europe/Warsaw  # set timezone
sudo hwclock --systohc               # sync RTC with system time
sudo hwclock --show                  # show hardware clock
```
