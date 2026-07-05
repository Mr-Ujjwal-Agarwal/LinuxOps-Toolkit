#!/bin/bash

source config/config.sh
source utils/colors.sh

clear_screen() {

    clear

}

print_banner() {

    title "=============================================================="

    echo

    title "               LinuxOps Toolkit v1.0"

    echo

    info "        Professional Linux Administration Suite"

    echo

    title "=============================================================="

    echo

}

system_information() {

    HOST=$(hostname)

    USERNAME=$(whoami)

    OS=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')

    KERNEL=$(uname -r)

    UPTIME=$(uptime -p)

    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2+$4"%"}')

    RAM=$(free -h | awk '/Mem:/ {print $3 "/" $2}')

    DISK=$(df -h / | awk 'NR==2 {print $5}')

    echo "Hostname : $HOST"

    echo "User     : $USERNAME"

    echo "OS       : $OS"

    echo "Kernel   : $KERNEL"

    echo "Uptime   : $UPTIME"

    echo "CPU      : $CPU"

    echo "RAM      : $RAM"

    echo "Disk     : $DISK"

    echo

}

print_menu() {

echo "1. File Management"

echo "2. Backup & Restore"

echo "3. Log Analyzer"

echo "4. User Management"

echo "5. Disk Utilities"

echo "6. Process Manager"

echo "7. Service Manager"

echo "8. Package Manager"

echo "9. Network Utilities"

echo "10. System Health"

echo "11. Security Audit"

echo "12. About"

echo "13. Exit"

echo

}
