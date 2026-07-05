#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Utility : Loader
# Version : 1.0.0
# ==========================================================

source utils/colors.sh

# ==========================================================
# Spinner Loader
# ==========================================================

spinner() {

    local pid=$1
    local delay=0.10
    local spin='|/-\'

    while ps -p "$pid" >/dev/null 2>&1
    do
        for i in $(seq 0 3)
        do
            printf "\r${BRIGHT_CYAN}[%c] Processing...${RESET}" "${spin:$i:1}"
            sleep "$delay"
        done
    done

    printf "\r%-40s\r" " "

}

# ==========================================================
# Progress Bar
# ==========================================================

progress_bar() {

    local message="$1"

    echo
    info "$message"
    echo

    for i in {0..100..5}
    do

        filled=$((i/5))
        empty=$((20-filled))

        printf "\r["

        for ((j=0;j<filled;j++))
        do
            printf "#"
        done

        for ((j=0;j<empty;j++))
        do
            printf "-"
        done

        printf "] %3d%%" "$i"

        sleep 0.05

    done

    echo
    success "Completed."

}

# ==========================================================
# Execute With Spinner
# ==========================================================

run_with_spinner() {

    "$@" &

    spinner $!

    wait

}

# ==========================================================
# Fake Loading
# ==========================================================

loading() {

    local message="${1:-Loading...}"

    progress_bar "$message"

}

# ==========================================================
# Countdown
# ==========================================================

countdown() {

    local seconds="$1"

    while [[ "$seconds" -gt 0 ]]
    do

        printf "\rStarting in %2d second(s)... " "$seconds"

        sleep 1

        ((seconds--))

    done

    echo

}

# ==========================================================
# Success Animation
# ==========================================================

success_animation() {

    printf "\n"

    success "Operation Completed Successfully."

    printf "\n"

}
