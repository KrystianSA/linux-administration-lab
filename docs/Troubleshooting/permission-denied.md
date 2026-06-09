# Troubleshooting #19 — Permission Denied Despite "Correct" Permissions

## The four layers of permissions

Permission denied can happen at four different levels — always check them in order:

```
1. File permissions (ls -l)
2. Parent directory permissions (namei -l)
3. ACL — extra per-user permissions (getfacl)
4. SELinux/AppArmor — mandatory access control (ausearch, ls -Z)
```

---

## Layer 1 — Standard file permissions

```bash
ls -l /path/to/file
```

Format: `-rwxr-xr--`
- `rwx` = owner: read, write, execute
- `r-x` = group: read, execute
- `r--` = others: read only

---

## Layer 2 — Parent directory permissions

The file permissions can be fine but a parent directory may block access.

```bash
namei -l /var/app/data/config.txt
```

Example output:
```
f: /var/app/data/config.txt
 dr-xr-xr-x root  root  /
 drwxr-xr-x root  root  var
 drwx------ root  root  app      ← problem here! others can't enter
 drwxr-xr-x root  root  data
 -rw-r--r-- root  root  config.txt
```

`namei -l` checks permissions of every element in the path — not just the final file.

---

## Layer 3 — ACL (Access Control List)

ACL extends standard permissions — allows granting access to specific users/groups without changing file ownership.

```bash
getfacl /path/to/file          # show ACL entries
setfacl -m u:username:r /path  # add read permission for specific user
setfacl -x u:username /path    # remove ACL for user
```

**Hidden trap:** `ls -l` doesn't show ACL. The only hint is a `+` at the end of permissions:

```
-rw-r--r--+ root root file.txt
            ↑ this + means ACL exists — check with getfacl
```

---

## Layer 4 — SELinux (RHEL/Rocky) / AppArmor (Ubuntu)

An additional security layer **on top of** standard permissions. Even if `ls -l` looks fine, SELinux/AppArmor can block access based on its own policies.

Analogy: you have a key to the office (standard permissions) but the security guard (SELinux) checks if you also have the right badge.

### SELinux (RHEL/Rocky)

```bash
ls -Z /path/to/file            # show SELinux context
ausearch -m avc                # search audit log for SELinux denials
ausearch -m avc | tail -20     # last 20 denials
```

If you see `denied` entries → SELinux is blocking.

Test by temporarily switching to permissive mode:
```bash
setenforce 0    # permissive — logs but doesn't block
# test if problem disappears
setenforce 1    # back to enforcing
```

Check current mode:
```bash
getenforce      # Enforcing / Permissive / Disabled
```

### AppArmor (Ubuntu)

```bash
sudo aa-status                          # show AppArmor status
sudo journalctl | grep -i apparmor      # AppArmor denials in logs
```

---

## SELinux vs AppArmor

| | SELinux | AppArmor |
|---|---|---|
| Default on | RHEL / Rocky / CentOS | Ubuntu / Debian |
| Model | Labels on every file and process | Profiles per application |
| Complexity | High | Lower |
| Check denials | `ausearch -m avc` | `journalctl \| grep apparmor` |

---

## Full troubleshooting flow

```
Permission denied
    ↓
ls -l <file>                    → check file permissions
    ↓ OK
namei -l <full/path/to/file>   → check entire path
    ↓ OK
ls -l <file> (look for +)      → ACL present?
getfacl <file>                  → check ACL rules
    ↓ OK
RHEL? ausearch -m avc           → SELinux denials?
Ubuntu? journalctl | grep apparmor → AppArmor denials?
    ↓ confirmed SELinux
setenforce 0                    → test in permissive mode
setenforce 1                    → restore enforcing
```

---

## Quick reference

```bash
ls -l <file>                    # standard permissions
namei -l <path>                 # permissions along full path
getfacl <file>                  # show ACL
setfacl -m u:user:r <file>      # add ACL for user
getenforce                      # SELinux mode
setenforce 0                    # set permissive (temporary!)
ausearch -m avc | tail -20      # SELinux denials
ls -Z <file>                    # SELinux context
```
