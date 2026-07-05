#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Utility : Colors
# Version : 1.0.0
# ==========================================================

# Reset
RESET="\e[0m"

# Regular Colors
BLACK="\e[30m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"

# Bright Colors
BRIGHT_BLACK="\e[90m"
BRIGHT_RED="\e[91m"
BRIGHT_GREEN="\e[92m"
BRIGHT_YELLOW="\e[93m"
BRIGHT_BLUE="\e[94m"
BRIGHT_MAGENTA="\e[95m"
BRIGHT_CYAN="\e[96m"
BRIGHT_WHITE="\e[97m"

# Styles
BOLD="\e[1m"
UNDERLINE="\e[4m"

# ==========================================================
# Generic Printer
# ==========================================================

print_color() {

    local color="$1"
    local message="$2"

    echo -e "${color}${message}${RESET}"

}

# ==========================================================
# Message Functions
# ==========================================================

success() {

    print_color "${BRIGHT_GREEN}${BOLD}" "✔ $1"

}

error() {

    print_color "${BRIGHT_RED}${BOLD}" "✖ $1"

}

warning() {

    print_color "${BRIGHT_YELLOW}${BOLD}" "⚠ $1"

}

info() {

    print_color "${BRIGHT_CYAN}" "➜ $1"

}

heading() {

    echo
    print_color "${BRIGHT_BLUE}${BOLD}" "$1"
    echo

}

sub_heading() {

    print_color "${MAGENTA}${BOLD}" "$1"

}

highlight() {

    print_color "${BRIGHT_WHITE}${BOLD}" "$1"

}

# ==========================================================
# UI Helpers
# ==========================================================

separator() {

    printf '%*s\n' "$(tput cols 2>/dev/null || echo 80)" '' | tr ' ' '='

}

blank() {

    echo

}

