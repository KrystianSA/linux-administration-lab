# Reverse Proxy

This document describes the Nginx reverse proxy configuration used to expose Uptime Kuma securely from a Docker container running on localhost.

---

# Goal

Expose the application through Nginx while keeping the Docker container inaccessible directly from the local network.

Traffic flow:

```text
Browser
↓
Nginx Reverse Proxy
↓
127.0.0.1:3001
↓
Docker Container
```

---

# Why Reverse Proxy Was Needed

The Docker container was configured with localhost-only binding:

```yaml
ports:
  - "127.0.0.1:3001:3001"
```

This improved security because the container was not directly accessible from the local network.

However, it also meant the application could only be reached from inside the VM.

Nginx reverse proxy was used as the public entrypoint.

---

# Install Nginx

```bash
sudo apt install nginx -y
```

Verify service status:

```bash
sudo systemctl status nginx
```

---

# Create Reverse Proxy Configuration

Create a new configuration file:

```bash
sudo nano /etc/nginx/sites-available/uptime-kuma-reverse-proxy
```

---

# Nginx Configuration

```nginx
server {
    listen 80;
    server_name kuma.local;

    location / {
        proxy_pass http://127.0.0.1:3001;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

---

# Enable Configuration

Create symbolic link:

```bash
sudo ln -s /etc/nginx/sites-available/uptime-kuma-reverse-proxy /etc/nginx/sites-enabled/
```

---

# Test Nginx Configuration

```bash
sudo nginx -t
```

Expected result:

```text
syntax is ok
test is successful
```

---

# Reload Nginx

```bash
sudo systemctl reload nginx
```

---

# Local DNS Configuration

The hostname `kuma.local` does not exist in public DNS.

A local DNS entry was added on the client machine.

Edit local hosts file:

```bash
sudo nano /etc/hosts
```

Add entry:

```text
192.168.x.x kuma.local
```

Where:

- `192.168.x.x` is the Ubuntu VM IP address
- `kuma.local` is the local hostname

---

# Verify Access

Open browser:

```text
http://kuma.local
```

Expected flow:

```text
Browser
↓
Nginx Reverse Proxy
↓
127.0.0.1:3001
↓
Uptime Kuma Container
```

---

# Security Benefits

## Reverse Proxy as Single Public Entry Point

Only Nginx is exposed to the local network.

The Docker container remains accessible only through localhost.

Benefits:

- Reduced attack surface
- Better traffic control
- Easier TLS management in future
- Cleaner network architecture

---

# Troubleshooting

## Duplicate default_server Error

An issue occurred because multiple Nginx configuration files were loaded simultaneously.

Error example:

```text
duplicate default server
```

Cause:

```nginx
include /etc/nginx/sites-available/*;
```

This caused Nginx to load backup configuration files as active configurations.

Correct configuration:

```nginx
include /etc/nginx/sites-enabled/*;
```

---

# Multiple Applications Behind Nginx

Another application was later deployed behind the same reverse proxy.

To distinguish traffic between applications:

- Separate `server_name` values were required
- Separate Nginx server blocks were created
- Additional local DNS entries were added in `/etc/hosts`

Example:

```nginx
server_name kuma.local;
server_name app.local;
```

---

# Lessons Learned

- Reverse proxy should be the only public entrypoint
- `sites-enabled` is preferred over `sites-available`
- `server_name` is required when hosting multiple applications
- Localhost Docker binding improves security
- Local DNS simplifies local homelab access
