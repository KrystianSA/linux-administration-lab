# Troubleshooting #21 — Filesystem Read-Only

## What is a read-only filesystem?

A filesystem mounted as read-only means no writes are possible — creating, editing, or deleting files fails with:
```
Read-only file system
```

## Why does it happen?

Three main causes:

1. **Kernel protection** — kernel detects I/O errors on disk and automatically remounts as read-only to prevent further data corruption
2. **fstab configuration** — partition configured with `ro` option in `/etc/fstab`
3. **Hardware failure** — dying disk causing I/O errors

---

## Detect read-only filesystem

```bash
mount | grep ro,              # show read-only mounts (comma avoids false positives)
findmnt -o TARGET,OPTIONS     # cleaner view of all mounts and their options
```

Normal read-only mounts (safe to ignore):
```
/run/credentials/systemd-*.service   ← systemd security feature, expected
/sys, /proc                          ← virtual filesystems, expected
```

Problem read-only mount:
```
/dev/sda1 on / type ext4 (ro,relatime)   ← main filesystem read-only = alarm!
```

---

## Find the cause

```bash
dmesg | grep -i "i/o error"
dmesg | grep -i "error"
dmesg | grep -i "remount"
journalctl -k | grep -i error
```

Kernel remount signature in logs:
```
Buffer I/O error on device sda1, logical block ...
EXT4-fs error (device sda1): ...
EXT4-fs (sda1): Remounting filesystem read-only
```

If you see these → disk hardware problem caused the remount.

---

## Fix

### Option 1 — Quick fix (if disk is OK, just remount rw)

```bash
sudo mount -o remount,rw /
```

`-o remount,rw` changes options on already-mounted filesystem without unmounting.
Use this when kernel remounted as ro but disk seems healthy.

### Option 2 — Full repair with fsck

**Cannot run fsck on mounted filesystem** — must unmount first.

For non-root filesystems:
```bash
sudo umount /dev/sda1
sudo fsck /dev/sda1          # check and repair filesystem
sudo mount /dev/sda1         # remount
```

For root filesystem `/` — cannot unmount while running:
1. **GRUB recovery mode** — boot into single user mode
2. **Live USB** — boot from external media, disk is unmounted
3. **Azure Serial Console** — restart VM into recovery

### Option 3 — Check disk health first

Before any repair, check if hardware is failing:
```bash
sudo smartctl -a /dev/sda    # SMART health data
dmesg | grep -i sda          # kernel messages about this disk
```

If SMART shows errors → replace the disk, don't just repair filesystem.

---

## Important: always snapshot before fsck on production

`fsck` can make things worse on a severely damaged filesystem. Take a VM snapshot or disk backup before running it.

---

## Full troubleshooting flow

```
"Read-only file system" error
    ↓
mount | grep ro,               → confirm which filesystem is ro
    ↓
dmesg | grep -i "i/o error"   → kernel detected disk errors?
    ↓ no errors, just accidental ro
mount -o remount,rw /          → quick fix
    ↓ disk errors present
smartctl -a /dev/sda           → check disk health
    ↓ disk OK
boot recovery / live USB → fsck /dev/sda1 → remount
    ↓ SMART errors
replace disk
```

---

## Quick reference

```bash
mount | grep ro,               # find read-only filesystems
dmesg | grep -i "i/o error"   # kernel disk errors
dmesg | grep -i remount        # kernel remount events
sudo mount -o remount,rw /     # remount as read-write
sudo fsck /dev/sda1            # check and repair (unmounted only!)
sudo smartctl -a /dev/sda      # disk health check
```
