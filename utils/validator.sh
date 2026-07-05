#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Utility : Validator
# Version : 1.0.0
# ==========================================================

source utils/colors.sh
source utils/ui.sh

# ==========================================================
# Empty Input Validation
# ==========================================================

validate_not_empty() {

    local input="$1"

    if [[ -z "$input" ]]
    then

        error "Input cannot be empty."

        pause_screen

        return 1

    fi

    return 0

}

# ==========================================================
# Directory Exists
# ==========================================================

validate_directory_exists() {

    local directory="$1"

    if [[ ! -d "$directory" ]]
    then

        error "Directory not found."

        pause_screen

        return 1

    fi

    return 0

}

# ==========================================================
# Directory Does Not Exist
# ==========================================================

validate_directory_not_exists() {

    local directory="$1"

    if [[ -d "$directory" ]]
    then

        warning "Directory already exists."

        pause_screen

        return 1

    fi

    return 0

}

# ==========================================================
# File Exists
# ==========================================================

validate_file_exists() {

    local file="$1"

    if [[ ! -f "$file" ]]
    then

        error "File not found."

        pause_screen

        return 1

    fi

    return 0

}

# ==========================================================
# File Does Not Exist
# ==========================================================

validate_file_not_exists() {

    local file="$1"

    if [[ -f "$file" ]]
    then

        warning "File already exists."

        pause_screen

        return 1

    fi

    return 0

}

# ==========================================================
# Permission Validation
# ==========================================================

validate_permission() {

    local permission="$1"

    if [[ ! "$permission" =~ ^[0-7]{3}$ ]]
    then

        error "Permission must be between 000 and 777."

        pause_screen

        return 1

    fi

    return 0

}

# ==========================================================
# Number Validation
# ==========================================================

validate_number() {

    local number="$1"

    if [[ ! "$number" =~ ^[0-9]+$ ]]
    then

        error "Please enter a valid number."

        pause_screen

        return 1

    fi

    return 0

}

# ==========================================================
# Yes / No Validation
# ==========================================================

validate_yes_no() {

    local answer="$1"

    case "$answer" in

        y|Y|yes|YES)

            return 0

            ;;

        n|N|no|NO)

            return 1

            ;;

        *)

            warning "Please enter Yes or No."

            pause_screen

            return 2

            ;;

    esac

}

# ==========================================================
# Validate Read Permission
# ==========================================================

validate_read_permission() {

    local file="$1"

    if [[ ! -r "$file" ]]
    then

        error "Read permission denied."

        pause_screen

        return 1

    fi

    return 0

}

# ==========================================================
# Validate Write Permission
# ==========================================================

validate_write_permission() {

    local file="$1"

    if [[ ! -w "$file" ]]
    then

        error "Write permission denied."

        pause_screen

        return 1

    fi

    return 0

}

# ==========================================================
# Validate Execute Permission
# ==========================================================

validate_execute_permission() {

    local file="$1"

    if [[ ! -x "$file" ]]
    then

        error "Execute permission denied."

        pause_screen

        return 1

    fi

    return 0

}
