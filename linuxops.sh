#!/bin/bash

# ==========================================
# LinuxOps Toolkit v1.0
# Author : Ujjwal Agarwal
# ==========================================

# Load Configuration
source config/config.sh

# Load Utilities
source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/loader.sh

# Load Modules
source modules/file_manager.sh
source modules/backup.sh
source modules/logs.sh
source modules/users.sh
source modules/disk.sh
source modules/process.sh
source modules/services.sh
source modules/packages.sh
source modules/network.sh
source modules/health.sh
source modules/security.sh
source modules/about.sh

# ==========================================
# Main Dashboard
# ==========================================

main_menu() {

    while true
    do

        clear_screen

        print_banner

        system_information

        print_menu

        read -rp "Select an option [1-13]: " choice

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
                disk_menu
                ;;

            6)
                process_menu
                ;;

            7)
                services_menu
                ;;

            8)
                packages_menu
                ;;

            9)
                network_menu
                ;;

            10)
                health_menu
                ;;

            11)
                security_menu
                ;;

            12)
                about_menu
                ;;

            13)

                clear

                success "Thank you for using LinuxOps Toolkit."

                echo

                exit 0

                ;;

            *)

                error "Invalid Choice!"

                sleep 1

                ;;

        esac

    done

}

# ==========================================
# Start Application
# ==========================================

main_menu
