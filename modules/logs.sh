#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Module : Log Management
# Version : 1.0.0
# ==========================================================

source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/logger.sh
source utils/loader.sh

MODULE_NAME="LOG_MANAGER"

LOG_FILE="reports/linuxops.log"

# ==========================================================
# Helper Functions
# ==========================================================

log_module_success() {

    log_success \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

log_module_failure() {

    log_error \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

initialize_logs() {

    mkdir -p reports

    touch "$LOG_FILE"

}

# ==========================================================
# View Logs
# ==========================================================

view_logs() {

    show_module "View Logs"

    initialize_logs

    echo

    if [[ ! -s "$LOG_FILE" ]]
    then

        warning "Log file is empty."

        pause_screen

        return

    fi

    less "$LOG_FILE"

    log_module_success \
    "VIEW_LOGS" \
    "$LOG_FILE"

}

# ==========================================================
# Live Monitoring
# ==========================================================

live_logs() {

    show_module "Live Log Monitoring"

    initialize_logs

    info "Press CTRL+C to stop monitoring."

    echo

    tail -f "$LOG_FILE"

}

# ==========================================================
# Search Logs
# ==========================================================

search_logs() {

    show_module "Search Logs"

    initialize_logs

    read -rp "Keyword : " keyword

    validate_not_empty "$keyword" || return

    echo

    loading "Searching..."

    results=$(grep -in "$keyword" "$LOG_FILE")

    if [[ -z "$results" ]]
    then

        warning "No matching entries found."

        log_module_failure \
        "SEARCH_LOGS" \
        "$keyword"

    else

        success "Search Results"

        echo

        echo "$results"

        log_module_success \
        "SEARCH_LOGS" \
        "$keyword"

    fi

    pause_screen

}

# ==========================================================
# Filter Logs
# ==========================================================

filter_logs() {

    show_module "Filter Logs"

    initialize_logs

    echo

    echo "1. SUCCESS"

    echo "2. ERROR"

    echo "3. WARNING"

    echo "4. INFO"

    echo

    read -rp "Select : " option

    case "$option" in

        1) filter="SUCCESS" ;;

        2) filter="ERROR" ;;

        3) filter="WARNING" ;;

        4) filter="INFO" ;;

        *)

            warning "Invalid Option."

            pause_screen

            return

            ;;

    esac

    echo

    grep "$filter" "$LOG_FILE"

    pause_screen

}

# ==========================================================
# Export Logs
# ==========================================================

export_logs() {

    show_module "Export Logs"

    initialize_logs

    if [[ ! -s "$LOG_FILE" ]]
    then

        warning "No logs available."

        pause_screen

        return

    fi

    export_file="reports/logs_$(date +%Y%m%d_%H%M%S).log"

    loading "Exporting Logs..."

    if cp "$LOG_FILE" "$export_file"
    then

        success "Logs exported successfully."

        info "$export_file"

        log_module_success \
        "EXPORT_LOGS" \
        "$export_file"

    else

        error "Failed to export logs."

        log_module_failure \
        "EXPORT_LOGS" \
        "$export_file"

    fi

    pause_screen

}

# ==========================================================
# Log Statistics
# ==========================================================

log_statistics() {

    show_module "Log Statistics"

    initialize_logs

    total=$(wc -l < "$LOG_FILE")

    success_count=$(grep -c "SUCCESS" "$LOG_FILE")

    error_count=$(grep -c "ERROR" "$LOG_FILE")

    warning_count=$(grep -c "WARNING" "$LOG_FILE")

    info_count=$(grep -c "INFO" "$LOG_FILE")

    echo

    highlight "Log Summary"

    separator

    echo "Total Entries : $total"

    echo "SUCCESS       : $success_count"

    echo "ERROR         : $error_count"

    echo "WARNING       : $warning_count"

    echo "INFO          : $info_count"

    echo

    log_module_success \
    "LOG_STATISTICS" \
    "Viewed statistics"

    pause_screen

}

# ==========================================================
# Clear Logs
# ==========================================================

