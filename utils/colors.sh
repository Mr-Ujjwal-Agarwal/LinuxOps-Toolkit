#!/bin/bash

# ==========================================
# Color Definitions
# ==========================================

RESET="\e[0m"

BLACK="\e[30m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"

BOLD="\e[1m"

SUCCESS="${GREEN}${BOLD}"
ERROR="${RED}${BOLD}"
WARNING="${YELLOW}${BOLD}"
INFO="${CYAN}${BOLD}"
TITLE="${BLUE}${BOLD}"

success() {
    echo -e "${SUCCESS}$1${RESET}"
}

error() {
    echo -e "${ERROR}$1${RESET}"
}

warning() {
    echo -e "${WARNING}$1${RESET}"
}

info() {
    echo -e "${INFO}$1${RESET}"
}

title() {
    echo -e "${TITLE}$1${RESET}"
}
