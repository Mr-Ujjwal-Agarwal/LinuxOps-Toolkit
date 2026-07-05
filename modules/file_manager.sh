#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Module  : File Management
# Version : 2.0.0
# ==========================================================

source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/logger.sh
source utils/loader.sh

MODULE_NAME="FILE_MANAGER"

# ==========================================================
# Helper Functions
# ==========================================================

confirm_action() {

    local message="$1"

    echo
    warning "$message"

    read -rp "Continue? (y/n): " choice

    validate_yes_no "$choice"

    [[ $? -eq 0 ]]

}

log_success_action() {

    local action="$1"
    local details="$2"

    log_success "$MODULE_NAME" "$action" "$details"

}

log_error_action() {

    local action="$1"
    local details="$2"

    log_error "$MODULE_NAME" "$action" "$details"

}

# ==========================================================
# Create Directory
# ==========================================================

file_create_directory() {

    show_module "Create Directory"

    read -rp "Directory Path : " directory_path

    validate_not_empty "$directory_path" || return

    validate_directory_not_exists "$directory_path" || return

    loading "Creating Directory..."

    if mkdir -p "$directory_path"
    then

        success "Directory created successfully."

        info "$(realpath "$directory_path" 2>/dev/null)"

        log_success_action "CREATE_DIRECTORY" "$directory_path"

    else

        error "Unable to create directory."

        log_error_action "CREATE_DIRECTORY" "$directory_path"

    fi

    pause_screen

}

# ==========================================================
# Delete Directory
# ==========================================================

file_delete_directory() {

    show_module "Delete Directory"

    read -rp "Directory Path : " directory_path

    validate_not_empty "$directory_path" || return

    validate_directory_exists "$directory_path" || return

    confirm_action "Delete directory permanently?" || return

    loading "Deleting Directory..."

    if rm -rf "$directory_path"
    then

        success "Directory deleted successfully."

        log_success_action "DELETE_DIRECTORY" "$directory_path"

    else

        error "Unable to delete directory."

        log_error_action "DELETE_DIRECTORY" "$directory_path"

    fi

    pause_screen

}

# ==========================================================
# Create File
# ==========================================================

file_create_file() {

    show_module "Create File"

    read -rp "File Path : " file_path

    validate_not_empty "$file_path" || return

    validate_file_not_exists "$file_path" || return

    loading "Creating File..."

    if touch "$file_path"
    then

        success "File created successfully."

        info "$(realpath "$file_path" 2>/dev/null)"

        log_success_action "CREATE_FILE" "$file_path"

    else

        error "Unable to create file."

        log_error_action "CREATE_FILE" "$file_path"

    fi

    pause_screen

}

# ==========================================================
# Delete File
# ==========================================================

file_delete_file() {

    show_module "Delete File"

    read -rp "File Path : " file_path

    validate_not_empty "$file_path" || return

    validate_file_exists "$file_path" || return

    confirm_action "Delete file permanently?" || return

    loading "Deleting File..."

    if rm -f "$file_path"
    then

        success "File deleted successfully."

        log_success_action "DELETE_FILE" "$file_path"

    else

        error "Unable to delete file."

        log_error_action "DELETE_FILE" "$file_path"

    fi

    pause_screen

}

# ==========================================================
# Copy File
# ==========================================================

file_copy_file() {

    show_module "Copy File"

    read -rp "Source File      : " source_file
    validate_not_empty "$source_file" || return
    validate_file_exists "$source_file" || return

    read -rp "Destination File : " destination_file
    validate_not_empty "$destination_file" || return

    if [[ -f "$destination_file" ]]
    then
        confirm_action "Destination file exists. Overwrite?" || return
    fi

    loading "Copying File..."

    if cp -f "$source_file" "$destination_file"
    then

        success "File copied successfully."

        log_success_action \
        "COPY_FILE" \
        "$source_file -> $destination_file"

    else

        error "Failed to copy file."

        log_error_action \
        "COPY_FILE" \
        "$source_file"

    fi

    pause_screen

}

# ==========================================================
# Move File
# ==========================================================

