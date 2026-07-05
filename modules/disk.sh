#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Module : Disk Management
# Version : 1.0.0
# ==========================================================

source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/logger.sh
source utils/loader.sh

MODULE_NAME="DISK_MANAGER"

# ==========================================================
# Helper Functions
# ==========================================================

disk_success() {

    log_success \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

disk_failure() {

    log_error \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

# ==========================================================
# Disk Dashboard
# ==========================================================

disk_dashboard() {

    show_module "Disk Dashboard"

    total_fs=$(df -h | tail -n +2 | wc -l)

    mounted=$(mount | wc -l)

    block_devices=$(lsblk -dn | wc -l)

    usage=$(df / | awk 'NR==2 {print $5}')

    echo

    highlight "Storage Summary"

    separator

    printf "%-25s : %s\n" "Mounted Filesystems" "$mounted"

    printf "%-25s : %s\n" "Block Devices" "$block_devices"

    printf "%-25s : %s\n" "Filesystems" "$total_fs"

    printf "%-25s : %s\n" "Root Usage" "$usage"

    echo

    pause_screen

}

# ==========================================================
# Filesystem Usage
# ==========================================================

filesystem_usage() {

    show_module "Filesystem Usage"

    echo

    df -hT

    echo

    disk_success \
    "FILESYSTEM_USAGE" \
    "Viewed filesystem usage"

    pause_screen

}

# ==========================================================
# Mounted Filesystems
# ==========================================================

mounted_filesystems() {

    show_module "Mounted Filesystems"

    echo

    mount

    echo

    disk_success \
    "MOUNTED_FILESYSTEMS" \
    "Viewed mounted filesystems"

    pause_screen

}

# ==========================================================
# Block Devices
# ==========================================================

block_devices() {

    show_module "Block Devices"

    echo

    lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT

    echo

    disk_success \
    "BLOCK_DEVICES" \
    "Viewed block devices"

    pause_screen

}

# ==========================================================
# Partition Information
# ==========================================================

partition_information() {

    show_module "Partition Information"

    echo

    lsblk -f

    echo

    disk_success \
    "PARTITION_INFORMATION" \
    "Viewed partition information"

    pause_screen

}

# ==========================================================
# Inode Usage
# ==========================================================

inode_usage() {

    show_module "Inode Usage"

    echo

    df -ih

    echo

    disk_success \
    "INODE_USAGE" \
    "Viewed inode usage"

    pause_screen

}
# ==========================================================
# Largest Files
# ==========================================================

largest_files() {

    show_module "Largest Files"

    read -rp "Directory (Default /): " directory

    directory=${directory:-/}

    validate_directory_exists "$directory" || return

    loading "Scanning Files..."

    echo

    find "$directory" -type f -exec du -h {} + 2>/dev/null \
    | sort -hr \
    | head -20

    echo

    disk_success \
    "LARGEST_FILES" \
    "$directory"

    pause_screen

}

# ==========================================================
# Largest Directories
# ==========================================================

largest_directories() {

    show_module "Largest Directories"

    read -rp "Directory (Default /): " directory

    directory=${directory:-/}

    validate_directory_exists "$directory" || return

    loading "Scanning Directories..."

    echo

    du -xh "$directory" 2>/dev/null \
    | sort -hr \
    | head -20

    echo

    disk_success \
    "LARGEST_DIRECTORIES" \
    "$directory"

    pause_screen

}

# ==========================================================
# Disk Cleanup
# ==========================================================

disk_cleanup() {

    show_module "Disk Cleanup"

    warning "Temporary files and package cache may be removed."

    read -rp "Continue? (y/n): " answer

    validate_yes_no "$answer"

    [[ $? -ne 0 ]] && return

    loading "Cleaning System..."

    sudo rm -rf /tmp/* 2>/dev/null

    if command -v apt >/dev/null 2>&1
    then

        sudo apt autoremove -y
        sudo apt autoclean -y

    elif command -v dnf >/dev/null 2>&1
    then

        sudo dnf autoremove -y
        sudo dnf clean all

    elif command -v yum >/dev/null 2>&1
    then

        sudo yum autoremove -y
        sudo yum clean all

    fi

    success "Cleanup completed."

    disk_success \
    "DISK_CLEANUP" \
    "Completed"

    pause_screen

}

# ==========================================================
# SMART Disk Health
# ==========================================================

smart_health() {

    show_module "SMART Health"

    if ! command -v smartctl >/dev/null 2>&1
    then

        warning "smartctl is not installed."

        info "Install package: smartmontools"

        pause_screen

        return

    fi

    read -rp "Disk (Example /dev/sda): " disk

    validate_not_empty "$disk" || return

    echo

    sudo smartctl -H "$disk"

    echo

    disk_success \
    "SMART_HEALTH" \
    "$disk"

    pause_screen

}

# ==========================================================
# LVM Information
# ==========================================================

lvm_information() {

    show_module "LVM Information"

    if ! command -v lvs >/dev/null 2>&1
    then

        warning "LVM tools are not installed."

        pause_screen

        return

    fi

    echo

    highlight "Physical Volumes"

    separator

    pvs

    echo

    highlight "Volume Groups"

    separator

    vgs

    echo

    highlight "Logical Volumes"

    separator

    lvs

    echo

    disk_success \
    "LVM_INFORMATION" \
    "Viewed LVM"

    pause_screen

}

# ==========================================================
# Storage Statistics
# ==========================================================

storage_statistics() {

    show_module "Storage Statistics"

    filesystem_count=$(df -h | tail -n +2 | wc -l)

    mounted_count=$(mount | wc -l)

    block_count=$(lsblk -dn | wc -l)

    total_space=$(df -h --total | awk '/total/ {print $2}')

    used_space=$(df -h --total | awk '/total/ {print $3}')

    available_space=$(df -h --total | awk '/total/ {print $4}')

    echo

    highlight "Storage Statistics"

    separator

    printf "%-24s : %s\n" "Filesystems" "$filesystem_count"
    printf "%-24s : %s\n" "Mounted" "$mounted_count"
    printf "%-24s : %s\n" "Block Devices" "$block_count"
    printf "%-24s : %s\n" "Total Space" "$total_space"
    printf "%-24s : %s\n" "Used Space" "$used_space"
    printf "%-24s : %s\n" "Available Space" "$available_space"

    echo

    disk_success \
    "STORAGE_STATISTICS" \
    "Viewed statistics"

    pause_screen

}

# ==========================================================
# Disk Health Summary
# ==========================================================

disk_health() {

    show_module "Disk Health"

    echo

    usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

    if [[ "$usage" -ge 90 ]]
    then

        error "Critical: Root filesystem usage above 90%"

    elif [[ "$usage" -ge 75 ]]
    then

        warning "Warning: Root filesystem usage above 75%"

    else

        success "Filesystem usage is healthy."

    fi

    echo

    df -h /

    echo

    disk_success \
    "DISK_HEALTH" \
    "Completed"

    pause_screen

}
# ==========================================================
# Disk Management Menu
# ==========================================================

disk_menu() {

    while true
    do

        show_module "Disk Management"

        show_menu_option 1  "Disk Dashboard"
        show_menu_option 2  "Filesystem Usage"
        show_menu_option 3  "Mounted Filesystems"
        show_menu_option 4  "Block Devices"
        show_menu_option 5  "Partition Information"
        show_menu_option 6  "Inode Usage"
        show_menu_option 7  "Largest Files"
        show_menu_option 8  "Largest Directories"
        show_menu_option 9  "Disk Cleanup"
        show_menu_option 10 "SMART Disk Health"
        show_menu_option 11 "LVM Information"
        show_menu_option 12 "Storage Statistics"
        show_menu_option 13 "Disk Health Summary"

        separator

        show_menu_option 0 "Back"

        separator

        read -rp "Select Option : " option

        case "$option" in

            1)

                disk_dashboard
                ;;

            2)

                filesystem_usage
                ;;

            3)

                mounted_filesystems
                ;;

            4)

                block_devices
                ;;

            5)

                partition_information
                ;;

            6)

                inode_usage
                ;;

            7)

                largest_files
                ;;

            8)

                largest_directories
                ;;

            9)

                disk_cleanup
                ;;

            10)

                smart_health
                ;;

            11)

                lvm_information
                ;;

            12)

                storage_statistics
                ;;

            13)

                disk_health
                ;;

            0)

                break
                ;;

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

disk_manager() {

    disk_menu

}

# ==========================================================
# Execute Directly
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then

    disk_manager

fi



