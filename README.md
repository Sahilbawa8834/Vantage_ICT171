# Vantage

## ICT171 Cloud Server Project

**Student Name:** Sahil Bawa  
**Student Number:** 35734862  
**Unit:** ICT171 — Introduction to Server Environments and Architectures  
**Cloud Provider:** DigitalOcean  
**Server Type:** Ubuntu 24.04 LTS VPS  
**Web Server:** Nginx  

## Live System

**Public IP Address:** 134.199.167.21

Vantage is a cloud-hosted monitoring and server-status project built for Murdoch ICT171. It runs on a DigitalOcean Ubuntu droplet behind Nginx and uses a single Bash script, scheduled by cron, to perform recurring checks on the host and the project webpage. These checks include server self-health, HTTP uptime, a response-header security audit, and a SHA-256 content-integrity hash of the homepage. The results are written to a JSON file and displayed in a live dashboard on the website.

## Architecture

Vantage runs on a DigitalOcean Ubuntu droplet.  
Nginx serves the public website from `/var/www/html/`.  
A cron job runs `vantage_check.sh` every five minutes.  
The script writes the latest results to `/var/www/html/status.json`.  
The webpage reads `status.json` and displays the current check results in the dashboard.

## Implemented Checks

### CHK-01 — Uptime & Response
Sends an HTTP request to the project webpage and records the status code and response time.

### CHK-02 — TLS Certificate Expiry
Planned for Stage 2 after HTTPS is enabled.

### CHK-03 — Security Headers
Checks for common response headers:
- HSTS
- Content-Security-Policy
- X-Frame-Options
- X-Content-Type-Options
- Referrer-Policy

### CHK-04 — Content Integrity
Calculates a SHA-256 hash of the homepage and compares it with a stored baseline.

### CHK-07 — Server Self-Check
Collects CPU usage, memory usage, disk usage, and uptime from the host.

## Current Status

- [x] DigitalOcean droplet provisioned
- [x] Ubuntu 24.04 LTS installed
- [x] SSH key authentication configured
- [x] Nginx installed and serving the site
- [x] `vantage_check.sh` deployed
- [x] Cron job configured
- [x] `status.json` being generated
- [x] Live dashboard reading real output
- [x] GitHub repository created
- [ ] Domain configured
- [ ] HTTPS enabled
- [ ] Real TLS certificate expiry check activated

## Roadmap

### Stage 1 — Cloud foundation and live checks
- Provision Ubuntu droplet
- Configure Nginx
- Set up SSH key authentication
- Publish project page on public IP
- Deploy Bash check script through cron
- Write results to `/var/www/html/status.json`

### Stage 2 — DNS, HTTPS, and real TLS check
- Register or use a domain
- Point DNS to the droplet
- Update Nginx `server_name`
- Install Certbot and enable Let's Encrypt HTTPS
- Activate CHK-02 with a real certificate-expiry check

### Stage 3 — Documentation, verification, and small improvements
- Finalise `README.md` and `SETUP.md`
- Add a clear “How to verify” section
- Tidy logging and maintenance
- Produce the final PDF report

## How to Verify

Check that the site is live:

```bash
curl -I http://134.199.167.21
