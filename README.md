# Fail2Ban Management Tool

## Overview
The **Fail2Ban Management Tool** is a Bash script designed to automate the installation, configuration, and management of Fail2Ban on Kali Linux. It provides an intuitive interface to manage Fail2Ban services, configure settings, and monitor logs, making it an essential tool for system administrators.

---

## Features
- **Installation**:
  - Automatically checks and installs Fail2Ban if not already installed.
  - Ensures the service is active and running.

- **Configuration**:
  - Allows customization of `bantime`, `maxretry`, and `ignoreip`.
  - Supports editing and validation of `jail.local` for specific services like SSH.

- **IP Management**:
  - Ban or unban IPs manually.
  - View the list of currently banned IPs.
  - Add IPs to a permanent whitelist.

- **Logs and Monitoring**:
  - Display the full Fail2Ban log file.
  - Monitor logs in real-time.
  - View ban statistics by service.

- **Service Management**:
  - Check the status of the Fail2Ban service.
  - Restart the service when necessary.

---

## Requirements
- **Kali Linux** or any Debian-based distribution.
- Root privileges to execute the script.

---

## Installation :  Clone this repository to your local machine
   ```bash
   git clone https://github.com/yourusername/fail2ban-management-tool.git
   cd fail2ban-management-tool
  chmod +x fail2ban.sh
  sudo ./fail2ban.sh
```
## USAGE
```bash
sudo ./fail2ban.sh
