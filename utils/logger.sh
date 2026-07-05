#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Utility : Logger
# Version : 1.0.0
# ==========================================================

source utils/colors.sh

LOG_DIR="reports"
LOG_FILE="$LOG_DIR/linuxops.log"

# ==========================================================
# Initialize Logger
# ==========================================================

logger_init() {

    mkdir -p "$LOG_DIR"

    touch "$LOG_FILE"

}

# ==========================================================
# Current Timestamp
# ==========================================================

logger_timestamp() {

    date "+%Y-%m-%d %H:%M:%S"

}

# ==========================================================
# Generic Logger
# ==========================================================

log_action() {

    local module="$1"
    local action="$2"
    local status="$3"
    local details="$4"

    logger_init

    echo "[$(logger_timestamp)] | MODULE=$module | ACTION=$action | STATUS=$status | DETAILS=$details" >> "$LOG_FILE"

}

# ==========================================================
# Success Logger
# ==========================================================

log_success() {

    local module="$1"
    local action="$2"
    local details="$3"

    log_action "$module" "$action" "SUCCESS" "$details"

}

# ==========================================================
# Error Logger
# ==========================================================

log_error() {

    local module="$1"
    local action="$2"
    local details="$3"

    log_action "$module" "$action" "ERROR" "$details"

}

# ==========================================================
# Warning Logger
# ==========================================================

log_warning() {

    local module="$1"
    local action="$2"
    local details="$3"

    log_action "$module" "$action" "WARNING" "$details"

}

# ==========================================================
# Information Logger
# ==========================================================

log_info() {

    local module="$1"
    local action="$2"
    local details="$3"

    log_action "$module" "$action" "INFO" "$details"

}

# ==========================================================
# Show Log File
# ==========================================================

show_logs() {

    logger_init

    if [[ ! -s "$LOG_FILE" ]]
    then

        warning "No logs available."

        return

    fi

    cat "$LOG_FILE"

}

# ==========================================================
# Clear Logs
# ==========================================================

clear_logs() {

    logger_init

    > "$LOG_FILE"

    success "Logs cleared successfully."

}

# ==========================================================
# Export Logs
# ==========================================================

export_logs() {

    logger_init

    local export_file="reports/linuxops-$(date +%Y%m%d-%H%M%S).log"

    cp "$LOG_FILE" "$export_file"

    success "Logs exported successfully."

    info "$export_file"

}

# ==========================================================
# Log Statistics
# ==========================================================

log_statistics() {

    logger_init

    echo

    heading "Log Statistics"

    echo

    echo "Total Entries : $(wc -l < "$LOG_FILE")"

    echo "Success       : $(grep -c 'SUCCESS' "$LOG_FILE")"

    echo "Warnings      : $(grep -c 'WARNING' "$LOG_FILE")"

    echo "Errors        : $(grep -c 'ERROR' "$LOG_FILE")"

    echo "Information   : $(grep -c 'INFO' "$LOG_FILE")"

    echo

}
