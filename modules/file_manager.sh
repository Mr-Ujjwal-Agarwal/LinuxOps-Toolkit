#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Module  : File Management
# Version : 1.0.0
# Author  : Ujjwal Agarwal
# ==========================================================

# ==========================================================
# Helper Functions
# ==========================================================

FILE_LOG="$REPORT_DIR/linuxops.log"

file_log() {

    local action="$1"
    local target="$2"

    mkdir -p "$REPORT_DIR"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] | $action | $target" >> "$FILE_LOG"
}

file_confirm() {

    local message="$1"

    echo
    warning "$message"

    read -rp "Continue? (y/n): " confirm

    case "$confirm" in

        y|Y)

            return 0

            ;;

        *)

            info "Operation cancelled."

            pause_screen

            return 1

            ;;

    esac

}

file_directory_exists() {

    [[ -d "$1" ]]

}

file_file_exists() {

    [[ -f "$1" ]]

}

file_validate_input() {

    local input="$1"

    if [[ -z "$input" ]]
    then

        error "Input cannot be empty."

        pause_screen

        return 1

    fi

    return 0

}

file_show_header() {

    clear

    title "========================================================"

    title "                FILE MANAGEMENT MODULE"

    title "========================================================"

    echo

    info "Current Directory : $(pwd)"

    echo

}

# ==========================================================
# Create Directory
# ==========================================================

file_create_directory() {

    file_show_header

    title "Create Directory"

    echo

    read -rp "Directory Path : " directory_path

    file_validate_input "$directory_path" || return

    if file_directory_exists "$directory_path"
    then

        warning "Directory already exists."

        pause_screen

        return

    fi

    if mkdir -p "$directory_path"
    then

        success "Directory created successfully."

        info "Location : $(realpath "$directory_path" 2>/dev/null)"

        file_log "CREATE_DIRECTORY" "$directory_path"

    else

        error "Unable to create directory."

    fi

    echo

    pause_screen

}

# ==========================================================
# Delete Directory
# ==========================================================

file_delete_directory() {

    file_show_header

    title "Delete Directory"

    echo

    read -rp "Directory Path : " directory_path

    file_validate_input "$directory_path" || return

    if ! file_directory_exists "$directory_path"
    then

        error "Directory not found."

        pause_screen

        return

    fi

    file_confirm "This directory and ALL of its contents will be permanently deleted." || return

    if rm -rf "$directory_path"
    then

        if ! file_directory_exists "$directory_path"
        then

            success "Directory deleted successfully."

            file_log "DELETE_DIRECTORY" "$directory_path"

        else

            error "Directory still exists."

        fi

    else

        error "Unable to delete directory."

    fi

    echo

    pause_screen

}

# ==========================================================
# Create File
# ==========================================================

file_create_file() {

    file_show_header

    title "Create File"

    echo

    read -rp "File Path : " file_path

    file_validate_input "$file_path" || return

    if file_file_exists "$file_path"
    then

        warning "File already exists."

        pause_screen

        return

    fi

    if touch "$file_path"
    then

        success "File created successfully."

        info "Location : $(realpath "$file_path" 2>/dev/null)"

        file_log "CREATE_FILE" "$file_path"

    else

        error "Unable to create file."

    fi

    echo

    pause_screen

}

# ==========================================================
# Delete File
# ==========================================================

file_delete_file() {

    file_show_header

    title "Delete File"

    echo

    read -rp "File Path : " file_path

    file_validate_input "$file_path" || return

    if ! file_file_exists "$file_path"
    then

        error "File not found."

        pause_screen

        return

    fi

    file_confirm "This file will be permanently deleted." || return

    if rm -f "$file_path"
    then

        success "File deleted successfully."

        file_log "DELETE_FILE" "$file_path"

    else

        error "Unable to delete file."

    fi

    echo

    pause_screen

}

# ==========================================================
# Copy File
# ==========================================================

file_copy_file() {

    file_show_header

    title "Copy File"

    echo

    read -rp "Source File      : " source_file
    file_validate_input "$source_file" || return

    if ! file_file_exists "$source_file"
    then
        error "Source file does not exist."
        pause_screen
        return
    fi

    read -rp "Destination Path : " destination_file
    file_validate_input "$destination_file" || return

    if cp "$source_file" "$destination_file"
    then
        success "File copied successfully."

        file_log "COPY_FILE" "$source_file -> $destination_file"

    else

        error "Unable to copy file."

    fi

    echo

    pause_screen

}

# ==========================================================
# Move File
# ==========================================================

file_move_file() {

    file_show_header

    title "Move File"

    echo

    read -rp "Source File      : " source_file
    file_validate_input "$source_file" || return

    if ! file_file_exists "$source_file"
    then

        error "Source file not found."

        pause_screen

        return

    fi

    read -rp "Destination Path : " destination_file
    file_validate_input "$destination_file" || return

    if mv "$source_file" "$destination_file"
    then

        success "File moved successfully."

        file_log "MOVE_FILE" "$source_file -> $destination_file"

    else

        error "Unable to move file."

    fi

    echo

    pause_screen

}

