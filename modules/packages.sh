#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Module : Package Management
# Version : 1.0.0
# ==========================================================

source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/logger.sh
source utils/loader.sh

MODULE_NAME="PACKAGE_MANAGER"

# ==========================================================
# Detect Package Manager
# ==========================================================

detect_package_manager() {

    if command -v apt >/dev/null 2>&1
    then
        PACKAGE_MANAGER="apt"

    elif command -v dnf >/dev/null 2>&1
    then
        PACKAGE_MANAGER="dnf"

    elif command -v yum >/dev/null 2>&1
    then
        PACKAGE_MANAGER="yum"

    else

        error "Unsupported Linux Distribution."

        return 1

    fi

}

# ==========================================================
# Helper Functions
# ==========================================================

package_success() {

    log_success \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

package_failure() {

    log_error \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

confirm_package_action() {

    local message="$1"

    echo

    warning "$message"

    read -rp "Continue? (y/n): " answer

    validate_yes_no "$answer"

    [[ $? -eq 0 ]]

}

# ==========================================================
# Package Dashboard
# ==========================================================

package_dashboard() {

    show_module "Package Dashboard"

    detect_package_manager || return

    updates="N/A"

    if [[ "$PACKAGE_MANAGER" == "apt" ]]
    then

        updates=$(apt list --upgradable 2>/dev/null | tail -n +2 | wc -l)

    fi

    echo

    highlight "Package Manager"

    separator

    printf "%-24s : %s\n" "Manager" "$PACKAGE_MANAGER"
    printf "%-24s : %s\n" "Available Updates" "$updates"

    echo

    pause_screen

}

# ==========================================================
# Install Package
# ==========================================================

install_package() {

    show_module "Install Package"

    detect_package_manager || return

    read -rp "Package Name : " package

    validate_not_empty "$package" || return

    loading "Installing Package..."

    case "$PACKAGE_MANAGER" in

        apt)

            sudo apt install -y "$package"

            ;;

        dnf)

            sudo dnf install -y "$package"

            ;;

        yum)

            sudo yum install -y "$package"

            ;;

    esac

    if [[ $? -eq 0 ]]
    then

        success "Package installed successfully."

        package_success \
        "INSTALL_PACKAGE" \
        "$package"

    else

        error "Installation failed."

        package_failure \
        "INSTALL_PACKAGE" \
        "$package"

    fi

    pause_screen

}

# ==========================================================
# Remove Package
# ==========================================================

remove_package() {

    show_module "Remove Package"

    detect_package_manager || return

    read -rp "Package Name : " package

    validate_not_empty "$package" || return

    confirm_package_action \
    "Remove package '$package'?" || return

    loading "Removing Package..."

    case "$PACKAGE_MANAGER" in

        apt)

            sudo apt remove -y "$package"

            ;;

        dnf)

            sudo dnf remove -y "$package"

            ;;

        yum)

            sudo yum remove -y "$package"

            ;;

    esac

    if [[ $? -eq 0 ]]
    then

        success "Package removed."

        package_success \
        "REMOVE_PACKAGE" \
        "$package"

    else

        error "Removal failed."

        package_failure \
        "REMOVE_PACKAGE" \
        "$package"

    fi

    pause_screen

}

# ==========================================================
# Search Package
# ==========================================================

search_package() {

    show_module "Search Package"

    detect_package_manager || return

    read -rp "Keyword : " keyword

    validate_not_empty "$keyword" || return

    echo

    case "$PACKAGE_MANAGER" in

        apt)

            apt search "$keyword"

            ;;

        dnf)

            dnf search "$keyword"

            ;;

        yum)

            yum search "$keyword"

            ;;

    esac

    echo

    package_success \
    "SEARCH_PACKAGE" \
    "$keyword"

    pause_screen

}

# ==========================================================
# Package Information
# ==========================================================

package_information() {

    show_module "Package Information"

    detect_package_manager || return

    read -rp "Package Name : " package

    validate_not_empty "$package" || return

    echo

    case "$PACKAGE_MANAGER" in

        apt)

            apt show "$package"

            ;;

        dnf)

            dnf info "$package"

            ;;

        yum)

            yum info "$package"

            ;;

    esac

    echo

    package_success \
    "PACKAGE_INFORMATION" \
    "$package"

    pause_screen

}

# ==========================================================
# Installed Packages
# ==========================================================

installed_packages() {

    show_module "Installed Packages"

    detect_package_manager || return

    echo

    case "$PACKAGE_MANAGER" in

        apt)

            apt list --installed

            ;;

        dnf)

            dnf list installed

            ;;

        yum)

            yum list installed

            ;;

    esac

    echo

    package_success \
    "INSTALLED_PACKAGES" \
    "Viewed installed packages"

    pause_screen

}

