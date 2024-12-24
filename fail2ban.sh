#!/bin/bash

# Fail2Ban Management Tool
# Author: [Your Name]
# Version: 1.0
# Description: Automates the installation, configuration, and management of Fail2Ban on Kali Linux.

LOG_FILE="./fail2ban_management.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# =======================
# LOGGING FUNCTION
# =======================
function log_action() {
    echo "[$DATE] $1" | tee -a "$LOG_FILE"
}

# =======================
# ROOT CHECK FUNCTION
# =======================
function check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_action "[-] Please run this script as root."
        exit 1
    fi
}

# =======================
# INSTALL REQUIRED PACKAGES
# =======================
function install_fail2ban() {
    log_action "[+] Checking for Fail2Ban installation..."
    if command -v fail2ban-server &>/dev/null; then
        log_action "[+] Fail2Ban is already installed."
    else
        log_action "[-] Fail2Ban is not installed. Installing..."
        apt-get update -y
        apt-get install -y fail2ban
        if [[ $? -eq 0 ]]; then
            log_action "[+] Fail2Ban installed successfully."
        else
            log_action "[-] Failed to install Fail2Ban."
            exit 1
        fi
    fi

    log_action "[+] Ensuring Fail2Ban service is running..."
    systemctl enable --now fail2ban
    if systemctl is-active --quiet fail2ban; then
        log_action "[+] Fail2Ban service is active and running."
    else
        log_action "[-] Fail2Ban service failed to start."
        exit 1
    fi
}

# =======================
# CONFIGURE FAIL2BAN
# =======================
function configure_fail2ban() {
    local jail_file="/etc/fail2ban/jail.local"

    log_action "[+] Configuring Fail2Ban..."
    if [[ ! -f $jail_file ]]; then
        log_action "[+] Creating jail.local configuration file..."
        cat >"$jail_file" <<EOL
[DEFAULT]
bantime = 10m
findtime = 10m
maxretry = 5
ignoreip = 127.0.0.1/8

[sshd]
enabled = true
EOL
        log_action "[+] Default configuration for Fail2Ban added."
    fi

    while true; do
        clear
        echo "=========================="
        echo "   Configure Fail2Ban     "
        echo "=========================="
        echo "1. Edit Ban Time (bantime)"
        echo "2. Edit Max Retries (maxretry)"
        echo "3. Add or Remove Ignored IPs"
        echo "4. Show Current Configuration"
        echo "0. Return to Main Menu"
        read -p "Choose an option: " CONFIG_OPTION

        case $CONFIG_OPTION in
            1)
                read -p "Enter new bantime (e.g., 10m, 1h): " bantime
                sed -i "s/^bantime = .*/bantime = $bantime/" "$jail_file"
                log_action "[+] Bantime updated to $bantime."
                ;;
            2)
                read -p "Enter new maxretry value: " maxretry
                sed -i "s/^maxretry = .*/maxretry = $maxretry/" "$jail_file"
                log_action "[+] Maxretry updated to $maxretry."
                ;;
            3)
                read -p "Enter IP to ignore (e.g., 192.168.1.1): " ignoreip
                if grep -q "^ignoreip = " "$jail_file"; then
                    sed -i "s/^ignoreip = .*/& $ignoreip/" "$jail_file"
                else
                    echo "ignoreip = $ignoreip" >>"$jail_file"
                fi
                log_action "[+] IP $ignoreip added to ignore list."
                ;;
            4)
                log_action "[+] Current configuration:"
                cat "$jail_file"
                ;;
            0) break ;;
            *) log_action "[-] Invalid option. Please try again." ;;
        esac
    done

    systemctl restart fail2ban
    log_action "[+] Fail2Ban service restarted to apply changes."
}

# =======================
# MANAGE BANNED IPS
# =======================
function manage_banned_ips() {
    while true; do
        clear
        echo "=========================="
        echo "    Manage Banned IPs     "
        echo "=========================="
        echo "1. List Banned IPs"
        echo "2. Ban an IP Manually"
        echo "3. Unban an IP"
        echo "4. Add IP to Whitelist"
        echo "0. Return to Main Menu"
        read -p "Choose an option: " BAN_OPTION

        case $BAN_OPTION in
            1)
                log_action "[+] Listing banned IPs..."
                fail2ban-client status sshd | grep -i banned
                ;;
            2)
                read -p "Enter IP to ban: " ip
                fail2ban-client set sshd banip "$ip"
                log_action "[+] IP $ip has been banned."
                ;;
            3)
                read -p "Enter IP to unban: " ip
                fail2ban-client set sshd unbanip "$ip"
                log_action "[+] IP $ip has been unbanned."
                ;;
            4)
                read -p "Enter IP to whitelist: " ip
                configure_fail2ban_add_ignoreip "$ip"
                ;;
            0) break ;;
            *) log_action "[-] Invalid option. Please try again." ;;
        esac
    done
}

# =======================
# VIEW LOGS AND STATISTICS
# =======================
function view_logs() {
    while true; do
        clear
        echo "=========================="
        echo "  View Logs and Stats     "
        echo "=========================="
        echo "1. Show Full Log File"
        echo "2. View Logs in Real-Time"
        echo "3. Show Ban Statistics"
        echo "0. Return to Main Menu"
        read -p "Choose an option: " LOG_OPTION

        case $LOG_OPTION in
            1)
                log_action "[+] Showing full log file:"
                cat /var/log/fail2ban.log
                ;;
            2)
                log_action "[+] Viewing logs in real-time:"
                tail -f /var/log/fail2ban.log
                ;;
            3)
                log_action "[+] Ban statistics:"
                fail2ban-client status sshd
                ;;
            0) break ;;
            *) log_action "[-] Invalid option. Please try again." ;;
        esac
    done
}

# =======================
# CHECK AND RESTART SERVICE
# =======================
function check_and_restart_service() {
    log_action "[+] Checking Fail2Ban service status..."
    if systemctl is-active --quiet fail2ban; then
        log_action "[+] Fail2Ban service is running."
    else
        log_action "[-] Fail2Ban service is not running. Restarting..."
        systemctl restart fail2ban
        if systemctl is-active --quiet fail2ban; then
            log_action "[+] Fail2Ban service restarted successfully."
        else
            log_action "[-] Failed to restart Fail2Ban service."
        fi
    fi
}

# =======================
# MAIN MENU
# =======================
function main_menu() {
    while true; do
        clear
        echo "==================================="
        echo "       Fail2Ban Management Tool    "
        echo "==================================="
        echo "1. Install Fail2Ban"
        echo "2. Configure Fail2Ban"
        echo "3. Manage Banned IPs"
        echo "4. View Logs and Statistics"
        echo "5. Check and Restart Service"
        echo "0. Exit"
        read -p "Choose an option: " MAIN_OPTION

        case $MAIN_OPTION in
            1) install_fail2ban ;;
            2) configure_fail2ban ;;
            3) manage_banned_ips ;;
            4) view_logs ;;
            5) check_and_restart_service ;;
            0) exit 0 ;;
            *) log_action "[-] Invalid option. Please try again." ;;
        esac
    done
}

# =======================
# EXECUTION
# =======================
check_root
main_menu
