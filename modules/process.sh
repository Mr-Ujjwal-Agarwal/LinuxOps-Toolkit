#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Module : Process Management
# Version : 1.0.0
# ==========================================================

source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/logger.sh
source utils/loader.sh

MODULE_NAME="PROCESS_MANAGER"

# ==========================================================
# Helper Functions
# ==========================================================

process_success() {

    log_success \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

process_failure() {

    log_error \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

confirm_process_action() {

    local message="$1"

    echo

    warning "$message"

    read -rp "Continue? (y/n): " answer

    validate_yes_no "$answer"

    [[ $? -eq 0 ]]

}

# ==========================================================
# Process Dashboard
# ==========================================================

process_dashboard() {

    show_module "Process Dashboard"

    total=$(ps -e --no-headers | wc -l)

    running=$(ps -e -o stat= | grep -c "^R")

    sleeping=$(ps -e -o stat= | grep -c "^S")

    zombies=$(ps -e -o stat= | grep -c "^Z")

    echo

    highlight "Process Summary"

    separator

    printf "%-22s : %s\n" "Total Processes" "$total"
    printf "%-22s : %s\n" "Running" "$running"
    printf "%-22s : %s\n" "Sleeping" "$sleeping"
    printf "%-22s : %s\n" "Zombie" "$zombies"

    echo

    pause_screen

}

# ==========================================================
# Running Processes
# ==========================================================

running_processes() {

    show_module "Running Processes"

    ps -ef

    echo

    process_success \
    "LIST_PROCESSES" \
    "Displayed running processes"

    pause_screen

}

# ==========================================================
# Top CPU Processes
# ==========================================================

top_cpu() {

    show_module "Top CPU Processes"

    ps -eo pid,user,%cpu,%mem,comm \
    --sort=-%cpu | head -11

    echo

    process_success \
    "TOP_CPU" \
    "Viewed CPU usage"

    pause_screen

}

# ==========================================================
# Top Memory Processes
# ==========================================================

top_memory() {

    show_module "Top Memory Processes"

    ps -eo pid,user,%cpu,%mem,comm \
    --sort=-%mem | head -11

    echo

    process_success \
    "TOP_MEMORY" \
    "Viewed memory usage"

    pause_screen

}

# ==========================================================
# Search Process
# ==========================================================

search_process() {

    show_module "Search Process"

    read -rp "Process Name : " process_name

    validate_not_empty "$process_name" || return

    echo

    pgrep -a "$process_name"

    echo

    process_success \
    "SEARCH_PROCESS" \
    "$process_name"

    pause_screen

}
# ==========================================================
# Process Information
# ==========================================================

process_information() {

    show_module "Process Information"

    read -rp "PID : " pid

    validate_number "$pid" || return

    if ! ps -p "$pid" >/dev/null 2>&1
    then

        error "Process not found."

        pause_screen

        return

    fi

    echo

    ps -fp "$pid"

    echo

    process_success \
    "PROCESS_INFORMATION" \
    "$pid"

    pause_screen

}

# ==========================================================
# Kill Process
# ==========================================================

kill_process() {

    show_module "Kill Process"

    read -rp "PID : " pid

    validate_number "$pid" || return

    ps -p "$pid" >/dev/null 2>&1 || {

        error "Process not found."

        pause_screen

        return

    }

    confirm_process_action \
    "Terminate Process $pid ?" || return

    loading "Stopping Process..."

    if kill "$pid"
    then

        success "Process terminated successfully."

        process_success \
        "KILL_PROCESS" \
        "$pid"

    else

        error "Unable to terminate process."

        process_failure \
        "KILL_PROCESS" \
        "$pid"

    fi

    pause_screen

}

# ==========================================================
# Kill Process By Name
# ==========================================================

kill_process_name() {

    show_module "Kill Process By Name"

    read -rp "Process Name : " process_name

    validate_not_empty "$process_name" || return

    confirm_process_action \
    "Terminate all '$process_name' processes?" || return

    loading "Stopping Processes..."

    if pkill "$process_name"
    then

        success "Process terminated."

        process_success \
        "KILL_PROCESS_NAME" \
        "$process_name"

    else

        error "Process not found."

        process_failure \
        "KILL_PROCESS_NAME" \
        "$process_name"

    fi

    pause_screen

}

# ==========================================================
# Process Tree
# ==========================================================

process_tree() {

    show_module "Process Tree"

    if command -v pstree >/dev/null 2>&1
    then

        pstree -p

    else

        warning "pstree is not installed."

        echo

        info "Install package: psmisc"

    fi

    echo

    process_success \
    "PROCESS_TREE" \
    "Viewed process tree"

    pause_screen

}

# ==========================================================
# Zombie Processes
# ==========================================================

zombie_processes() {

    show_module "Zombie Processes"

    echo

    zombies=$(ps -el | awk '$2=="Z"')

    if [[ -z "$zombies" ]]
    then

        success "No zombie processes detected."

    else

        warning "Zombie Processes Found"

        echo

        echo "$zombies"

    fi

    echo

    process_success \
    "ZOMBIE_CHECK" \
    "Completed"

    pause_screen

}

# ==========================================================
# High CPU Processes
# ==========================================================

high_cpu_processes() {

    show_module "High CPU Processes"

    echo

    ps -eo pid,user,%cpu,%mem,comm \
    --sort=-%cpu | head -15

    echo

    process_success \
    "HIGH_CPU" \
    "Viewed high CPU processes"

    pause_screen

}

# ==========================================================
# High Memory Processes
# ==========================================================

high_memory_processes() {

    show_module "High Memory Processes"

    echo

    ps -eo pid,user,%cpu,%mem,comm \
    --sort=-%mem | head -15

    echo

    process_success \
    "HIGH_MEMORY" \
    "Viewed high memory processes"

    pause_screen

}

# ==========================================================
# Process Statistics
# ==========================================================

process_statistics() {

    show_module "Process Statistics"

    total=$(ps -e --no-headers | wc -l)

    running=$(ps -e -o stat= | grep -c "^R")

    sleeping=$(ps -e -o stat= | grep -c "^S")

    stopped=$(ps -e -o stat= | grep -c "^T")

    zombies=$(ps -e -o stat= | grep -c "^Z")

    echo

    highlight "Process Statistics"

    separator

    printf "%-22s : %s\n" "Total" "$total"
    printf "%-22s : %s\n" "Running" "$running"
    printf "%-22s : %s\n" "Sleeping" "$sleeping"
    printf "%-22s : %s\n" "Stopped" "$stopped"
    printf "%-22s : %s\n" "Zombie" "$zombies"

    echo

    process_success \
    "PROCESS_STATISTICS" \
    "Viewed statistics"

    pause_screen

}

# ==========================================================
# Refresh Dashboard
# ==========================================================

refresh_dashboard() {

    loading "Refreshing Dashboard..."

    process_dashboard

}

# ==========================================================
# Process Menu
# ==========================================================

process_menu() {

    while true
    do

        show_module "Process Management"

        show_menu_option 1  "Process Dashboard"
        show_menu_option 2  "Running Processes"
        show_menu_option 3  "Top CPU Processes"
        show_menu_option 4  "Top Memory Processes"
        show_menu_option 5  "Search Process"
        show_menu_option 6  "Process Information"
        show_menu_option 7  "Kill Process"
        show_menu_option 8  "Kill Process By Name"
        show_menu_option 9  "Process Tree"
        show_menu_option 10 "Zombie Processes"
        show_menu_option 11 "High CPU Processes"
        show_menu_option 12 "High Memory Processes"
        show_menu_option 13 "Process Statistics"
        show_menu_option 14 "Refresh Dashboard"

        separator

        show_menu_option 0 "Back"

        separator

        read -rp "Select Option : " option

        case "$option" in

            1)

                process_dashboard
                ;;

            2)

                running_processes
                ;;

            3)

                top_cpu
                ;;

            4)

                top_memory
                ;;

            5)

                search_process
                ;;

            6)

                process_information
                ;;

            7)

                kill_process
                ;;

            8)

                kill_process_name
                ;;

            9)

                process_tree
                ;;

            10)

                zombie_processes
                ;;

            11)

                high_cpu_processes
                ;;

            12)

                high_memory_processes
                ;;

            13)

                process_statistics
                ;;

            14)

                refresh_dashboard
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

process_manager() {

    process_menu

}

# ==========================================================
# Execute Directly
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then

    process_manager

fi

