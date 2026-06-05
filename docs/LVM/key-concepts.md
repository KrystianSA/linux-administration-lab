# LVM Basics 

## What is LVM?

LVM (Logical Volume Manager) is an abstraction layer over physical disks that allows flexible storage management — resizing volumes without downtime, combining multiple disks into one pool, and more.

### The three layers

```
Physical Disk → PV (Physical Volume) → VG (Volume Group) → LV (Logical Volume) → Filesystem
```

| Layer | Description | Command to create |
|---|---|---|
| PV | A disk or partition handed over to LVM | `pvcreate` |
| VG | A pool combining one or more PVs | `vgcreate` |
| LV | A "slice" of the VG — acts like a partition | `lvcreate` |

---

## Lab Setup

- OS: Ubuntu Server
- 2 virtual disks added in VirtualBox: `sda` (1GB), `sdb` (1GB)
- Verified with `lsblk`

---

## Scenario 1 — Create LVM from scratch

### Step 1 — Initialize disks as Physical Volumes

```bash
sudo pvcreate /dev/sda
sudo pvcreate /dev/sdb
```

Verify:
```bash
sudo pvs
```

Expected output:
```
PV         VG        Fmt  Attr PSize   PFree
/dev/sda             lvm2 ---   1.00g  1.00g
/dev/sdb             lvm2 ---   1.00g  1.00g
```

### Step 2 — Create a Volume Group

Combine both PVs into one VG called `vg_data`:

```bash
sudo vgcreate vg_data /dev/sda /dev/sdb
```

Verify:
```bash
sudo vgs
```

Expected output:
```
VG      #PV #LV #SN Attr   VSize  VFree
vg_data   2   0   0 wz--n- 1.99g  1.99g
```

### Step 3 — Create a Logical Volume

Create a 500MB LV called `lv_data` from `vg_data`:

```bash
sudo lvcreate -L 500M -n lv_data vg_data
```

Verify:
```bash
sudo lvs
```

### Step 4 — Create a filesystem

Format the LV with ext4:

```bash
sudo mkfs.ext4 /dev/vg_data/lv_data
```

### Step 5 — Mount the LV

```bash
sudo mkdir /mnt/dane
sudo mount /dev/vg_data/lv_data /mnt/dane
```

Verify:
```bash
df -hT /mnt/dane
```

Expected output:
```
Filesystem                  Type  Size  Used Avail Use% Mounted on
/dev/mapper/vg_data-lv_data ext4  452M  152K  417M   1% /mnt/dane
```

---

## Key concepts to remember

**LVM allocates space sequentially** — a 500MB LV fits entirely on `sda`, leaving `sdb` untouched. LVM automatically spans across disks when the LV is larger than a single PV.

**Filesystem ≠ LV** — after `lvextend`, you must also resize the filesystem separately:
- ext4: `resize2fs /dev/vg_data/lv_data`
- XFS: `xfs_growfs /mnt/dane`

Or use the `-r` flag to do both at once:
```bash
sudo lvextend -r -l +100%FREE /dev/vg_data/lv_data
```

**ext4 vs XFS:**
- ext4: can be grown and shrunk (shrink requires unmounting)
- XFS: can only be grown, never shrunk

---

## Useful commands cheatsheet

```bash
pvs                    # list Physical Volumes
vgs                    # list Volume Groups
lvs                    # list Logical Volumes
lsblk                  # show disk/partition/LV tree
df -hT                 # show filesystem usage + type
pvdisplay              # detailed PV info
vgdisplay              # detailed VG info
lvdisplay              # detailed LV info
```****
