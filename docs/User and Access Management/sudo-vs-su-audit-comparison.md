# sudo vs su - Audit Comparison

## Goal

Compare logging visibility between `sudo` and `su`.

---

# sudo Logging

## Command

```bash
sudo journalctl | grep sudo -m 10
```

---

# Example Output

```text
May 18 11:59:24 ubuntu-server sudo[5586]: krystian : TTY=/dev/pts/1 ; PWD=/home/krystian ; USER=root ; COMMAND=/usr/bin/journalctl
```

---

# Analysis

`sudo` provides detailed audit information:

| Field | Meaning |
|---|---|
| krystian | invoking user |
| TTY | terminal session |
| PWD | working directory |
| USER=root | target privilege |
| COMMAND | exact executed command |

---

# su Logging

## Command

```bash
sudo journalctl | grep su -m 10
```

---

# Example Output

```text
May 18 11:43:11 ubuntu-server su[5478]: pam_unix(su-l:session): session opened for user developer(uid=1001) by krystian(uid=1000)
```

---

# Analysis

`su` logging provides:
- session information
- user switching visibility

But:
- does not track exact commands
- provides weaker audit granularity

---

# Security Comparison

| Feature | sudo | su |
|---|---|---|
| User tracking | ✅ | ✅ |
| Session tracking | ✅ | ✅ |
| Exact command logging | ✅ | ❌ |
| Strong audit trail | ✅ | ❌ |
| Enterprise preferred | ✅ | ⚠️ |

---

# Key Takeaways

- `sudo` provides significantly stronger auditing
- `su` logs sessions but not executed commands
- enterprise environments prefer `sudo`
- granular audit trails improve incident investigation
- least privilege workflows rely heavily on `sudo`