file_move_file() {

    show_module "Move File"

    read -rp "Source File      : " source_file
    validate_not_empty "$source_file" || return
    validate_file_exists "$source_file" || return

    read -rp "Destination Path : " destination_path
    validate_not_empty "$destination_path" || return

    loading "Moving File..."

    if mv "$source_file" "$destination_path"
    then

        success "File moved successfully."

        log_success_action \
        "MOVE_FILE" \
        "$source_file -> $destination_path"

    else

        error "Failed to move file."

        log_error_action \
        "MOVE_FILE" \
        "$source_file"

    fi

    pause_screen

}

# ==========================================================
# Rename File
# ==========================================================

file_rename_file() {

    show_module "Rename File"

    read -rp "Current File : " current_file
    validate_not_empty "$current_file" || return
    validate_file_exists "$current_file" || return

    read -rp "New Name : " new_name
    validate_not_empty "$new_name" || return

    new_path="$(dirname "$current_file")/$new_name"

    loading "Renaming File..."

    if mv "$current_file" "$new_path"
    then

        success "File renamed successfully."

        log_success_action \
        "RENAME_FILE" \
        "$current_file -> $new_path"

    else

        error "Failed to rename file."

        log_error_action \
        "RENAME_FILE" \
        "$current_file"

    fi

    pause_screen

}

# ==========================================================
# Search File
# ==========================================================

file_search() {

    show_module "Search File"

    read -rp "Search Directory : " search_directory
    validate_not_empty "$search_directory" || return
    validate_directory_exists "$search_directory" || return

    read -rp "File Name : " search_name
    validate_not_empty "$search_name" || return

    loading "Searching..."

    results=$(find "$search_directory" \
    -iname "*$search_name*" \
    2>/dev/null)

    echo

    if [[ -z "$results" ]]
    then

        warning "No matching files found."

        log_error_action \
        "SEARCH_FILE" \
        "$search_name"

    else

        success "Search Results"

        echo

        echo "$results"

        log_success_action \
        "SEARCH_FILE" \
        "$search_name"

    fi

    pause_screen

}

# ==========================================================
# Change Permission
# ==========================================================

file_change_permission() {

    show_module "Permission Manager"

    read -rp "File Path : " file_path
    validate_not_empty "$file_path" || return
    validate_file_exists "$file_path" || return

    read -rp "Permission (000-777) : " permission
    validate_permission "$permission" || return

    loading "Updating Permission..."

    if chmod "$permission" "$file_path"
    then

        success "Permission updated."

        log_success_action \
        "CHANGE_PERMISSION" \
        "$file_path ($permission)"

    else

        error "Permission update failed."

        log_error_action \
        "CHANGE_PERMISSION" \
        "$file_path"

    fi

    pause_screen

}

# ==========================================================
# File Information
# ==========================================================

file_information() {

    show_module "File Information"

    read -rp "File Path : " file_path
    validate_not_empty "$file_path" || return
    validate_file_exists "$file_path" || return

    echo

    stat "$file_path"

    log_success_action \
    "FILE_INFORMATION" \
    "$file_path"

    pause_screen

}

# ==========================================================
# File Management Menu
# ==========================================================

file_manager_menu() {

    while true
    do

        show_module "File Management"

        show_menu_option 1  "Create Directory"
        show_menu_option 2  "Delete Directory"
        show_menu_option 3  "Create File"
        show_menu_option 4  "Delete File"
        show_menu_option 5  "Copy File"
        show_menu_option 6  "Move File"
        show_menu_option 7  "Rename File"
        show_menu_option 8  "Search File"
        show_menu_option 9  "Change Permission"
        show_menu_option 10 "File Information"

        separator

        show_menu_option 0 "Back"

        separator

        read -rp "Select Option : " option

        case "$option" in

            1)

                file_create_directory
                ;;

            2)

                file_delete_directory
                ;;

            3)

                file_create_file
                ;;

            4)

                file_delete_file
                ;;

            5)

                file_copy_file
                ;;

            6)

                file_move_file
                ;;

            7)

                file_rename_file
                ;;

            8)

                file_search
                ;;

            9)

                file_change_permission
                ;;

            10)

                file_information
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
# Module Entry Point
# ==========================================================

file_manager() {

    file_manager_menu

}

# ==========================================================
# Execute Directly
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then

    file_manager

fi

