#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Module : Health Monitoring
# Version : 1.0.0
# ==========================================================

source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/logger.sh
source utils/loader.sh

MODULE_NAME="HEALTH_MANAGER"

# ==========================================================
# Helper Functions
# ==========================================================

health_success() {

    log_success \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

health_failure() {

    log_error \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

# ==========================================================
# Health Dashboard
# ==========================================================

health_dashboard() {

    show_module "System Health Dashboard"

    cpu_usage=$(top -bn1 | awk -F',' '/Cpu/ {gsub("%",""); print 100-$4}')

    memory_usage=$(free | awk '/Mem:/ {printf "%.1f",($3/$2)*100}')

    swap_usage=$(free | awk '/Swap:/ {if($2==0) print 0; else printf "%.1f",($3/$2)*100}')

    disk_usage=$(df / | awk 'NR==2 {print $5}')

    load_average=$(uptime | awk -F'load average:' '{print $2}')

    echo

    highlight "System Overview"

    separator

    printf "%-25s : %s%%\n" "CPU Usage" "$cpu_usage"

    printf "%-25s : %s%%\n" "Memory Usage" "$memory_usage"

    printf "%-25s : %s%%\n" "Swap Usage" "$swap_usage"

    printf "%-25s : %s\n" "Disk Usage" "$disk_usage"

    printf "%-25s : %s\n" "Load Average" "$load_average"

    echo

    pause_screen

}

# ==========================================================
# CPU Usage
# ==========================================================

cpu_usage_report() {

    show_module "CPU Usage"

    echo

    top -bn1 | head -10

    echo

    health_success \
    "CPU_USAGE" \
    "Viewed CPU usage"

    pause_screen

}

# ==========================================================
# Memory Usage
# ==========================================================

memory_usage_report() {

    show_module "Memory Usage"

    echo

    free -h

    echo

    health_success \
    "MEMORY_USAGE" \
    "Viewed memory usage"

    pause_screen

}

# ==========================================================
# Swap Usage
# ==========================================================

swap_usage_report() {

    show_module "Swap Usage"

    echo

    free -h

    echo

    swapon --show

    echo

    health_success \
    "SWAP_USAGE" \
    "Viewed swap usage"

    pause_screen

}

# ==========================================================
# Load Average
# ==========================================================

load_average_report() {

    show_module "Load Average"

    echo

    uptime

    echo

    cat /proc/loadavg

    echo

    health_success \
    "LOAD_AVERAGE" \
    "Viewed load average"

    pause_screen

}

# ==========================================================
# Uptime
# ==========================================================

uptime_report() {

    show_module "System Uptime"

    echo

    uptime -p

    echo

    uptime

    echo

    health_success \
    "UPTIME" \
    "Viewed uptime"

    pause_screen

}

# ==========================================================
# Top CPU Consumers
# ==========================================================

top_cpu_processes() {

    show_module "Top CPU Consumers"

    echo

    ps -eo pid,user,%cpu,%mem,comm \
    --sort=-%cpu | head -11

    echo

    health_success \
    "TOP_CPU" \
    "Viewed top CPU consumers"

    pause_screen

}

# ==========================================================
# Top Memory Consumers
# ==========================================================

top_memory_processes() {

    show_module "Top Memory Consumers"

    echo

    ps -eo pid,user,%cpu,%mem,comm \
    --sort=-%mem | head -11

    echo

    health_success \
    "TOP_MEMORY" \
    "Viewed top memory consumers"

    pause_screen

}

# ==========================================================
# Disk Health
# ==========================================================

disk_health_report() {

    show_module "Disk Health"

    echo

    df -h /

    echo

    usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

    if [[ "$usage" -ge 90 ]]
    then

        error "Critical Disk Usage"

    elif [[ "$usage" -ge 75 ]]
    then

        warning "High Disk Usage"

    else

        success "Disk Usage Healthy"

    fi

    echo

    health_success \
    "DISK_HEALTH" \
    "Completed"

    pause_screen

}

# ==========================================================
# Network Health
# ==========================================================

network_health_report() {

    show_module "Network Health"

    echo

    highlight "Internet Connectivity"

    separator

    if ping -c 2 8.8.8.8 >/dev/null 2>&1
    then

        success "Internet : Connected"

    else

        error "Internet : Unreachable"

    fi

    echo

    highlight "DNS Resolution"

    separator

    if getent hosts google.com >/dev/null 2>&1
    then

        success "DNS : Working"

    else

        error "DNS : Failed"

    fi

    echo

    health_success \
    "NETWORK_HEALTH" \
    "Completed"

    pause_screen

}

# ==========================================================
# CPU Temperature
# ==========================================================

temperature_report() {

    show_module "CPU Temperature"

    echo

    if command -v sensors >/dev/null 2>&1
    then

        sensors

    else

        warning "lm-sensors package is not installed."

        info "Install using your package manager."

    fi

    echo

    health_success \
    "TEMPERATURE" \
    "Viewed temperature"

    pause_screen

}

# ==========================================================
# Live Monitor
# ==========================================================

live_monitor() {

    show_module "Live System Monitor"

    info "Press CTRL+C to stop monitoring."

    sleep 2

    while true
    do

        clear

        cpu=$(top -bn1 | awk -F',' '/Cpu/ {gsub("%",""); print 100-$4}')

        memory=$(free | awk '/Mem:/ {printf "%.1f",($3/$2)*100}')

        swap=$(free | awk '/Swap:/ {if($2==0) print 0; else printf "%.1f",($3/$2)*100}')

        disk=$(df / | awk 'NR==2 {print $5}')

        load=$(awk '{print $1}' /proc/loadavg)

        echo "=============================================="

        echo "        LinuxOps Live Health Monitor"

        echo "=============================================="

        echo

        printf "%-20s : %s%%\n" "CPU Usage" "$cpu"

        printf "%-20s : %s%%\n" "Memory Usage" "$memory"

        printf "%-20s : %s%%\n" "Swap Usage" "$swap"

        printf "%-20s : %s\n" "Disk Usage" "$disk"

        printf "%-20s : %s\n" "Load Average" "$load"

        printf "%-20s : %s\n" "Time" "$(date)"

        sleep 2

    done

}

# ==========================================================
# Overall Health Score
# ==========================================================

health_score() {

    show_module "System Health Score"

    cpu=$(top -bn1 | awk -F',' '/Cpu/ {gsub("%",""); print 100-$4}')

    memory=$(free | awk '/Mem:/ {printf "%.0f",($3/$2)*100}')

    disk=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

    score=100

    (( cpu > 80 )) && score=$((score-20))
    (( memory > 80 )) && score=$((score-20))
    (( disk > 80 )) && score=$((score-20))

    echo

    highlight "Overall System Health"

    separator

    printf "%-20s : %s/100\n" "Health Score" "$score"

    if [[ "$score" -ge 90 ]]
    then

        success "Excellent System Health"

    elif [[ "$score" -ge 70 ]]
    then

        warning "Good System Health"

    else

        error "System Needs Attention"

    fi

    echo

    health_success \
    "HEALTH_SCORE" \
    "$score"

    pause_screen

}
# ==========================================================
# Health Monitoring Menu
# ==========================================================

health_menu() {

    while true
    do

        show_module "Health Monitoring"

        show_menu_option 1  "Health Dashboard"
        show_menu_option 2  "CPU Usage"
        show_menu_option 3  "Memory Usage"
        show_menu_option 4  "Swap Usage"
        show_menu_option 5  "Load Average"
        show_menu_option 6  "System Uptime"
        show_menu_option 7  "Top CPU Consumers"
        show_menu_option 8  "Top Memory Consumers"
        show_menu_option 9  "Disk Health"
        show_menu_option 10 "Network Health"
        show_menu_option 11 "CPU Temperature"
        show_menu_option 12 "Live Monitor"
        show_menu_option 13 "Overall Health Score"

        separator

        show_menu_option 0 "Back"

        separator

        read -rp "Select Option : " option

        case "$option" in

            1)

                health_dashboard
                ;;

            2)

                cpu_usage_report
                ;;

            3)

                memory_usage_report
                ;;

            4)

                swap_usage_report
                ;;

            5)

                load_average_report
                ;;

            6)

                uptime_report
                ;;

            7)

                top_cpu_processes
                ;;

            8)

                top_memory_processes
                ;;

            9)

                disk_health_report
                ;;

            10)

                network_health_report
                ;;

            11)

                temperature_report
                ;;

            12)

                live_monitor
                ;;

            13)

                health_score
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
# Module Entry
# ==========================================================

health_manager() {

    health_menu

}

# ==========================================================
# Execute Directly
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then

    health_manager

fi

