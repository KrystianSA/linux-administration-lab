# DNS & Static IP Configuration on Ubuntu

## How DNS resolution works

When you type `google.com`, Linux resolves it in this order (defined in `/etc/nsswitch.conf`):

```
/etc/hosts (local file)
    ↓ not found
systemd-resolved cache (127.0.0.53)
    ↓ not in cache
Upstream DNS server (e.g. 8.8.8.8)
    ↓ doesn't know
Root servers (.)
    ↓
TLD servers (.com)
    ↓
Authoritative server for google.com
    ↓
IP address returned
```

### Key files

| File | Role |
|---|---|
| `/etc/hosts` | Local static mappings (name → IP), checked first |
| `/etc/nsswitch.conf` | Defines resolution order (`files dns`) |
| `/etc/resolv.conf` | Points to DNS resolver — on Ubuntu this is a **symlink** to systemd-resolved stub |

### Important: /etc/resolv.conf is a symlink on Ubuntu

```bash
ls -la /etc/resolv.conf
# /etc/resolv.conf -> ../run/systemd/resolve/stub-resolv.conf
```

It points to `127.0.0.53` — the systemd-resolved stub proxy. This is NOT the real DNS server.

To see the real upstream DNS:
```bash
resolvectl status | grep "DNS Server"
```

### Why systemd-resolved exists

systemd-resolved acts as a local stub proxy — it caches DNS responses for the whole system. Instead of every application querying the upstream DNS directly, they all query `127.0.0.53` and resolved handles caching and forwarding.

---

## Reading dig output

```bash
dig google.com
```

```
;; ->>HEADER<<- status: NOERROR        # NXDOMAIN = doesn't exist, SERVFAIL = server error
;; QUESTION SECTION:
;google.com. IN A                       # query type A = IPv4

;; ANSWER SECTION:
google.com. 281 IN A 142.250.120.138   # 281 = TTL in seconds
                                        # A = record type
                                        # last value = IP address

;; SERVER: 127.0.0.53                  # stub resolver (not real DNS)
;; Query time: 280 msec
```

### Useful dig flags

```bash
dig google.com +short          # only the IP
dig @8.8.8.8 google.com        # query specific DNS (bypasses local resolver)
dig google.com +trace          # trace full delegation from root servers
dig -x 142.250.120.138         # reverse lookup (IP → name)
dig google.com MX              # query specific record type
```

### DNS record types

| Record | Maps | Example use |
|---|---|---|
| A | name → IPv4 | `google.com → 142.250.120.138` |
| AAAA | name → IPv6 | `google.com → 2607:f8b0::...` |
| CNAME | name → another name (alias) | `www → google.com` |
| MX | domain → mail server + priority | email routing |
| NS | domain → authoritative name servers | zone delegation |
| PTR | IP → name (reverse) | email validation |
| TXT | arbitrary text | SPF, DKIM, DMARC |

### TTL — Time To Live

TTL is set by the domain owner. It defines how long a DNS response can be cached.

- **Short TTL** (e.g. 60s) — use when planning to change IP soon
- **Long TTL** (e.g. 3600s) — less DNS traffic, faster responses from cache

---

## Static IP configuration on Ubuntu (netplan)

### Check current IP before editing

```bash
ip a show enp0s8
```

Note your current IP — you'll use it as the static address.

### Always backup first

```bash
sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak
```

### Edit netplan config

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

```yaml
network:
  version: 2
  ethernets:
    enp0s8:
      dhcp4: false
      dhcp6: false
      match:
        macaddress: 08:00:27:cf:65:6b
      set-name: enp0s8
      addresses:
        - 192.168.0.128/24
      routes:
        - to: default
          via: 192.168.0.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

### YAML gotchas

- Space after `-` is required: `- 192.168.0.1` not `-192.168.0.1`
- Indentation must be spaces, not tabs
- `gateway4` is **deprecated** since Ubuntu 22.04 — use `routes: - to: default via: ...`

### Apply safely

```bash
netplan try     # tests config — auto-reverts after 120s if you don't confirm
                # press ENTER to accept, Ctrl+C to revert immediately
netplan apply   # applies permanently without safety net
```

**Always use `netplan try` when working remotely over SSH.**

### Verify

```bash
ip a show enp0s8                          # check IP assigned
ip route show default                     # check gateway
ping -c3 192.168.0.1                      # local connectivity
ping -c3 8.8.8.8                          # external connectivity
resolvectl status | grep "DNS Server"     # check DNS
dig google.com +short                     # DNS resolves correctly
```

---

## Lessons learned

| Mistake | What happened | Fix |
|---|---|---|
| Set `dhcp4: false` without static IP | VM lost IP, SSH dropped | Always set `addresses` and `routes` when disabling DHCP |
| No backup before editing | Had to manually revert | Always `cp file file.bak` before editing network config |
| Used `netplan apply` instead of `try` | No safety net | Use `netplan try` when working remotely |
