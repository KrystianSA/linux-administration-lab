# VMware vSphere

## Architecture overview

```
VMware (company)
    └── vSphere (platform)
            ├── ESXi        — Type 1 hypervisor, installed directly on physical hardware
            ├── vCenter     — Management server, coordinates multiple ESXi hosts
            └── vSphere Client — Web UI (HTML5) for admins
```

### Access methods

```
vSphere Client (GUI)    — browser-based, like Azure Portal
SSH + esxcli            — command line, like Azure CLI
```

If GUI is unavailable → use SSH. If SSH is unavailable → use vSphere Client.

---

## Hypervisor types

| Type | Description | Examples |
|---|---|---|
| **Type 1 (bare-metal)** | Installed directly on physical hardware, no OS underneath | ESXi, Hyper-V, KVM |
| **Type 2 (hosted)** | Installed on top of existing OS | VirtualBox, VMware Workstation |

**ESXi = Type 1** — more performant, used in enterprise.
**VirtualBox = Type 2** — easier to use, good for lab environments.

---

## vCenter features

vCenter manages multiple ESXi hosts and enables:

| Feature | What it does |
|---|---|
| **vMotion** | Live migration of running VM between ESXi hosts — zero downtime |
| **HA** (High Availability) | Automatically restarts VM on another host after host failure — brief downtime |
| **DRS** (Distributed Resource Scheduler) | Load balancing — automatically moves VMs between hosts using vMotion |

### vMotion vs HA

- **vMotion** — planned migration, host is healthy, zero downtime. Used for maintenance.
- **HA** — unplanned recovery, host failed, VM restarts on another host (brief downtime).

Used together in practice:
- **Day** — admin uses vMotion manually for planned maintenance
- **Night** — HA automatically handles unexpected host failures

### How vMotion works

1. RAM copied in background to destination host (VM keeps running)
2. Last RAM changes synchronized (milliseconds)
3. VM frozen for a fraction of a second
4. Network connection switched to new host
5. VM resumes on new host

**Requirement:** shared storage (SAN/NAS) between ESXi hosts — disk is NOT copied, both hosts see the same datastore.

---

## Snapshot vs Clone vs Backup

| | Snapshot | Clone | Backup |
|---|---|---|---|
| What | Point-in-time state | Full independent copy | Copy on external storage |
| Location | Same disk as VM | Same datastore | Different location |
| Purpose | Quick rollback point | Duplicate VM | Disaster recovery |
| Independent | No (delta file) | Yes | Yes |

### Snapshot — critical rules

```
✅ Use before: patching, risky config changes, deployments
❌ Delete after: verification that everything works
⚠️  Snapshot is NOT a backup — it's on the same disk as the VM!
⚠️  Long-lived snapshots grow (delta files) and degrade performance
```

Analogy:
- **Snapshot** = bookmark in a book
- **Clone** = photocopy of the whole book
- **Backup** = copy locked in a safe in another city

---

## VMware Tools (Guest Additions)

Software package installed **inside** the guest OS (Ubuntu/RHEL). Enables ESXi to communicate with the VM.

| Without VMware Tools | With VMware Tools |
|---|---|
| VM works but ESXi can't communicate | Full two-way communication |
| No graceful shutdown | Graceful shutdown from vSphere Client |
| No time sync | Time synced with ESXi host |
| vMotion harder | vMotion fully supported |
| ESXi doesn't know VM's IP | IP visible in vSphere Client |

**Equivalent on other platforms:**
- VirtualBox → **Guest Additions** (`vboxguest` kernel module)
- Hyper-V → **Integration Services**

Check if installed (VirtualBox):
```bash
lsmod | grep vboxguest
```

---

## esxcli — Command Line Management

Used after connecting to ESXi via SSH. Enable SSH first in vSphere Client → Host → Services.

```bash
# ESXi version
esxcli system version get

# List running VMs (get World ID for kill)
esxcli vm process list

# Kill stuck VM — always start with soft!
esxcli vm process kill --type=soft --world-id=<ID>   # graceful (like SIGTERM)
esxcli vm process kill --type=hard --world-id=<ID>   # immediate kill
esxcli vm process kill --type=force --world-id=<ID>  # last resort only!

# List ALL VMs (including powered off)
vim-cmd vmsvc/getallvms

# Network interfaces
esxcli network ip interface list

# Datastores (storage)
esxcli storage filesystem list
```

### Why soft → hard → force (never skip to force)?

Same logic as Linux `kill`:
- `soft` = SIGTERM — VM can clean up, close files, save state
- `hard` = immediate process kill
- `force` = kernel forcefully removes VM — risk of filesystem corruption

**Always start with soft.**

---

## VM vs Docker Container

Classic interview question:

| | VM | Container |
|---|---|---|
| Virtualizes | Hardware | Operating system |
| Has own kernel | Yes | No (shares host kernel) |
| Start time | ~1 minute | < 1 second |
| Size | GB | MB |
| Isolation | Strong (separate kernel) | Weaker (shared kernel) |
| Technology | Hypervisor (ESXi) | namespaces + cgroups |

**In practice — combine both:**
Containers run inside VMs (EKS/GKE/AKS managed Kubernetes does exactly this).

---

## What a junior must know for the interview

- Difference between ESXi and vCenter
- What snapshot is — and that **it is NOT a backup**
- What vMotion does and why it requires shared storage
- That VMware Tools improves guest integration (drivers, time, graceful shutdown)
- That VM sees disk as `/dev/sda` — expanding works the same as in cloud: `growpart → pvresize → lvextend → resize2fs`
- esxcli kill order: soft → hard → force
