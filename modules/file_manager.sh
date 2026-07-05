#!/bin/bash

# ==========================================
# LinuxOps Toolkit
# File Management Module
# ==========================================

# ==========================================
# Create Directory
# ==========================================

file_create_directory() {

    clear

    title "========== Create Directory =========="

    echo

    read -rp "Enter directory path: " directory

    if [[ -z "$directory" ]]; then
        error "Directory path cannot be empty."
        pause_screen
        return
    fi

    if [[ -d "$directory" ]]; then
        warning "Directory already exists."
        pause_screen
        return
    fi

    if mkdir -p "$directory"; then
        success "Directory created successfully."
    else
        error "Failed to create directory."
    fi

    echo
    pause_screen
}

# ==========================================
# Delete Directory
# ==========================================

file_delete_directory() {

    clear

    title "========== Delete Directory =========="

    echo

    read -rp "Enter directory path: " directory

    if [[ -z "$directory" ]]; then
        error "Directory path cannot be empty."
        pause_screen
        return
    fi

    if [[ ! -d "$directory" ]]; then
        error "Directory does not exist."
        pause_screen
        return
    fi

    echo
    warning "WARNING!"
    warning "This operation will permanently delete:"
    echo "$directory"
    echo

    read -rp "Continue? (y/n): " confirm

    case "$confirm" in

        y|Y)

            if rm -rf "$directory"; then
                success "Directory deleted successfully."
            else
                error "Failed to delete directory."
            fi

            ;;

        *)

            info "Operation cancelled."

            ;;

    esac

    echo
    pause_screen
}

# ==========================================
# Placeholder
# ==========================================

file_feature_pending() {

    echo
    warning "This feature will be available in the next sprint."
    echo

    pause_screen

}

# ==========================================
# File Management Dashboard
# ==========================================

file_manager_menu() {

    while true
    do

        clear

        title "========== File Management =========="

        echo

        echo "1. Create Directory"
        echo "2. Delete Directory"
        echo "3. Create File"
        echo "4. Delete File"
        echo "5. Copy File"
        echo "6. Move File"
        echo "7. Rename File"
        echo "8. Search File"
        echo "9. Change Permission"
        echo "10. File Information"
        echo "11. Back"

        echo

        read -rp "Choose an option: " choice

        case "$choice" in

            1)

                file_create_directory

                ;;

            2)

                file_delete_directory

                ;;

            3|4|5|6|7|8|9|10)

                file_feature_pending

                ;;

            11)

                return

                ;;

            *)

                error "Invalid option."

                sleep 1

                ;;

        esac

    done

}
