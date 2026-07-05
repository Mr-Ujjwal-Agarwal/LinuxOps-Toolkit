#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Version : 1.0.0
# Author  : Ujjwal Agarwal
# ==========================================================

# ==========================================================
# Load Configuration
# ==========================================================

source config/config.sh

# ==========================================================
# Load Utilities
# ==========================================================

source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/loader.sh
source utils/logger.sh

# ==========================================================
# Load Modules
# ==========================================================

source modules/file_manager.sh
source modules/backup.sh
source modules/logs.sh
source modules/users.sh
source modules/process.sh
source modules/services.sh
source modules/packages.sh
source modules/network.sh
source modules/disk.sh
source modules/health.sh
source modules/security.sh
source modules/system_info.sh
source modules/about.sh

# ==========================================================
# Main Dashboard
# ==========================================================

main_dashboard() {

    clear_screen

    heading "LinuxOps Toolkit v1.0"

    separator

    show_system_info

    show_menu_title "Main Menu"

    show_menu_option 1  "File Management"
    show_menu_option 2  "Backup Management"
    show_menu_option 3  "Log Management"
    show_menu_option 4  "User Management"
    show_menu_option 5  "Process Management"
    show_menu_option 6  "Service Management"
    show_menu_option 7  "Package Management"
    show_menu_option 8  "Network Management"
    show_menu_option 9  "Disk Management"
    show_menu_option 10 "Health Monitoring"
    show_menu_option 11 "Security Audit"
    show_menu_option 12 "System Information"
    show_menu_option 13 "About"

    separator

    warning "0. Exit"

    separator

}

# ==========================================================
# Main Menu
# ==========================================================

main_menu() {

    while true
    do

        main_dashboard

        read -rp "Select an option [0-13]: " choice

        case "$choice" in

            1)

                file_manager_menu
                ;;

            2)

                backup_menu
                ;;

            3)

                logs_menu
                ;;

            4)

                users_menu
                ;;

            5)

                process_menu
                ;;

            6)

                services_menu
                ;;

            7)

                package_menu
                ;;

            8)

                network_menu
                ;;

            9)

                disk_menu
                ;;

            10)

                health_menu
                ;;

            11)

                security_menu
                ;;

            12)

                system_information_manager
                ;;

            13)

                about_menu
                ;;

            0)

                clear

                success "Thank you for using LinuxOps Toolkit."

                echo

                info "Goodbye!"

                echo

                exit 0
                ;;

            *)

                error "Invalid option."

                sleep 1
                ;;

        esac

    done

}

# ==========================================================
# Start Application
# ==========================================================

main_menu
