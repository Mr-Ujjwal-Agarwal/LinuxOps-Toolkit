#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Module : System Information
# Version : 1.0.0
# ==========================================================

source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/logger.sh
source utils/loader.sh

MODULE_NAME="SYSTEM_INFORMATION"

# ==========================================================
# Helper Functions
# ==========================================================

system_success() {

    log_success \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

system_failure() {

    log_error \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

# ==========================================================
# System Dashboard
# ==========================================================

system_dashboard() {

    show_module "System Dashboard"

    os=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')

    kernel=$(uname -r)

    hostname=$(hostname)

    uptime_info=$(uptime -p)

    ip_address=$(hostname -I | awk '{print $1}')

    echo

    highlight "System Summary"

    separator

    printf "%-24s : %s\n" "Hostname" "$hostname"

    printf "%-24s : %s\n" "Operating System" "$os"

    printf "%-24s : %s\n" "Kernel" "$kernel"

    printf "%-24s : %s\n" "IP Address" "$ip_address"

    printf "%-24s : %s\n" "Uptime" "$uptime_info"

    echo

    pause_screen

}

# ==========================================================
# Operating System
# ==========================================================

os_information() {

    show_module "Operating System"

    echo

    cat /etc/os-release

    echo

    system_success \
    "OS_INFORMATION" \
    "Viewed OS information"

    pause_screen

}

# ==========================================================
# Kernel Information
# ==========================================================

kernel_information() {

    show_module "Kernel Information"

    echo

    uname -a

    echo

    system_success \
    "KERNEL_INFORMATION" \
    "Viewed kernel information"

    pause_screen

}

# ==========================================================
# CPU Information
# ==========================================================

cpu_information() {

    show_module "CPU Information"

    echo

    lscpu

    echo

    system_success \
    "CPU_INFORMATION" \
    "Viewed CPU information"

    pause_screen

}

# ==========================================================
# Memory Information
# ==========================================================

memory_information() {

    show_module "Memory Information"

    echo

    free -h

    echo

    system_success \
    "MEMORY_INFORMATION" \
    "Viewed memory information"

    pause_screen

}

# ==========================================================
# Disk Information
# ==========================================================

disk_information() {

    show_module "Disk Information"

    echo

    lsblk

    echo

    df -h

    echo

    system_success \
    "DISK_INFORMATION" \
    "Viewed disk information"

    pause_screen

}



# ==========================================================
# Network Information
# ==========================================================

network_information() {

    show_module "Network Information"

    echo

    ip -br address

    echo

    ip route

    echo

    system_success \
    "NETWORK_INFORMATION" \
    "Viewed network information"

    pause_screen

}

# ==========================================================
# BIOS Information
# ==========================================================

bios_information() {

    show_module "BIOS Information"

    echo

    if command -v dmidecode >/dev/null 2>&1
    then

        sudo dmidecode -t bios

    else

        warning "dmidecode is not installed."

    fi

    echo

    system_success \
    "BIOS_INFORMATION" \
    "Viewed BIOS information"

    pause_screen

}

# ==========================================================
# Virtualization Detection
# ==========================================================

virtualization_information() {

    show_module "Virtualization"

    echo

    if command -v systemd-detect-virt >/dev/null 2>&1
    then

        systemd-detect-virt

    else

        warning "Unable to detect virtualization."

    fi

    echo

    system_success \
    "VIRTUALIZATION" \
    "Viewed virtualization information"

    pause_screen

}

# ==========================================================
# Hostname Information
# ==========================================================

hostname_information() {

    show_module "Hostname Information"

    echo

    hostnamectl

    echo

    system_success \
    "HOSTNAME_INFORMATION" \
    "Viewed hostname information"

    pause_screen

}

# ==========================================================
# System Uptime
# ==========================================================

system_uptime() {

    show_module "System Uptime"

    echo

    uptime

    echo

    uptime -p

    echo

    system_success \
    "SYSTEM_UPTIME" \
    "Viewed uptime"

    pause_screen

}

# ==========================================================
# Export System Report
# ==========================================================

system_report() {

    show_module "Generate System Report"

    mkdir -p reports

    report="reports/system_report_$(date +%Y%m%d_%H%M%S).txt"

    {

        echo "======================================"
        echo " LinuxOps Toolkit System Report"
        echo "======================================"

        echo
        echo "Generated : $(date)"

        echo
        echo "Hostname"
        hostnamectl

        echo
        echo "Operating System"
        cat /etc/os-release

        echo
        echo "Kernel"
        uname -a

        echo
        echo "CPU"
        lscpu

        echo
        echo "Memory"
        free -h

        echo
        echo "Disk"
        lsblk

        echo
        df -h

        echo
        echo "Network"
        ip addr

        echo
        ip route

    } > "$report"

    success "System report generated."

    info "$report"

    system_success \
    "SYSTEM_REPORT" \
    "$report"

    pause_screen

}

# ==========================================================
# Menu
# ==========================================================

system_information_menu() {

    while true
    do

        show_module "System Information"

        show_menu_option 1  "System Dashboard"
        show_menu_option 2  "Operating System"
        show_menu_option 3  "Kernel Information"
        show_menu_option 4  "CPU Information"
        show_menu_option 5  "Memory Information"
        show_menu_option 6  "Disk Information"
        show_menu_option 7  "Network Information"
        show_menu_option 8  "BIOS Information"
        show_menu_option 9  "Virtualization"
        show_menu_option 10 "Hostname Information"
        show_menu_option 11 "System Uptime"
        show_menu_option 12 "Generate System Report"

        separator

        show_menu_option 0 "Back"

        separator

        read -rp "Select Option : " option

        case "$option" in

            1) system_dashboard ;;
            2) os_information ;;
            3) kernel_information ;;
            4) cpu_information ;;
            5) memory_information ;;
            6) disk_information ;;
            7) network_information ;;
            8) bios_information ;;
            9) virtualization_information ;;
            10) hostname_information ;;
            11) system_uptime ;;
            12) system_report ;;
            0) break ;;

            *)

                warning "Invalid Option."

                sleep 1

                ;;

        esac

    done

}

# ==========================================================
# Module Entry
# ==========================================================

system_information_manager() {

    system_information_menu

}

# ==========================================================
# Execute Directly
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then

    system_information_manager

fi
