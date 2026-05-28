# Configuration
---

# Initial Setup

After the first container startup, Uptime Kuma launched the initial setup wizard.

The configuration process included:

- database selection
- administrator account creation
- initial dashboard configuration
- monitor creation
- security settings

---

# Database Selection

Three database options were evaluated during deployment.

<img width="992" height="638" alt="database" src="https://github.com/user-attachments/assets/c9fc95b6-ae9d-44f0-981e-628be739b677" />

---

## Embedded MariaDB

Rejected.

Reason:

- requires more resources
- unnecessary complexity for a small VM deployment
- overkill for a lightweight homelab setup

---

## External MariaDB / MySQL

Rejected.

Reason:

- requires separate database server
- introduces additional administration overhead
- unnecessary for a single-instance monitoring setup

---

## SQLite

Selected.

Reason:

- zero configuration
- officially recommended for single-instance deployments
- lightweight
- data stored in a single file
- persistent Docker volume already protected application data
---

# Administrator Account

An administrator account was created during the initial setup process.

The account was used for:

- dashboard management
- monitor configuration
- notification settings
- security configuration

<img width="883" height="708" alt="Zrzut ekranu 2026-05-27 o 20 24 09" src="https://github.com/user-attachments/assets/c2a82790-c4aa-43d0-846c-5ef9b89c2f93" />
---

# Security Configuration

## Two-Factor Authentication

2FA was enabled for the administrator account.

Purpose:

- additional account protection
- reduced risk of credential compromise

<img width="630" height="545" alt="Zrzut ekranu 2026-05-28 o 09 59 17" src="https://github.com/user-attachments/assets/06f65962-885a-4e32-93af-392790f41064" />

---

## Third-Party Authentication

Third-party authentication providers were intentionally not configured.

Reason:

- deployment was designed for internal homelab usage only
- no public internet exposure planned
- reduced configuration complexity
