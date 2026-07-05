#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Module : Backup Management
# Version : 1.0.0
# ==========================================================

source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/logger.sh
source utils/loader.sh

MODULE_NAME="BACKUP"

BACKUP_ROOT="backups"

# ==========================================================
# Helper Functions
# ==========================================================

backup_initialize() {

    mkdir -p "$BACKUP_ROOT"

}

backup_name() {

    date +"backup_%Y%m%d_%H%M%S.tar.gz"

}

backup_success() {

    log_success \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

backup_failure() {

    log_error \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

confirm_backup_action() {

    local message="$1"

    echo
    warning "$message"

    read -rp "Continue? (y/n): " choice

    validate_yes_no "$choice"

    [[ $? -eq 0 ]]

}

# ==========================================================
# Create Backup
# ==========================================================

create_backup() {

    show_module "Create Backup"

    backup_initialize

    read -rp "Source Directory : " source_directory

    validate_not_empty "$source_directory" || return

    validate_directory_exists "$source_directory" || return

    archive="$BACKUP_ROOT/$(backup_name)"

    loading "Creating Backup..."

    if tar -czf "$archive" "$source_directory"
    then

        success "Backup Created Successfully."

        info "$archive"

        backup_success \
        "CREATE_BACKUP" \
        "$archive"

    else

        error "Backup Failed."

        backup_failure \
        "CREATE_BACKUP" \
        "$source_directory"

    fi

    pause_screen

}

# ==========================================================
# Restore Backup
# ==========================================================

restore_backup() {

    show_module "Restore Backup"

    read -rp "Backup Archive : " archive

    validate_not_empty "$archive" || return

    validate_file_exists "$archive" || return

    read -rp "Restore Destination : " destination

    validate_not_empty "$destination" || return

    mkdir -p "$destination"

    loading "Restoring Backup..."

    if tar -xzf "$archive" -C "$destination"
    then

        success "Backup Restored Successfully."

        backup_success \
        "RESTORE_BACKUP" \
        "$archive"

    else

        error "Restore Failed."

        backup_failure \
        "RESTORE_BACKUP" \
        "$archive"

    fi

    pause_screen

}

# ==========================================================
# Verify Backup
# ==========================================================

verify_backup() {

    show_module "Verify Backup"

    read -rp "Backup Archive : " archive

    validate_not_empty "$archive" || return

    validate_file_exists "$archive" || return

    loading "Verifying Backup..."

    if tar -tf "$archive" >/dev/null 2>&1
    then

        success "Backup Verified Successfully."

        backup_success \
        "VERIFY_BACKUP" \
        "$archive"

    else

        error "Backup Verification Failed."

        backup_failure \
        "VERIFY_BACKUP" \
        "$archive"

    fi

    pause_screen

}


# ==========================================================
# List Available Backups
# ==========================================================

list_backups() {

    show_module "Available Backups"

    backup_initialize

    echo

    if [[ -z "$(ls -A "$BACKUP_ROOT" 2>/dev/null)" ]]
    then

        warning "No backups available."

        pause_screen

        return

    fi

    ls -lh "$BACKUP_ROOT"

    echo

    backup_success \
    "LIST_BACKUPS" \
    "Viewed backup list"

    pause_screen

}

# ==========================================================
# Delete Backup
# ==========================================================

delete_backup() {

    show_module "Delete Backup"

    read -rp "Backup Archive : " archive

    validate_not_empty "$archive" || return

    validate_file_exists "$archive" || return

    confirm_backup_action "Delete this backup permanently?" || return
    loading "Deleting Backup..."

    if rm -f "$archive"
    then

        success "Backup deleted successfully."

        backup_success \
        "DELETE_BACKUP" \
        "$archive"

    else

        error "Unable to delete backup."

        backup_failure \
        "DELETE_BACKUP" \
        "$archive"

    fi

    pause_screen

}

# ==========================================================
# Backup Information
# ==========================================================

backup_information() {

    show_module "Backup Information"

    read -rp "Backup Archive : " archive

    validate_not_empty "$archive" || return

    validate_file_exists "$archive" || return

    echo

    highlight "Archive Information"

    separator

    stat "$archive"

    echo

    highlight "Archive Contents"

    separator

    tar -tf "$archive"

    echo

    backup_success \
    "BACKUP_INFORMATION" \
    "$archive"

    pause_screen

}

# ==========================================================
# Backup Statistics
# ==========================================================

backup_statistics() {

    show_module "Backup Statistics"

    backup_initialize

    echo

    total_backups=$(find "$BACKUP_ROOT" -maxdepth 1 -name "*.tar.gz" | wc -l)

    total_size=$(du -sh "$BACKUP_ROOT" | awk '{print $1}')

    largest_backup=$(find "$BACKUP_ROOT" -name "*.tar.gz" \
        -exec ls -Sh {} + 2>/dev/null | head -1 | awk '{print $NF}')

    newest_backup=$(find "$BACKUP_ROOT" -name "*.tar.gz" \
        -exec ls -t {} + 2>/dev/null | head -1)

    echo "Total Backups : $total_backups"

    echo "Storage Used  : $total_size"

    echo "Largest Backup: ${largest_backup:-N/A}"

    echo "Latest Backup : ${newest_backup:-N/A}"

    echo

    backup_success \
    "BACKUP_STATISTICS" \
    "Viewed statistics"

    pause_screen

}

# ==========================================================
# Cleanup Old Backups
# ==========================================================

cleanup_old_backups() {

    show_module "Retention Policy"

    backup_initialize

    read -rp "Keep Latest (Number): " keep

    validate_number "$keep" || return

    loading "Cleaning Old Backups..."

    backups=$(ls -t "$BACKUP_ROOT"/*.tar.gz 2>/dev/null)

    count=0

    for backup in $backups
    do

        ((count++))

        if [[ $count -gt $keep ]]
        then

            rm -f "$backup"

            backup_success \
            "DELETE_OLD_BACKUP" \
            "$backup"

        fi

    done

    success "Retention policy applied."

    pause_screen

}

# ==========================================================
# Backup Health Check
# ==========================================================

backup_health_check() {

    show_module "Backup Health"

    backup_initialize

    echo

    available_space=$(df -h "$BACKUP_ROOT" | awk 'NR==2 {print $4}')

    filesystem=$(df -h "$BACKUP_ROOT" | awk 'NR==2 {print $1}')

    echo "Filesystem      : $filesystem"

    echo "Available Space : $available_space"

    echo

    success "Backup storage is accessible."

    backup_success \
    "HEALTH_CHECK" \
    "$BACKUP_ROOT"

    pause_screen

}

# ==========================================================
# Preview Backup Contents
# ==========================================================

preview_backup() {

    show_module "Preview Backup"

    read -rp "Backup Archive : " archive

    validate_not_empty "$archive" || return
    validate_file_exists "$archive" || return

    echo

    tar -tvf "$archive"

    echo

    backup_success \
    "PREVIEW_BACKUP" \
    "$archive"

    pause_screen

}

# ==========================================================
# Generate SHA256 Checksum
# ==========================================================

generate_checksum() {

    show_module "Generate SHA256"

    read -rp "Backup Archive : " archive

    validate_not_empty "$archive" || return
    validate_file_exists "$archive" || return

    loading "Generating Checksum..."

    sha256sum "$archive" > "$archive.sha256"

    success "Checksum generated."

    info "$archive.sha256"

    backup_success \
    "CHECKSUM_GENERATED" \
    "$archive"

    pause_screen

}

# ==========================================================
# Verify SHA256 Checksum
# ==========================================================

verify_checksum() {

    show_module "Verify SHA256"

    read -rp "Checksum File : " checksum

    validate_not_empty "$checksum" || return
    validate_file_exists "$checksum" || return

    loading "Verifying..."

    if sha256sum -c "$checksum"
    then

        success "Integrity Verified."

        backup_success \
        "VERIFY_CHECKSUM" \
        "$checksum"

    else

        error "Checksum verification failed."

        backup_failure \
        "VERIFY_CHECKSUM" \
        "$checksum"

    fi

    pause_screen

}

# ==========================================================
# Schedule Backup (Cron)
# ==========================================================

schedule_backup() {

    show_module "Schedule Backup"

    warning "Automatic scheduling requires cron."

    echo

    info "Example Cron Entry"

    echo

    echo "0 2 * * * /path/to/linuxops.sh"

    echo

    pause_screen

}

# ==========================================================
# Backup Menu
# ==========================================================

backup_menu() {

    while true
    do

        show_module "Backup Management"

        show_menu_option 1  "Create Backup"
        show_menu_option 2  "Restore Backup"
        show_menu_option 3  "Verify Backup"
        show_menu_option 4  "List Backups"
        show_menu_option 5  "Delete Backup"
        show_menu_option 6  "Backup Information"
        show_menu_option 7  "Backup Statistics"
        show_menu_option 8  "Cleanup Old Backups"
        show_menu_option 9  "Backup Health Check"
        show_menu_option 10 "Preview Backup"
        show_menu_option 11 "Generate SHA256"
        show_menu_option 12 "Verify SHA256"
        show_menu_option 13 "Schedule Backup"

        separator

        show_menu_option 0 "Back"

        separator

        read -rp "Select Option : " option

        case "$option" in

            1)  create_backup ;;
            2)  restore_backup ;;
            3)  verify_backup ;;
            4)  list_backups ;;
            5)  delete_backup ;;
            6)  backup_information ;;
            7)  backup_statistics ;;
            8)  cleanup_old_backups ;;
            9)  backup_health_check ;;
            10) preview_backup ;;
            11) generate_checksum ;;
            12) verify_checksum ;;
            13) schedule_backup ;;
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

backup_manager() {

    backup_menu

}

# ==========================================================
# Execute Directly
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then

    backup_manager

fi


