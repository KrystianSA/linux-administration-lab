# Troubleshooting #13 — Zombie Processes

## What is a zombie process?

A zombie is a process that has **finished executing** but its parent hasn't collected its exit code yet (hasn't called `wait()`).

Analogy: an employee finished their task and is waiting at their desk for the manager to sign it off. The employee does nothing but still occupies a desk slot.

**Zombie does NOT:**
- consume CPU
- consume memory

**Zombie DOES:**
- occupy a slot in the process table
- become a problem when you have thousands of them (table fills up)

---

## Find zombie processes

```bash
ps aux | awk '$8=="Z"'         # find processes with exact Z in STAT column
ps aux | grep defunct          # 'defunct' = zombie in Linux output
```

**Why not `ps aux | grep Z`?**
grep itself contains "Z" in its name — you'd see grep in the results. Use `awk` for exact column matching.

In `top` — zombie count is shown in the Tasks line:
```
Tasks: 125 total, 1 running, 124 sleeping, 0 zombie
```

---

## Fix zombie processes

**You cannot `kill` a zombie** — it's already dead. Signals don't work on dead processes.

You need to kill or restart the **parent process**.

### Step 1 — Find the parent PID

```bash
ps aux | awk '$8=="Z"'         # get zombie PID
ps -o ppid= -p <zombie_PID>   # get parent PID
```

### Step 2 — Restart or kill the parent

```bash
# preferred — if parent is a systemd service
systemctl restart <service>

# if not a service
kill <parent_PID>              # graceful (SIGTERM)
kill -9 <parent_PID>           # last resort (SIGKILL)
```

Restarting is safer than killing — killing the parent may affect other child processes.

### Alternative — send SIGCHLD to parent

```bash
kill -SIGCHLD <parent_PID>
```

This tells the parent "go collect your finished children" without fully restarting it. Works if the parent is written to handle this signal.

---

## Why zombies appear

The parent process has a bug — it creates child processes but never calls `wait()` to collect their exit status. Common in:
- Poorly written applications
- Applications under high load (parent too busy to collect children)
- Applications that crash before cleaning up

---

## Full troubleshooting flow

```
top → Tasks line shows zombie count > 0
    ↓
ps aux | awk '$8=="Z"'         → find zombie PID
    ↓
ps -o ppid= -p <zombie_PID>   → find parent PID
    ↓
systemctl restart <service>   → restart if it's a service
kill <parent_PID>             → otherwise kill parent
    ↓ zombies persist?
kill -SIGCHLD <parent_PID>    → signal parent to collect children
```

---

## Quick reference

```bash
ps aux | awk '$8=="Z"'         # find zombies
ps -o ppid= -p <PID>          # find parent PID
kill -SIGCHLD <parent_PID>    # signal parent to collect children
systemctl restart <service>   # restart parent service
```
