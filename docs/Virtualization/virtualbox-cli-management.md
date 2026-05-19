# VirtualBox CLI Management with VBoxManage

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Why Use VBoxManage](#2-why-use-vboxmanage)
- [3. Starting a Virtual Machine](#3-starting-a-virtual-machine)
- [4. Running Virtual Machines in Headless Mode](#4-running-virtual-machines-in-headless-mode)
- [5. Stopping a Virtual Machine](#5-stopping-a-virtual-machine)
- [6. Troubleshooting Invalid Commands](#6-troubleshooting-invalid-commands)
- [7. Verifying VM State](#7-verifying-vm-state)
- [8. Key Takeaways](#8-key-takeaways)

---

# 1. Introduction

`VBoxManage` is the command-line management utility for VirtualBox.

It allows administrators to:
- start virtual machines
- stop virtual machines
- configure networking
- manage storage
- automate VM operations
- run headless infrastructure

This approach is commonly used in:
- homelabs
- CI/CD systems
- server automation
- remote virtualization environments

---

# 2. Why Use VBoxManage

Using CLI management provides:
- automation capabilities
- faster workflows
- remote management
- scripting support
- infrastructure-as-code compatibility

Compared to GUI management:
- terminal workflows scale better
- commands can be scripted
- easier remote administration

---

# 3. Starting a Virtual Machine

## Command

```bash
VBoxManage startvm "ubuntu-server-lab" --type=headless
```

## Breakdown

| Element | Meaning |
|---|---|
| VBoxManage | VirtualBox CLI utility |
| startvm | start virtual machine |
| "ubuntu-server-lab" | VM name |
| --type=headless | run without GUI |

---

# 4. Running Virtual Machines in Headless Mode

Headless mode starts the VM:
- without opening the VirtualBox GUI
- fully in the background

This is commonly used for:
- Linux servers
- homelab infrastructure
- SSH-based administration
- remote servers

## Observed Output

```text
Waiting for VM "ubuntu-server-lab" to power on...
VM "ubuntu-server-lab" has been successfully started.
```

---

# 5. Stopping a Virtual Machine

## Command

```bash
VBoxManage controlvm "ubuntu-server-lab" poweroff
```

## Breakdown

| Element | Meaning |
|---|---|
| controlvm | control running VM |
| poweroff | immediate shutdown |

## Observed Output

```text
0%...10%...20%...100%
```

## Important Insight

`poweroff` behaves similarly to:
- unplugging physical power from a machine

This is:
- fast
- but not graceful

In production environments, graceful shutdown methods are preferred whenever possible.

---

# 6. Troubleshooting Invalid Commands

## Incorrect Command

```bash
VBoxManage stopvm
```

## Observed Error

```text
VBoxManage: error: Invalid command 'stopvm'
```

## Analysis

`VBoxManage` does not include:
```text
stopvm
```

Instead:
- VM lifecycle actions are managed through:
```text
controlvm
```

Correct command:

```bash
VBoxManage controlvm "ubuntu-server-lab" poweroff
```

## Important Insight

CLI tooling often:
- requires exact syntax
- separates lifecycle actions into subcommands

Reading command output carefully is critical for troubleshooting.

---

# 7. Verifying VM State

After restarting the VM:
- SSH connectivity was successfully restored
- the VM received a bridged LAN IP address

## SSH Test

```bash
ssh krystian@<ip> -p 2222
```

## Observed Result

Successful remote login confirmed:
- VM boot success
- networking functionality
- SSH service availability

---

# 8. Key Takeaways

- `VBoxManage` enables full CLI-based VM management
- headless mode is useful for server workflows
- `controlvm` manages running VM state
- CLI tooling requires exact syntax
- terminal-based virtualization management scales well
- VM administration can be fully automated
- headless Linux servers are commonly managed entirely through SSH
