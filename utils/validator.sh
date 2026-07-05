#!/bin/bash

# ==========================================
# Input Validation Functions
# ==========================================

validate_number() {

    [[ "$1" =~ ^[0-9]+$ ]]

}

validate_directory() {

    [[ -d "$1" ]]

}

validate_file() {

    [[ -f "$1" ]]

}

pause_screen() {

    echo
    read -rp "Press Enter to continue..."

}
