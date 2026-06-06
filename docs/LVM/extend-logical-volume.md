# LVM — Extending Volumes & Azure Disk Resize

## The golden rule

Every layer must be informed separately. Nothing happens automatically.

```
Physical disk grows
    ↓
growpart  — partition knows the disk is bigger
    ↓
pvresize  — PV knows the partition is bigger
    ↓
lvextend  — LV knows the PV has more space
    ↓
resize2fs — filesystem knows the LV is bigger
```

---

## Scenario 1 — Extend LV using free space already in VG

Use this when you have free space in the VG (e.g. you added a new disk earlier).

### Check free space first

```bash
vgs        # check VFree column
pvs        # check PFree column
lvs        # check current LV size
```

### Extend LV and filesystem in one command

```bash
sudo lvextend -r -l +100%FREE /dev/vg_data/lv_data
```

The `-r` flag does both steps automatically:
- resizes the LV
- resizes the filesystem (`resize2fs` for ext4, `xfs_growfs` for XFS)

### Verify

```bash
df -hT /mnt/dane
```

### What happens without `-r` (common junior mistake)

```bash
sudo lvextend -l +100%FREE /dev/vg_data/lv_data
df -hT /mnt/dane   # still shows old size!
```

The LV grew but the filesystem doesn't know yet. Fix it manually:

```bash
# for ext4:
sudo resize2fs /dev/vg_data/lv_data

# for XFS (use mountpoint, not device!):
sudo xfs_growfs /mnt/dane
```

---

## Scenario 2 — Disk resized in Azure (conceptual)

In production, disk resize in Azure is done via Ansible or Terraform — not manually in the portal. But regardless of how the disk was resized, Linux still needs to be informed layer by layer.

### The two worlds

**World 1 — Azure (cloud layer):**
Resize the managed disk in Azure Portal or via Ansible:
```bash
# Ansible module:
azure.azcollection.azure_rm_manageddisk:
  name: myDisk
  disk_size_gb: 256
```
At this point Linux still sees the old disk size.

**World 2 — Linux (OS layer):**
You need to inform each layer separately:

```bash
# 1. Tell the kernel to rescan the disk (sometimes needed)
echo 1 | sudo tee /sys/class/block/sda/device/rescan

# 2. Extend the partition
sudo growpart /dev/sda 3      # note: space between sda and 3, not /dev/sda3 !

# 3. Tell LVM the PV is bigger
sudo pvresize /dev/sda3

# 4. Extend LV and filesystem
sudo lvextend -r -l +100%FREE /dev/mapper/rhel-root

# 5. Verify
df -hT /
```

### Common mistakes

| Mistake | Result | Fix |
|---|---|---|
| `lvextend` without `-r` | LV grew but `df` shows old size | run `resize2fs` or `xfs_growfs` manually |
| `resize2fs` on XFS | error | use `xfs_growfs /mountpoint` instead |
| `xfs_growfs /dev/...` | error | XFS needs mountpoint, not device path |
| `growpart /dev/sda3` | error | correct syntax is `growpart /dev/sda 3` (with space) |
| forgetting `pvresize` | LVM doesn't see new space | run `pvresize /dev/sdaX` |

---

## ext4 vs XFS — key difference

| | ext4 | XFS |
|---|---|---|
| Grow | ✅ yes | ✅ yes |
| Shrink | ✅ yes (offline only) | ❌ never |
| Resize tool | `resize2fs /dev/...` | `xfs_growfs /mountpoint` |
| Default on | Ubuntu/Debian | RHEL/Rocky |

---

## Quick reference

```bash
lvextend -r -l +100%FREE /dev/vg/lv   # extend LV + filesystem (best practice)
lvextend -L +10G /dev/vg/lv           # extend by fixed size
resize2fs /dev/vg/lv                   # resize ext4 filesystem manually
xfs_growfs /mountpoint                 # resize XFS filesystem manually
growpart /dev/sda 3                    # extend partition (Azure/cloud scenario)
pvresize /dev/sda3                     # tell LVM PV grew
```
