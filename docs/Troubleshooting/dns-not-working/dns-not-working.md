# Troubleshooting #8 — DNS Not Working

## Key distinction: ping vs dig for DNS testing

```bash
ping -c3 <dns_ip>           # is the DNS server alive? (ICMP)
dig @<dns_ip> google.com    # is the DNS service responding? (UDP port 53)
```

A server can be alive (ping works) but the DNS service can be down. Always test both.

---

## Step-by-step

### Step 1 — Is the network working at all?

```bash
ping -c3 <gateway>          # local connectivity
ping -c3 8.8.8.8            # internet (if not a closed network)
```

If this fails → network problem, not DNS. Go to troubleshooting #7.

### Step 2 — What DNS server is configured?

```bash
resolvectl status            # shows upstream DNS servers
cat /etc/resolv.conf         # what the system sees (likely 127.0.0.53 on Ubuntu)
```

### Step 3 — Is the DNS server reachable and responding?

```bash
ping -c3 <dns_ip>            # server alive?
dig @<dns_ip> google.com     # DNS service responding?
```

**Private domains** (e.g. `db.company.internal`): public DNS like `8.8.8.8` won't know them.
Use the internal/private DNS server instead:

```bash
dig @<private_dns_ip> db.company.internal
```

Find the private DNS IP via `resolvectl status`.

### Step 4 — Is the local resolver working?

```bash
dig google.com               # through local resolver (127.0.0.53)
dig @8.8.8.8 google.com      # bypassing local resolver
```

If `@8.8.8.8` works but `dig google.com` doesn't → problem with systemd-resolved.

```bash
systemctl status systemd-resolved
systemctl restart systemd-resolved
resolvectl flush-caches       # clear stale cache (e.g. after IP change)
```

### Step 5 — Check firewall (DNS = port 53 UDP/TCP)

```bash
ss -ulnp | grep :53          # is anything listening on port 53?
sudo ufw status              # is port 53 allowed out?
```

---

## Common scenarios

| Symptom | Likely cause | Fix |
|---|---|---|
| `dig @8.8.8.8` works, `dig` doesn't | systemd-resolved broken | restart systemd-resolved |
| `dig` works, app can't resolve | app ignores system resolver | check app DNS config |
| Private domain not resolving | Using public DNS | use `dig @<private_dns>` |
| Was working, suddenly stopped | Stale cache after IP change | `resolvectl flush-caches` |
| All DNS fails, ping 8.8.8.8 works | Port 53 blocked by firewall | check ufw / firewalld |

---

## Quick reference

```bash
resolvectl status               # check configured DNS + cache stats
resolvectl flush-caches         # clear DNS cache
dig google.com +short           # test DNS resolution
dig @8.8.8.8 google.com         # bypass local resolver
dig @<private_ip> internal.host # test private DNS
ss -ulnp | grep :53             # check if DNS port is listening
systemctl restart systemd-resolved  # restart local resolver
```

> For detailed DNS theory (resolver, hierarchy, TTL, record types) see: `dns-and-static-ip.md`
