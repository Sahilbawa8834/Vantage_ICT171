# Vantage

## ICT171 Cloud Project Proposal and Development Repository

**Student Name:** Sahil Bawa  
**Student Number:** 35734862  
**Unit:** ICT171 — Introduction to Server Environments and Architectures  
**Cloud Provider:** DigitalOcean  
**Server Type:** Ubuntu Linux VPS  
**Web Server:** Nginx  

## Live Server
**Public IP Address:** 134.199.167.21

## Project Overview
Vantage is a cloud-based monitoring and change detection platform deployed on a Linux virtual machine and made accessible through a public IP address and domain name. The purpose of the project is to build a practical system that monitors both internal server activity and selected external web content from a single hosted environment.

The platform is intended to collect and display useful system information such as CPU usage, memory usage, disk usage, service availability, and authentication log activity. These checks will be automated using scripts that run on the server at regular intervals, reducing the need for manual monitoring and demonstrating practical server administration skills.

In addition to internal system monitoring, Vantage will periodically check selected public web pages and record when important content changes occur. This allows the project to demonstrate Linux server deployment, web hosting, automation, logging, and change detection in a real cloud environment.

## Project Goals
- Deploy and configure a Linux virtual server in the cloud
- Host a public webpage using Nginx
- Link the server to a domain name
- Document the setup process clearly
- Add scripting to automate monitoring tasks
- Extend the project into a more structured monitoring platform over time

## Planned Development Stages

### Stage 1
- Deploy the Ubuntu virtual server
- Configure Nginx
- Publish the proposal webpage
- Establish remote administration through SSH
- Document the setup process on GitHub

### Stage 2
- Add scripts to monitor service availability
- Record CPU, memory, and disk usage
- Review selected authentication log activity
- Organise the collected results clearly

### Stage 3
- Add external web page change detection
- Build a simple dashboard-style presentation of results
- Configure HTTPS
- Apply stronger server hardening measures

## Current Progress
- [x] DigitalOcean account created
- [x] Ubuntu virtual server deployed
- [x] SSH access configured
- [x] Nginx installed
- [x] Proposal webpage uploaded to live server
- [x] GitHub repository created
- [ ] Domain name linked
- [ ] Monitoring scripts added
- [ ] HTTPS configured
- [ ] Dashboard features added

## Technologies Used
- Ubuntu Linux
- Nginx
- HTML/CSS
- SSH
- DigitalOcean
- GitHub

## License
This project is released under the MIT License.
