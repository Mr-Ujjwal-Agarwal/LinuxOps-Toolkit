#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Utility : User Interface
# Version : 1.0.0
# ==========================================================

source utils/colors.sh

# ==========================================================
# Screen Functions
# ==========================================================

clear_screen() {

    clear

}

pause_screen() {

    echo
    read -rp "Press Enter to continue..."

}

# ==========================================================
# Banner
# ==========================================================

show_banner() {

    clear

    separator

    heading "              LinuxOps Toolkit v1.0"

    info "Professional Linux Administration Toolkit"

    separator

}

# ==========================================================
# System Information
# ==========================================================

show_system_info() {

    local hostname=$(hostname)
    local username=$(whoami)
    local os=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)
    local kernel=$(uname -r)
    local uptime=$(uptime -p)

    local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2+$4"%"}')

    local ram=$(free -h | awk '/Mem:/ {print $3 " / " $2}')

    local disk=$(df -h / | awk 'NR==2 {print $5}')

    info "Hostname : $hostname"
    info "User     : $username"
    info "OS       : $os"
    info "Kernel   : $kernel"
    info "Uptime   : $uptime"
    info "CPU      : $cpu"
    info "RAM      : $ram"
    info "Disk     : $disk"

    separator

}

# ==========================================================
# Page
# ==========================================================

show_page() {

    local page_title="$1"

    clear_screen

    show_banner

    heading "$page_title"

}

# ==========================================================
# Current Working Directory
# ==========================================================

show_working_directory() {

    highlight "Current Directory"

    echo

    pwd

    separator

}

# ==========================================================
# Menu Helpers
# ==========================================================

show_menu_option() {

    printf "%-3s %s\n" "$1." "$2"

}

show_menu_title() {

    separator

    heading "$1"

    separator

}

# ==========================================================
# Footer
# ==========================================================

show_footer() {

    separator

    info "LinuxOps Toolkit v1.0"

    separator

}

# ==========================================================
# Header For Modules
# ==========================================================

show_module() {

    local module_name="$1"

    show_page "$module_name"

    show_working_directory

}
