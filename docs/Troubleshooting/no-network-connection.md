# Troubleshooting #7 — No Network Connectivity

## The layered approach

Network troubleshooting works layer by layer — each layer depends on the one below.
Always start from the bottom and work your way up.

```
Layer 1: Interface has IP?          ip a
    ↓
Layer 2: Gateway reachable?         ping -c3 <gateway>
    ↓
Layer 3: Internet reachable?        ping -c3 8.8.8.8
    ↓
Layer 4: DNS works?                 dig google.com +short
```

If any layer fails, fix it before moving to the next.

---

## Step-by-step commands

### Layer 1 — Does the interface have an IP?

```bash
ip a
ip a show enp0s8    # specific interface
```

No IP → DHCP not working or static config missing. Check netplan config.

### Layer 2 — Can you reach the gateway?

```bash
ip route show default    # find gateway IP
ping -c3 192.168.0.1     # ping it
```

No route → check netplan routes config.
Ping fails → firewall or physical connectivity issue.

### Layer 3 — Can you reach the internet?

```bash
ping -c3 8.8.8.8
```

**Important:** In a closed network (no internet access), this will always fail — not because the network is broken, but because the firewall blocks outbound traffic. In that case, ping the private DNS or another internal host instead.

### Layer 4 — Does DNS resolve?

```bash
dig google.com +short
dig @8.8.8.8 google.com     # bypass local resolver, test directly
resolvectl status            # check configured DNS servers
```

---

## Firewall — the hidden culprit

Always check if firewall is blocking traffic:

```bash
sudo ufw status              # Ubuntu
sudo firewall-cmd --list-all # RHEL/Rocky
```

### Common firewall gotcha — ICMP (ping)

ufw doesn't support ICMP via standard commands. To allow ping outbound, edit directly:

```bash
sudo nano /etc/ufw/before.rules
```

Find the OUTPUT icmp section and add:
```
# ok icmp codes for OUTPUT
-A ufw-before-output -p icmp --icmp-type echo-request -j ACCEPT
```

Then reload:
```bash
sudo ufw reload
```

**INPUT vs OUTPUT:**
- `INPUT` — incoming traffic to your server
- `OUTPUT` — outgoing traffic from your server

Ping sends an `echo-request` (OUTPUT) and receives `echo-reply` (INPUT).
Both directions need to be allowed.

### Enterprise firewalls

| Tool | Used on |
|---|---|
| `ufw` | Ubuntu (small servers, lab) |
| `firewalld` | RHEL/Rocky (enterprise) |
| `iptables/nftables` | Low-level, used under the hood by all others |
| Security Groups | Azure/AWS — cloud-level firewall, before the VM |

---

## Full troubleshooting flow

```
No connectivity reported
    ↓
ip a                          → interface has IP?
    ↓ yes
ip route show default         → gateway configured?
    ↓ yes
ping -c3 <gateway>            → gateway reachable?
    ↓ fails
ufw status / firewall-cmd     → firewall blocking ICMP?
    ↓ ok
ping -c3 8.8.8.8              → internet reachable?
    ↓ fails
ping internal host            → closed network?
    ↓ ok
dig google.com                → DNS works?
```

---

## Quick reference

```bash
ip a                          # check interface + IP
ip route show default         # check gateway
ping -c3 <gateway>            # test local connectivity
ping -c3 8.8.8.8              # test internet connectivity
dig google.com +short         # test DNS
sudo ufw status               # check firewall rules
sudo ufw reload               # reload after editing before.rules
```