# ==========================================================
# Rename File
# ==========================================================

file_rename_file() {

    file_show_header

    title "Rename File"

    echo

    read -rp "Current File Path : " current_file
    file_validate_input "$current_file" || return

    if ! file_file_exists "$current_file"
    then

        error "File not found."

        pause_screen

        return

    fi

    read -rp "New File Name : " new_name
    file_validate_input "$new_name" || return

    new_path="$(dirname "$current_file")/$new_name"

    if mv "$current_file" "$new_path"
    then

        success "File renamed successfully."

        file_log "RENAME_FILE" "$current_file -> $new_path"

    else

        error "Unable to rename file."

    fi

    echo

    pause_screen

}

# ==========================================================
# Search File
# ==========================================================

file_search() {

    file_show_header

    title "Search File"

    echo

    read -rp "Enter File Name : " search_name

    file_validate_input "$search_name" || return

    echo

    info "Searching..."

    results=$(find . -iname "*$search_name*" 2>/dev/null)

    echo

    if [[ -z "$results" ]]
    then

        warning "No files found."

    else

        success "Search Results"

        echo

        echo "$results"

        file_log "SEARCH_FILE" "$search_name"

    fi

    echo

    pause_screen

}

# ==========================================================
# Change Permission
# ==========================================================

file_change_permission() {

    file_show_header

    title "Change File Permission"

    echo

    read -rp "File Path : " file_path

    file_validate_input "$file_path" || return

    if ! file_file_exists "$file_path"
    then

        error "File not found."

        pause_screen

        return

    fi

    read -rp "Permission (Example 755): " permission

    if chmod "$permission" "$file_path"
    then

        success "Permission updated successfully."

        file_log "CHANGE_PERMISSION" "$file_path ($permission)"

    else

        error "Unable to change permission."

    fi

    echo

    pause_screen

}

# ==========================================================
# File Information
# ==========================================================

file_information() {

    file_show_header

    title "File Information"

    echo

    read -rp "File Path : " file_path

    file_validate_input "$file_path" || return

    if ! file_file_exists "$file_path"
    then

        error "File not found."

        pause_screen

        return

    fi

    echo

    stat "$file_path"

    echo

    file_log "VIEW_INFORMATION" "$file_path"

    pause_screen

}

# ==========================================================
# File Feature Pending
# ==========================================================

file_feature_pending() {

    warning "Feature under development."

    echo

    pause_screen

}

# ==========================================================
# File Management Dashboard
# ==========================================================

file_manager_menu() {

    while true
    do

        file_show_header

        echo "1.  Create Directory"
        echo "2.  Delete Directory"
        echo "3.  Create File"
        echo "4.  Delete File"
        echo "5.  Copy File"
        echo "6.  Move File"
        echo "7.  Rename File"
        echo "8.  Search File"
        echo "9.  Change Permission"
        echo "10. File Information"
        echo
        echo "11. Back to Main Menu"

        echo

        read -rp "Choose Option : " option

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

                file_show_header

                title "Search File"

                echo

                read -rp "Search Directory : " search_directory

                file_validate_input "$search_directory" || continue

                if [[ ! -d "$search_directory" ]]
                then

                    error "Directory not found."

                    pause_screen

                    continue

                fi

                read -rp "File Name : " search_name

                file_validate_input "$search_name" || continue

                echo

                info "Searching..."

                echo

                results=$(find "$search_directory" -iname "*$search_name*" 2>/dev/null)

                if [[ -z "$results" ]]
                then

                    warning "No matching files found."

                else

                    success "Search Results"

                    echo

                    echo "$results"

                    file_log "SEARCH_FILE" "$search_directory/$search_name"

                fi

                echo

                pause_screen

                ;;

            9)

                file_show_header

                title "Change Permission"

                echo

                read -rp "File Path : " file_path

                file_validate_input "$file_path" || continue

                if ! file_file_exists "$file_path"
                then

                    error "File not found."

                    pause_screen

                    continue

                fi

                read -rp "Permission (000-777): " permission

                if [[ ! "$permission" =~ ^[0-7]{3}$ ]]
                then

                    error "Invalid permission."

                    pause_screen

                    continue

                fi

                if chmod "$permission" "$file_path"
                then

                    success "Permission changed successfully."

                    file_log "CHANGE_PERMISSION" "$file_path"

                else

                    error "Unable to change permission."

                fi

                echo

                pause_screen

                ;;

            10)

                file_information

                ;;

            11)

                return

                ;;

            *)

                error "Invalid Option."

                sleep 1

                ;;

        esac

    done

}


