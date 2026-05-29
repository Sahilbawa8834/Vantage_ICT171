# SETUP — Vantage (ICT171)

This file explains how Vantage was built and how the project could be rebuilt on a fresh Ubuntu server.

## Project context

- **Cloud provider:** DigitalOcean
- **Operating system:** Ubuntu 24.04 LTS
- **Web server:** Nginx
- **Domain:** vantageproject.me
- **HTTPS:** Let's Encrypt + Certbot
- **Automation:** Bash + cron
- **Security tool:** fail2ban
- **Repository:** https://github.com/Sahilbawa8834/Vantage_ICT171

---

## 1. Project overview

Vantage started as a simple cloud-hosted project page and later developed into a monitored server project with a separate protected admin dashboard.

The final structure is:

- **Public route** at `/`  
  This shows the project overview, roadmap, technical stack, and security features.

- **Protected admin route** at `/admin/`  
  This shows the live monitoring dashboard and is protected with Nginx basic authentication.

- **Protected monitoring output** at `/admin/status.json`  
  This is used by the admin dashboard and is not exposed publicly.

---

## 2. Create the cloud server

A DigitalOcean droplet was created using Ubuntu 24.04 LTS.

The project used:

- a Basic plan droplet
- SSH access for administration
- Nginx as the web server

After the droplet was created, the system was updated and Nginx was installed and enabled.

The main idea at this stage was to get a working Linux server online and accessible from the Internet.

---

## 3. Connect to the server

The server was administered through SSH.

A key-based SSH setup was used instead of relying only on password login. This made the server easier to manage securely from a local terminal.

After connecting, the first steps were:

- update packages
- install Nginx
- confirm the web server was running

---

## 4. Deploy the public website

The public homepage was placed in:

/var/www/html/index.html

This became the main project page visible at:
https://vantageproject.me/
At this stage, the site was mainly used to present the project and explain what Vantage was.

## 5. Configure the domain

The domain used for the project was:
vantageproject.me
An A record was pointed at the droplet’s public IP address.
After DNS propagation, Nginx was updated so the site would respond correctly to the domain name rather than only the raw server IP.
This made the project look more complete and also prepared it for HTTPS.

## 6. Enable HTTPS

HTTPS was added using Let’s Encrypt and Certbot.
This allowed the site to:

- use encrypted HTTPS connections
- present a valid TLS certificate
- support the live certificate-expiry check in the monitoring script

After this step, the project was accessible securely over HTTPS.

## 7. Add the monitoring script

The main monitoring script is:
/usr/local/bin/vantage_check.sh
It was written in Bash and designed to run automatically every five minutes.
The script checks:

- uptime
- TLS certificate expiry
- security headers
- content integrity
- server health

It writes the latest monitoring output to:
/var/www/html/admin/status.json
This file is then read by the admin dashboard.

## 8. Automate the script with cron

Cron was used to run the script every 5 minutes.
This makes the project work like a live monitored service rather than something that only updates when run manually.
The cron job writes to a log file so recent runs can be checked later if needed.
Main script log:
/var/log/vantage.log

## 9. Build the protected admin dashboard

The admin dashboard was placed in:
/var/www/html/admin/index.html
This dashboard is separate from the public page and shows:

- monitoring results
- host metrics
- check grades and details
- security controls summary

The dashboard reads from:
/var/www/html/admin/status.json
This route was intentionally kept separate from the public homepage so detailed server-health information would not be exposed openly.

## 10. Protect the admin route

The /admin/ route was protected using Nginx basic authentication.
The credentials file is stored at:
/etc/nginx/.htpasswd
This means:

- the public page remains open
- the admin dashboard requires authentication
- the protected JSON file is also behind the same auth wall

This was one of the most important security improvements made during the project.

## 11. Monitoring checks implemented

CHK-01 — Uptime
Checks if the public site is reachable and records the response time.

CHK-02 — TLS expiry
Checks the live certificate and reports how many days remain before it expires.

CHK-03 — Security headers
Checks whether the site is sending the main recommended security headers:

- HSTS
- Content-Security-Policy
- X-Frame-Options
- X-Content-Type-Options
- Referrer-Policy

CHK-04 — Content integrity
Uses a SHA-256 baseline file to detect unexpected homepage changes.
Baseline file:
/var/lib/vantage/baseline.sha256

CHK-07 — Server self-check
Collects server-level information such as:

- CPU usage
- memory usage
- disk usage
- uptime
- load average

## 12. Add security headers

Security headers were added in the Nginx HTTPS configuration.
These included:

- Strict-Transport-Security
- Content-Security-Policy
- X-Frame-Options
- X-Content-Type-Options
- Referrer-Policy

This improved the security-headers check and made the site more security-aware.

## 13. Improve logging

Separate logging was added so that sensitive areas of the project were easier to review.

- Admin access log: /var/log/nginx/vantage_admin_access.log
- Honeypot log: /var/log/nginx/vantage_honeypot_access.log

This made it easier to distinguish normal public traffic from admin access and suspicious requests.

## 14. Add a honeypot-style decoy path

A decoy route was added at:
/wp-admin
This route does not expose anything real. It is only there to record opportunistic scanning or probing requests.
This gave the project a more security-focused feel without adding unnecessary complexity.

## 15. Add fail2ban

Fail2ban was enabled for SSH brute-force protection.
This means repeated failed SSH login attempts can be monitored and abusive IPs can be banned automatically.
This was added as a small but practical hardening step for the server.

## 16. Important file paths

Public page

- /var/www/html/index.html

Admin dashboard

- /var/www/html/admin/index.html

Protected monitoring output

- /var/www/html/admin/status.json

Monitoring script

- /usr/local/bin/vantage_check.sh

Integrity baseline

- /var/lib/vantage/baseline.sha256

Auth file

- /etc/nginx/.htpasswd

Logs

- /var/log/vantage.log
- /var/log/nginx/vantage_admin_access.log
- /var/log/nginx/vantage_honeypot_access.log

## 17. Verification

A marker or another student can verify the project by checking that:

- the public site loads over HTTPS
- the admin route asks for authentication
- /admin/status.json is protected
- the old public status.json is no longer exposed
- the admin dashboard shows recent values
- the security headers are present
- the honeypot path responds and logs access
- fail2ban is active for SSH

## 18. Rebuild summary

To rebuild Vantage from scratch, the main steps are:

1. create the Ubuntu droplet
2. connect through SSH
3. install and configure Nginx
4. upload the public and admin pages
5. connect the domain
6. enable HTTPS
7. install the monitoring script
8. set up cron automation
9. protect /admin/ with basic auth
10. move monitoring output behind the admin route
11. add security headers
12. add separate logging
13. add the honeypot route
14. enable fail2ban
15. verify the final system

## 19. Final note

The final version of Vantage is more security-aware than the original basic hosted page. It now combines:

- a public-facing project site
- a protected admin dashboard
- live automated monitoring
- integrity checking
- HTTPS
- hardening measures
- logging improvements
- SSH brute-force protection