# ==========================================================
# Update Repository
# ==========================================================

update_repository() {

    show_module "Update Repository"

    detect_package_manager || return

    loading "Updating Repository..."

    case "$PACKAGE_MANAGER" in

        apt)

            sudo apt update

            ;;

        dnf)

            sudo dnf check-update

            ;;

        yum)

            sudo yum check-update

            ;;

    esac

    success "Repository updated."

    package_success \
    "UPDATE_REPOSITORY" \
    "$PACKAGE_MANAGER"

    pause_screen

}

# ==========================================================
# Upgrade System
# ==========================================================

upgrade_system() {

    show_module "System Upgrade"

    detect_package_manager || return

    confirm_package_action \
    "Upgrade all installed packages?" || return

    loading "Upgrading System..."

    case "$PACKAGE_MANAGER" in

        apt)

            sudo apt upgrade -y

            ;;

        dnf)

            sudo dnf upgrade -y

            ;;

        yum)

            sudo yum update -y

            ;;

    esac

    if [[ $? -eq 0 ]]
    then

        success "System upgraded successfully."

        package_success \
        "SYSTEM_UPGRADE" \
        "$PACKAGE_MANAGER"

    else

        error "System upgrade failed."

        package_failure \
        "SYSTEM_UPGRADE" \
        "$PACKAGE_MANAGER"

    fi

    pause_screen

}

# ==========================================================
# Cleanup Packages
# ==========================================================

cleanup_packages() {

    show_module "Cleanup Packages"

    detect_package_manager || return

    confirm_package_action \
    "Remove unused packages?" || return

    loading "Cleaning Packages..."

    case "$PACKAGE_MANAGER" in

        apt)

            sudo apt autoremove -y
            sudo apt autoclean -y

            ;;

        dnf)

            sudo dnf autoremove -y
            sudo dnf clean all

            ;;

        yum)

            sudo yum autoremove -y
            sudo yum clean all

            ;;

    esac

    success "Cleanup completed."

    package_success \
    "PACKAGE_CLEANUP" \
    "$PACKAGE_MANAGER"

    pause_screen

}

# ==========================================================
# Package Statistics
# ==========================================================

package_statistics() {

    show_module "Package Statistics"

    detect_package_manager || return

    case "$PACKAGE_MANAGER" in

        apt)

            installed=$(dpkg -l | grep '^ii' | wc -l)

            ;;

        dnf)

            installed=$(rpm -qa | wc -l)

            ;;

        yum)

            installed=$(rpm -qa | wc -l)

            ;;

    esac

    echo

    highlight "Package Statistics"

    separator

    printf "%-24s : %s\n" "Package Manager" "$PACKAGE_MANAGER"

    printf "%-24s : %s\n" "Installed Packages" "$installed"

    echo

    package_success \
    "PACKAGE_STATISTICS" \
    "Viewed statistics"

    pause_screen

}

# ==========================================================
# Package Health Check
# ==========================================================

package_health() {

    show_module "Package Health"

    detect_package_manager || return

    echo

    success "Package Manager Detected"

    echo

    printf "%-24s : %s\n" "Manager" "$PACKAGE_MANAGER"

    printf "%-24s : %s\n" "Executable" "$(command -v "$PACKAGE_MANAGER")"

    echo

    package_success \
    "PACKAGE_HEALTH" \
    "$PACKAGE_MANAGER"

    pause_screen

}
# ==========================================================
# Package Management Menu
# ==========================================================

package_menu() {

    while true
    do

        show_module "Package Management"

        show_menu_option 1  "Package Dashboard"
        show_menu_option 2  "Install Package"
        show_menu_option 3  "Remove Package"
        show_menu_option 4  "Search Package"
        show_menu_option 5  "Package Information"
        show_menu_option 6  "Installed Packages"
        show_menu_option 7  "Update Repository"
        show_menu_option 8  "Upgrade System"
        show_menu_option 9  "Cleanup Packages"
        show_menu_option 10 "Package Statistics"
        show_menu_option 11 "Package Health Check"

        separator

        show_menu_option 0 "Back"

        separator

        read -rp "Select Option : " option

        case "$option" in

            1)

                package_dashboard
                ;;

            2)

                install_package
                ;;

            3)

                remove_package
                ;;

            4)

                search_package
                ;;

            5)

                package_information
                ;;

            6)

                installed_packages
                ;;

            7)

                update_repository
                ;;

            8)

                upgrade_system
                ;;

            9)

                cleanup_packages
                ;;

            10)

                package_statistics
                ;;

            11)

                package_health
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

package_manager() {

    package_menu

}

# ==========================================================
# Execute Directly
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then

    package_manager

fi


