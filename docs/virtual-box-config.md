# Setting Up VirtualBox Environment

<img width="500" height="400" alt="Zrzut ekranu 2026-05-16 o 13 16 38" src="https://github.com/user-attachments/assets/645e5ef1-d960-4a55-8145-84afe8a6f4df" />`

# Table of Contents

- [VM Name](#vm-name)
- [VM Folder](#vm-folder)
- [ISO Image](#iso-image)
- [Unchecked: Proceed with Unattended Installation](#unchecked-proceed-with-unattended-installation)
- [Base Memory (RAM)](#base-memory-ram)
- [Number of CPUs](#number-of-cpus)
- [Checked: Enable EFI](#checked-enable-efi)
- [Disk Size](#disk-size)
- [Unchecked: Pre-allocate Full Size](#unchecked-pre-allocate-full-size)
- [Network Configuration](#network-configuration)

---

## VM Configuration

### VM Name

Purpose:
Create a dedicated Linux administration lab environment.

---

### VM Folder

Default VirtualBox location.

Purpose:
Stores VM configuration files, virtual disks, logs, and snapshots.

---

### ISO Image

`Ubuntu Server ARM64`

Purpose:
Use Ubuntu Server instead of Desktop version to simulate a real Linux server environment.

---

### Unchecked: Proceed with Unattended Installation

Reason:
Linux administrators should understand the full operating system installation process and manually configure the environment.

Manual installation provides:
- better understanding of Linux setup
- networking configuration practice
- storage configuration practice
- SSH setup experience

---

### Base Memory (RAM)

`4096 MB`

Reason:
Provides a balance between:
- host machine resource usage
- smooth Linux server performance

4 GB RAM is sufficient for:
- SSH
- Docker
- Nginx
- monitoring tools
- bash scripting practice

---

### Number of CPUs

`2 CPUs`

Reason:
Allows the virtual machine to handle multiple processes more efficiently and improves overall system responsiveness.

Suitable for:
- multitasking
- package installation
- Docker containers
- web server testing

---

### Checked: Enable EFI

Reason:
EFI is the modern replacement for legacy BIOS and is commonly used in modern Linux systems and enterprise environments.

Benefits:
- modern boot process
- GPT support
- better compatibility with ARM architecture
- realistic server environment

---

### Disk Size

`25 GB`

Reason:
Provides enough storage space for:
- Ubuntu Server
- Docker images
- logs
- additional packages
- future lab exercises

---

### Unchecked: Pre-allocate Full Size

Reason:
Dynamic allocation is more practical for lab environments because disk space is allocated gradually as needed.

Benefits:
- saves host storage space
- faster VM creation
- flexible for homelab usage

---

### Network Configuration

`NAT`

Reason:
NAT (Network Address Translation) allows the virtual machine to access the internet through the host machine connection.

Benefits:
- isolates the VM from the local home network
