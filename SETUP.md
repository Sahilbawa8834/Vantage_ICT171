# Vantage Setup Notes

## Project Overview
Vantage is a cloud-based monitoring and change detection platform developed for ICT171.  
The project is hosted on a Linux virtual server and currently presents a public webpage through Nginx.  
Its broader purpose is to develop a practical cloud environment that can later be extended with monitoring scripts, logging, website change detection, and security improvements.

---

## Server Information
- **Cloud Provider:** DigitalOcean
- **Server Type:** Ubuntu Linux Virtual Private Server (VPS)
- **Web Server:** Nginx
- **Public IP Address:** 134.199.167.21
- **Project Name:** Vantage

---

## Repository Information
- **GitHub Repository:** `Vantage_ICT171`
- **Main Files Included:**
  - `index.html`
  - `README.md`
  - `LICENSE`
  - `SETUP.md`

This repository stores the project webpage, project documentation, setup notes, and licensing information.

---

## Initial Cloud Deployment
The first stage of the project involved creating a new Ubuntu-based Droplet on DigitalOcean.  
DigitalOcean was selected because it provides direct SSH access, simple deployment, and a practical Infrastructure as a Service environment suitable for learning Linux administration and cloud hosting.

The virtual server was configured with:
- Ubuntu 24.04 LTS
- Shared CPU basic plan
- SSH key authentication
- Public IP access

---

## SSH Key Configuration
Secure remote access to the server was set up using an SSH key pair generated on macOS Terminal.

### SSH key generation command
```bash
ssh-keygen -t ed25519 -f ~/.ssh/vantage_do_key -C "vantage-do-key"