clear_logs_file() {

    show_module "Clear Logs"

    initialize_logs

    echo

    warning "All log entries will be deleted."

    read -rp "Continue? (y/n): " answer

    validate_yes_no "$answer"

    [[ $? -ne 0 ]] && return

    loading "Clearing Logs..."

    > "$LOG_FILE"

    success "Log file cleared."

    log_module_success \
    "CLEAR_LOGS" \
    "$LOG_FILE"

    pause_screen

}

# ==========================================================
# Log Health Check
# ==========================================================

log_health() {

    show_module "Log Health"

    initialize_logs

    echo

    logfile_size=$(du -h "$LOG_FILE" | awk '{print $1}')

    logfile_lines=$(wc -l < "$LOG_FILE")

    logfile_modified=$(stat -c %y "$LOG_FILE")

    highlight "Log Health"

    separator

    echo "Location      : $LOG_FILE"

    echo "Size          : $logfile_size"

    echo "Entries       : $logfile_lines"

    echo "Last Modified : $logfile_modified"

    echo

    success "Log file is accessible."

    log_module_success \
    "LOG_HEALTH" \
    "$LOG_FILE"

    pause_screen

}

# ==========================================================
# Search By Date
# ==========================================================

search_by_date() {

    show_module "Search Logs By Date"

    initialize_logs

    read -rp "Date (YYYY-MM-DD): " log_date

    validate_not_empty "$log_date" || return

    echo

    grep "$log_date" "$LOG_FILE"

    echo

    log_module_success \
    "SEARCH_DATE" \
    "$log_date"

    pause_screen

}

# ==========================================================
# Last N Log Entries
# ==========================================================

last_entries() {

    show_module "Recent Log Entries"

    initialize_logs

    read -rp "Number of Entries : " count

    validate_number "$count" || return

    echo

    tail -n "$count" "$LOG_FILE"

    echo

    log_module_success \
    "RECENT_LOGS" \
    "$count"

    pause_screen

}

# ==========================================================
# Logs Dashboard
# ==========================================================

logs_dashboard() {

    show_module "Log Dashboard"

    initialize_logs

    total_logs=$(wc -l < "$LOG_FILE")

    success_logs=$(grep -c "SUCCESS" "$LOG_FILE")

    error_logs=$(grep -c "ERROR" "$LOG_FILE")

    warning_logs=$(grep -c "WARNING" "$LOG_FILE")

    info_logs=$(grep -c "INFO" "$LOG_FILE")

    echo

    highlight "Current Log Status"

    separator

    printf "%-20s : %s\n" "Total Logs" "$total_logs"
    printf "%-20s : %s\n" "Success Logs" "$success_logs"
    printf "%-20s : %s\n" "Error Logs" "$error_logs"
    printf "%-20s : %s\n" "Warning Logs" "$warning_logs"
    printf "%-20s : %s\n" "Info Logs" "$info_logs"

    echo

    pause_screen

}

# ==========================================================
# Menu
# ==========================================================

logs_menu() {

    while true
    do

        show_module "Logs Management"

        show_menu_option 1  "Logs Dashboard"
        show_menu_option 2  "View Logs"
        show_menu_option 3  "Live Monitoring"
        show_menu_option 4  "Search Logs"
        show_menu_option 5  "Search By Date"
        show_menu_option 6  "Filter Logs"
        show_menu_option 7  "Recent Log Entries"
        show_menu_option 8  "Export Logs"
        show_menu_option 9  "Log Statistics"
        show_menu_option 10 "Log Health Check"
        show_menu_option 11 "Clear Logs"

        separator

        show_menu_option 0 "Back"

        separator

        read -rp "Select Option : " option

        case "$option" in

            1)

                logs_dashboard
                ;;

            2)

                view_logs
                ;;

            3)

                live_logs
                ;;

            4)

                search_logs
                ;;

            5)

                search_by_date
                ;;

            6)

                filter_logs
                ;;

            7)

                last_entries
                ;;

            8)

                export_logs
                ;;

            9)

                log_statistics
                ;;

            10)

                log_health
                ;;

            11)

                clear_logs_file
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

logs_manager() {

    logs_menu

}

# ==========================================================
# Execute Directly
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then

    logs_manager

fi
