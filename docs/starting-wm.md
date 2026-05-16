# Starting Ubuntu Server VM - Installation Process

- [GRUB Bootloader](#grub-bootloader)
- [Preferred Language](#preferred-language)
- [Installation Type](#installation-type)
- [Network Configuration](#network-configuration)
- [Proxy Configuration](#proxy-configuration)
- [Ubuntu Archive Mirror Configuration](#ubuntu-archive-mirror-configuration)
- [Storage Configuration](#storage-configuration)
- [LVM and LUKS](#lvm-and-luks)
- [SSH Configuration](#ssh-configuration)
- [Server Snaps](#server-snaps)

# GRUB Bootloader

The VM starts with the GNU GRUB bootloader.

Purpose:
- load the Linux kernel
- start the operating system
- provide recovery and troubleshooting options

GRUB is an important Linux administration component because it allows:
- kernel selection
- recovery mode access
- boot troubleshooting
- kernel parameter editing

---

# Preferred Language

`English`

Reason:
Most Linux administration documentation, logs, troubleshooting resources, and enterprise environments use English.

Benefits:
- easier troubleshooting
- compatibility with documentation
- better understanding of Linux logs and errors

---

# Installation Type

`Ubuntu Server`

Reason:
Ubuntu Server provides a realistic Linux server environment used in enterprise infrastructure.

Why not minimized:
- minimized version removes many useful utilities
- standard Ubuntu Server is better for learning and lab environments

Minimized installations are more common in:
- cloud deployments
- containers
- lightweight production workloads

---

# Network Configuration

Default configuration using:
`NAT`

Reason:
The VM receives internet access through the host operating system.

Benefits:
- simple setup
- internet connectivity
- package downloads
- software updates

The IP address is automatically assigned using:
`DHCP`

---

# Proxy Configuration

Skipped during installation.

Reason:
Proxy servers are mostly used in enterprise environments for:
- traffic monitoring
- filtering
- security
- access control

Proxy configuration will be explored later as part of networking and security practice.

---

# Ubuntu Archive Mirror Configuration

Default Ubuntu mirror:
`archive.ubuntu.com`

Purpose:
Used to download:
- packages
- updates
- security patches

The installer verifies:
- internet connectivity
- repository availability
- package access

---

# Storage Configuration

Default automatic configuration was selected.

Options used:
- `Use an entire disk`
- `Set up this disk as an LVM group`

Reason:
Provides a standard Linux server storage layout suitable for lab environments.

---

# LVM and LUKS

## LVM

`LVM = Logical Volume Manager`

Purpose:
Provides flexible storage management.

Benefits:
- resize logical volumes
- easier storage expansion
- better disk management
- enterprise-like storage structure

## LUKS Encryption

`Encrypt the LVM group with LUKS`

Not enabled.

Reason:
Disk encryption is important in production and security-focused environments, but unnecessary for a beginner lab setup.

Purpose of LUKS:
- protect sensitive data
- encrypt the filesystem
- secure storage devices

---

# Storage Layout

The default storage layout was used.

Reason:
In real production environments, storage configuration depends on:
- business requirements
- application type
- database usage
- logging requirements
- scalability needs

Examples:
- separate volumes for Docker
- separate partitions for logs
- database storage isolation

---

# SSH Configuration

`Install OpenSSH Server`

Enabled.

Reason:
SSH is the standard method for remotely managing Linux servers.

SSH allows:
- remote terminal access
- server administration
- automation
- remote troubleshooting

---

# Server Snaps

Skipped during installation.

Reason:
For learning purposes, a clean Linux environment without additional software or background services is preferred.

Benefits:
- lower resource usage
- reduced attack surface
- simpler troubleshooting
- better understanding of the base operating system

