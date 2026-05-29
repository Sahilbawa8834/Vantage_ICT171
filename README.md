# Vantage

A cloud-hosted monitoring and server-status project for Murdoch ICT171.

## Project Identity

- **Student Name:** Sahil Bawa
- **Student Number:** 35734862
- **Unit:** ICT171 — Introduction to Server Environments and Architectures
- **Semester:** 2026 S1
- **Repository:** https://github.com/Sahilbawa8834/Vantage_ICT171
- **Live site:** https://vantageproject.me/

## Overview

Vantage is a small cloud project built for ICT171. It runs on a DigitalOcean Ubuntu droplet behind Nginx and uses a Bash script, scheduled by cron, to perform recurring checks on the server and the website.

The project has two main parts:

- **Public route** at `https://vantageproject.me/` — explains the project, technical stack, roadmap, and security features.
- **Protected admin route** at `https://vantageproject.me/admin/` — shows the live operational dashboard, protected by Nginx basic authentication.

This separation keeps detailed monitoring information private and improves overall security awareness.

## Live System

- **Public site:** https://vantageproject.me/
- **Admin dashboard:** https://vantageproject.me/admin/ (authentication required)
- **Public IP:** 134.199.167.21
- **HTTPS:** Enabled with Let’s Encrypt and Certbot

## Architecture

DigitalOcean droplet (Ubuntu 24.04 LTS)
└── Nginx
├── / — public project page
├── /admin/ — protected admin dashboard
│ └── /admin/status.json — protected monitoring output
└── /wp-admin — honeypot decoy path

Cron runs `/usr/local/bin/vantage_check.sh` every 5 minutes.  
fail2ban protects SSH from repeated failed login attempts.

In simple terms, the cron job executes the Bash script every five minutes, which performs checks and writes results to `admin/status.json`. The admin dashboard then displays this data after authentication.

## Technical Stack

| Layer                  | Technology                |
| ---------------------- | ------------------------- |
| Cloud provider         | DigitalOcean (IaaS)       |
| Operating system       | Ubuntu 24.04 LTS          |
| Web server             | Nginx                     |
| Domain                 | vantageproject.me         |
| HTTPS                  | Let’s Encrypt via Certbot |
| Automation             | Bash + cron               |
| Check tools            | curl, openssl, sha256sum  |
| Brute-force protection | fail2ban                  |
| Version control        | Git + GitHub              |

## License

MIT

## Monitoring Checks

The check script performs five checks every five minutes and writes the results to a JSON file for the admin dashboard.

**CHK-01 — Uptime**  
Checks whether the public site is reachable and records the response status and response time.

**CHK-02 — TLS Certificate Expiry**  
Checks the live TLS certificate and reports how many days remain before expiry.

**CHK-03 — Security Headers**  
Verifies the presence of recommended security headers:

- HSTS
- Content-Security-Policy
- X-Frame-Options
- X-Content-Type-Options
- Referrer-Policy

**CHK-04 — Content Integrity**  
Uses a SHA-256 hash to compare the deployed homepage against a known-good baseline to detect unexpected changes.

**CHK-07 — Server Self-Check**  
Collects host-level metrics including CPU, memory, disk usage, uptime, and load average.

## Security Features

- HTTPS enabled with Let’s Encrypt
- Protected admin dashboard using Nginx basic authentication
- `status.json` not publicly accessible
- Nginx security headers enabled
- Content integrity baseline checking
- Dedicated admin access logging
- Honeypot decoy path at `/wp-admin`
- fail2ban enabled for SSH brute-force protection

## File Paths

**Site files:**

- `/var/www/html/index.html` — public homepage
- `/var/www/html/admin/index.html` — admin dashboard
- `/var/www/html/admin/status.json` — monitoring output

**Monitoring and integrity:**

- `/usr/local/bin/vantage_check.sh` — monitoring script (run by cron)
- `/var/lib/vantage/baseline.sha256` — content integrity baseline

**Logs:**

- `/var/log/vantage.log` — script log
- `/var/log/nginx/vantage_admin_access.log` — admin route log
- `/var/log/nginx/vantage_honeypot_access.log` — honeypot log

**Authentication:**

- `/etc/nginx/.htpasswd` — admin authentication file

## How to Verify

A marker can verify the system by checking:

- Public page loads correctly over HTTPS
- `/admin/` requires authentication
- `/admin/status.json` is not publicly accessible
- Admin dashboard shows recent monitoring results
- Security headers are present
- Honeypot path `/wp-admin` responds and logs access attempts
- fail2ban is active for SSH protection

## Roadmap

**Stage 1** — Cloud foundation and live checks (Complete)  
**Stage 2** — DNS, HTTPS, and TLS certificate check (Complete)  
**Stage 3** — Documentation and hardening (In progress)

## Scope

Vantage only performs checks against its own server and the project website (`https://vantageproject.me/`). It is not designed to monitor or target other systems.

## Access Note

**Admin Credentials** (for assessment only):

- **Username:** `admin`
- **Password:** Shared privately

Live credentials are not stored in the public repository.

## Author

**Sahil Bawa**  
Murdoch University
Student Number: 35734862  
Unit: ICT171 — Introduction to Server Environments and Architectures
