#!/bin/bash

# ==========================================
# File Management Module
# ==========================================

create_directory() {

    clear

    title "========== Create Directory =========="

    echo

    read -rp "Enter directory path: " dir

    if [[ -z "$dir" ]]
    then
        error "Directory path cannot be empty."

        pause_screen

        return
    fi

    if mkdir -p "$dir" 2>/dev/null
    then
        success "Directory created successfully."
    else
        error "Failed to create directory."
    fi

    echo

    pause_screen
}

delete_directory() {

    clear

    title "========== Delete Directory =========="

    echo

    read -rp "Enter directory path: " dir

    if [[ -z "$dir" ]]
    then
        error "Directory path cannot be empty."

        pause_screen

        return
    fi

    if [[ ! -d "$dir" ]]
    then
        error "Directory does not exist."

        pause_screen

        return
    fi

    echo

    warning "Are you sure you want to delete this directory?"

    read -rp "(y/n): " choice

    case "$choice" in

        y|Y)

            rm -rf "$dir"

            success "Directory deleted successfully."

            ;;

        *)

            warning "Operation cancelled."

            ;;

    esac

    echo

    pause_screen

}

coming_soon() {

    echo

    warning "Feature under development."

    echo

    pause_screen

}

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

read -rp "Choose Option: " choice

case "$choice" in

1)

create_directory

;;

2)

delete_directory

;;

3|4|5|6|7|8|9|10)

coming_soon

;;

11)

return

;;

*)

error "Invalid Choice."

sleep 1

;;

esac

done

}
