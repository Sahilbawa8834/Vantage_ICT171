# Vantage Setup Notes

## Project Overview

Vantage is a cloud-hosted monitoring and server-status project built for Murdoch ICT171. It runs on a DigitalOcean Ubuntu droplet behind Nginx and uses a single Bash script, scheduled by cron, to perform recurring checks on the host and the project webpage. These checks include server self-health, HTTP uptime, a response-header security audit, and a SHA-256 content-integrity hash of the homepage. The results are written to a JSON file and displayed in a live dashboard on the website.

## Server Information

- **Cloud Provider:** DigitalOcean
- **Operating System:** Ubuntu 24.04 LTS
- **Web Server:** Nginx
- **Public IP:** 134.199.167.21

## Initial Access

SSH access was configured using an SSH key generated on macOS.

```bash
ssh -i ~/.ssh/vantage_do_key root@134.199.167.21
