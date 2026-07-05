#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Module : Service Management
# Version : 1.0.0
# ==========================================================

source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/logger.sh
source utils/loader.sh

MODULE_NAME="SERVICE_MANAGER"

# ==========================================================
# Helper Functions
# ==========================================================

service_success() {

    log_success \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

service_failure() {

    log_error \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

confirm_service_action() {

    local message="$1"

    echo

    warning "$message"

    read -rp "Continue? (y/n): " answer

    validate_yes_no "$answer"

    [[ $? -eq 0 ]]

}

# ==========================================================
# Service Dashboard
# ==========================================================

service_dashboard() {

    show_module "Service Dashboard"

    total=$(systemctl list-unit-files --type=service --no-legend | wc -l)

    running=$(systemctl list-units --type=service --state=running --no-legend | wc -l)

    failed=$(systemctl --failed --type=service --no-legend | wc -l)

    enabled=$(systemctl list-unit-files --type=service --state=enabled --no-legend | wc -l)

    echo

    highlight "Service Summary"

    separator

    printf "%-24s : %s\n" "Total Services" "$total"
    printf "%-24s : %s\n" "Running Services" "$running"
    printf "%-24s : %s\n" "Failed Services" "$failed"
    printf "%-24s : %s\n" "Enabled Services" "$enabled"

    echo

    pause_screen

}

# ==========================================================
# List All Services
# ==========================================================

list_services() {

    show_module "All Services"

    systemctl list-units \
    --type=service \
    --all

    echo

    service_success \
    "LIST_SERVICES" \
    "Viewed services"

    pause_screen

}

# ==========================================================
# Running Services
# ==========================================================

running_services() {

    show_module "Running Services"

    systemctl list-units \
    --type=service \
    --state=running

    echo

    service_success \
    "RUNNING_SERVICES" \
    "Viewed running services"

    pause_screen

}

# ==========================================================
# Failed Services
# ==========================================================

failed_services() {

    show_module "Failed Services"

    systemctl --failed \
    --type=service

    echo

    service_success \
    "FAILED_SERVICES" \
    "Viewed failed services"

    pause_screen

}

# ==========================================================
# Service Status
# ==========================================================

service_status() {

    show_module "Service Status"

    read -rp "Service Name : " service

    validate_not_empty "$service" || return

    echo

    systemctl status "$service"

    echo

    service_success \
    "SERVICE_STATUS" \
    "$service"

    pause_screen

}

# ==========================================================
# Start Service
# ==========================================================

start_service() {

    show_module "Start Service"

    read -rp "Service Name : " service

    validate_not_empty "$service" || return

    loading "Starting Service..."

    if sudo systemctl start "$service"
    then

        success "Service started successfully."

        service_success \
        "START_SERVICE" \
        "$service"

    else

        error "Failed to start service."

        service_failure \
        "START_SERVICE" \
        "$service"

    fi

    pause_screen

}

# ==========================================================
# Stop Service
# ==========================================================

stop_service() {

    show_module "Stop Service"

    read -rp "Service Name : " service

    validate_not_empty "$service" || return

    confirm_service_action \
    "Stop service '$service'?" || return

    loading "Stopping Service..."

    if sudo systemctl stop "$service"
    then

        success "Service stopped successfully."

        service_success \
        "STOP_SERVICE" \
        "$service"

    else

        error "Failed to stop service."

        service_failure \
        "STOP_SERVICE" \
        "$service"

    fi

    pause_screen

}

# ==========================================================
# Restart Service
# ==========================================================

restart_service() {

    show_module "Restart Service"

    read -rp "Service Name : " service

    validate_not_empty "$service" || return

    loading "Restarting Service..."

    if sudo systemctl restart "$service"
    then

        success "Service restarted successfully."

        service_success \
        "RESTART_SERVICE" \
        "$service"

    else

        error "Failed to restart service."

        service_failure \
        "RESTART_SERVICE" \
        "$service"

    fi

    pause_screen

}

# ==========================================================
# Reload Service
# ==========================================================

reload_service() {

    show_module "Reload Service"

    read -rp "Service Name : " service

    validate_not_empty "$service" || return

    loading "Reloading Service..."

    if sudo systemctl reload "$service"
    then

        success "Service reloaded successfully."

        service_success \
        "RELOAD_SERVICE" \
        "$service"

    else

        error "Reload operation failed."

        service_failure \
        "RELOAD_SERVICE" \
        "$service"

    fi

    pause_screen

}

# ==========================================================
# Enable Service
# ==========================================================

enable_service() {

    show_module "Enable Service"

    read -rp "Service Name : " service

    validate_not_empty "$service" || return

    loading "Enabling Service..."

    if sudo systemctl enable "$service"
    then

        success "Service enabled."

        service_success \
        "ENABLE_SERVICE" \
        "$service"

    else

        error "Failed to enable service."

        service_failure \
        "ENABLE_SERVICE" \
        "$service"

    fi

    pause_screen

}

# ==========================================================
# Disable Service
# ==========================================================

disable_service() {

    show_module "Disable Service"

    read -rp "Service Name : " service

    validate_not_empty "$service" || return

    confirm_service_action \
    "Disable service '$service'?" || return

    loading "Disabling Service..."

    if sudo systemctl disable "$service"
    then

        success "Service disabled."

        service_success \
        "DISABLE_SERVICE" \
        "$service"

    else

        error "Failed to disable service."

        service_failure \
        "DISABLE_SERVICE" \
        "$service"

    fi

    pause_screen

}

# ==========================================================
# Service Logs
# ==========================================================

service_logs() {

    show_module "Service Logs"

    read -rp "Service Name : " service

    validate_not_empty "$service" || return

    echo

    sudo journalctl -u "$service" --no-pager -n 100

    echo

    service_success \
    "SERVICE_LOGS" \
    "$service"

    pause_screen

}

# ==========================================================
# Boot Performance
# ==========================================================

boot_analysis() {

    show_module "Boot Performance"

    echo

    systemd-analyze

    echo

    systemd-analyze blame | head -20

    echo

    service_success \
    "BOOT_ANALYSIS" \
    "Viewed boot analysis"

    pause_screen

}
# ==========================================================
# Startup Services
# ==========================================================

startup_services() {

    show_module "Startup Services"

    echo

    systemctl list-unit-files \
    --type=service \
    --state=enabled

    echo

    service_success \
    "STARTUP_SERVICES" \
    "Viewed enabled startup services"

    pause_screen

}

# ==========================================================
# Service Statistics
# ==========================================================

service_statistics() {

    show_module "Service Statistics"

    total=$(systemctl list-unit-files --type=service --no-legend | wc -l)

    running=$(systemctl list-units --type=service --state=running --no-legend | wc -l)

    stopped=$(systemctl list-units --type=service --state=inactive --no-legend | wc -l)

    failed=$(systemctl --failed --type=service --no-legend | wc -l)

    enabled=$(systemctl list-unit-files --type=service --state=enabled --no-legend | wc -l)

    disabled=$(systemctl list-unit-files --type=service --state=disabled --no-legend | wc -l)

    echo

    highlight "Service Statistics"

    separator

    printf "%-24s : %s\n" "Total Services" "$total"
    printf "%-24s : %s\n" "Running" "$running"
    printf "%-24s : %s\n" "Stopped" "$stopped"
    printf "%-24s : %s\n" "Failed" "$failed"
    printf "%-24s : %s\n" "Enabled" "$enabled"
    printf "%-24s : %s\n" "Disabled" "$disabled"

    echo

    service_success \
    "SERVICE_STATISTICS" \
    "Viewed statistics"

    pause_screen

}

# ==========================================================
# Service Health Check
# ==========================================================

service_health() {

    show_module "Service Health"

    echo

    failed_count=$(systemctl --failed --type=service --no-legend | wc -l)

    if [[ "$failed_count" -eq 0 ]]
    then

        success "No failed services detected."

    else

        warning "$failed_count failed service(s) detected."

        echo

        systemctl --failed --type=service

    fi

    echo

    service_success \
    "SERVICE_HEALTH" \
    "Completed"

    pause_screen

}

# ==========================================================
# Services Menu
# ==========================================================

services_menu() {

    while true
    do

        show_module "Service Management"

        show_menu_option 1  "Service Dashboard"
        show_menu_option 2  "List All Services"
        show_menu_option 3  "Running Services"
        show_menu_option 4  "Failed Services"
        show_menu_option 5  "Service Status"
        show_menu_option 6  "Start Service"
        show_menu_option 7  "Stop Service"
        show_menu_option 8  "Restart Service"
        show_menu_option 9  "Reload Service"
        show_menu_option 10 "Enable Service"
        show_menu_option 11 "Disable Service"
        show_menu_option 12 "Service Logs"
        show_menu_option 13 "Boot Analysis"
        show_menu_option 14 "Startup Services"
        show_menu_option 15 "Service Statistics"
        show_menu_option 16 "Service Health Check"

        separator

        show_menu_option 0 "Back"

        separator

        read -rp "Select Option : " option

        case "$option" in

            1)  service_dashboard ;;
            2)  list_services ;;
            3)  running_services ;;
            4)  failed_services ;;
            5)  service_status ;;
            6)  start_service ;;
            7)  stop_service ;;
            8)  restart_service ;;
            9)  reload_service ;;
            10) enable_service ;;
            11) disable_service ;;
            12) service_logs ;;
            13) boot_analysis ;;
            14) startup_services ;;
            15) service_statistics ;;
            16) service_health ;;
            0)  break ;;

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

services_manager() {

    services_menu

}

# ==========================================================
# Execute Directly
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then

    services_manager

fi


