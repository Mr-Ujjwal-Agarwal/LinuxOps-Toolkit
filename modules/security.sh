#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Module : Security Audit
# Version : 1.0.0
# ==========================================================

source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/logger.sh
source utils/loader.sh

MODULE_NAME="SECURITY_MANAGER"

# ==========================================================
# Helper Functions
# ==========================================================

security_success() {

    log_success \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

security_failure() {

    log_error \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

# ==========================================================
# Security Dashboard
# ==========================================================

security_dashboard() {

    show_module "Security Dashboard"

    failed_services=$(systemctl --failed --no-legend 2>/dev/null | wc -l)

    open_ports=$(ss -tuln 2>/dev/null | tail -n +2 | wc -l)

    logged_users=$(who | wc -l)

    failed_logins=0

    if [[ -f /var/log/auth.log ]]
    then
        failed_logins=$(grep -ic "failed password" /var/log/auth.log 2>/dev/null)
    elif [[ -f /var/log/secure ]]
    then
        failed_logins=$(grep -ic "failed password" /var/log/secure 2>/dev/null)
    fi

    echo

    highlight "Security Overview"

    separator

    printf "%-25s : %s\n" "Logged In Users" "$logged_users"

    printf "%-25s : %s\n" "Open Ports" "$open_ports"

    printf "%-25s : %s\n" "Failed Services" "$failed_services"

    printf "%-25s : %s\n" "Failed Login Attempts" "$failed_logins"

    echo

    pause_screen

}

# ==========================================================
# Failed Login Attempts
# ==========================================================

failed_logins() {

    show_module "Failed Login Attempts"

    echo

    if [[ -f /var/log/auth.log ]]
    then

        grep -i "Failed password" \
        /var/log/auth.log | tail -30

    elif [[ -f /var/log/secure ]]
    then

        grep -i "Failed password" \
        /var/log/secure | tail -30

    else

        warning "Authentication log not found."

    fi

    echo

    security_success \
    "FAILED_LOGINS" \
    "Viewed failed logins"

    pause_screen

}

# ==========================================================
# Logged In Users
# ==========================================================

logged_users_report() {

    show_module "Logged In Users"

    echo

    who

    echo

    security_success \
    "LOGGED_USERS" \
    "Viewed logged users"

    pause_screen

}

# ==========================================================
# SSH Security Audit
# ==========================================================

ssh_audit() {

    show_module "SSH Security Audit"

    ssh_config="/etc/ssh/sshd_config"

    if [[ ! -f "$ssh_config" ]]
    then

        error "SSH configuration not found."

        pause_screen

        return

    fi

    echo

    grep -Ei \
    "PermitRootLogin|PasswordAuthentication|PubkeyAuthentication|PermitEmptyPasswords" \
    "$ssh_config"

    echo

    security_success \
    "SSH_AUDIT" \
    "Completed"

    pause_screen

}

# ==========================================================
# Firewall Status
# ==========================================================

firewall_status() {

    show_module "Firewall Status"

    echo

    if command -v ufw >/dev/null 2>&1
    then

        sudo ufw status verbose

    elif command -v firewall-cmd >/dev/null 2>&1
    then

        sudo firewall-cmd --list-all

    else

        warning "Firewall utility not detected."

    fi

    echo

    security_success \
    "FIREWALL_STATUS" \
    "Viewed firewall"

    pause_screen

}

# ==========================================================
# Open Ports Audit
# ==========================================================

open_ports_audit() {

    show_module "Open Ports Audit"

    echo

    ss -tulnp

    echo

    security_success \
    "OPEN_PORTS" \
    "Viewed open ports"

    pause_screen

}

# ==========================================================
# Running Root Processes
# ==========================================================

running_root_processes() {

    show_module "Running Root Processes"

    echo

    ps -U root -u root -f

    echo

    security_success \
    "ROOT_PROCESSES" \
    "Viewed root processes"

    pause_screen

}

# ==========================================================
# World Writable Files Audit
# ==========================================================

world_writable_files() {

    show_module "World Writable Files"

    warning "This may take some time..."

    loading "Scanning Files..."

    echo

    find / \
        -xdev \
        -type f \
        -perm -0002 \
        2>/dev/null | head -100

    echo

    security_success \
    "WORLD_WRITABLE" \
    "Audit completed"

    pause_screen

}

# ==========================================================
# SUID / SGID Audit
# ==========================================================

suid_sgid_audit() {

    show_module "SUID / SGID Audit"

    warning "Scanning filesystem..."

    loading "Scanning..."

    echo

    find / \
        -xdev \
        \( -perm -4000 -o -perm -2000 \) \
        2>/dev/null | head -100

    echo

    security_success \
    "SUID_SGID" \
    "Audit completed"

    pause_screen

}

# ==========================================================
# Password Policy
# ==========================================================

password_policy() {

    show_module "Password Policy"

    echo

    if [[ -f /etc/login.defs ]]
    then

        grep -E \
        "PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE|PASS_MIN_LEN" \
        /etc/login.defs

    else

        warning "login.defs not found."

    fi

    echo

    security_success \
    "PASSWORD_POLICY" \
    "Viewed password policy"

    pause_screen

}

# ==========================================================
# Security Health Check
# ==========================================================

security_health() {

    show_module "Security Health"

    echo

    highlight "SSH Service"

    separator

    if systemctl is-active ssh >/dev/null 2>&1 || \
       systemctl is-active sshd >/dev/null 2>&1
    then

        success "SSH Service Running"

    else

        warning "SSH Service Not Running"

    fi

    echo

    highlight "Firewall"

    separator

    if command -v ufw >/dev/null 2>&1
    then

        ufw status | head -1

    elif command -v firewall-cmd >/dev/null 2>&1
    then

        firewall-cmd --state

    else

        warning "Firewall utility unavailable"

    fi

    echo

    highlight "SELinux"

    separator

    if command -v getenforce >/dev/null 2>&1
    then

        getenforce

    else

        info "SELinux not available"

    fi

    echo

    security_success \
    "SECURITY_HEALTH" \
    "Completed"

    pause_screen

}

# ==========================================================
# Security Score
# ==========================================================

security_score() {

    show_module "Security Score"

    score=100

    systemctl --failed --no-legend | grep -q . && score=$((score-10))

    ss -tuln | grep -q LISTEN && score=$((score-5))

    if [[ -f /var/log/auth.log ]]
    then

        failed=$(grep -ic "failed password" /var/log/auth.log 2>/dev/null)

        (( failed > 20 )) && score=$((score-15))

    fi

    if command -v getenforce >/dev/null 2>&1
    then

        [[ "$(getenforce)" != "Enforcing" ]] && score=$((score-10))

    fi

    echo

    highlight "Security Assessment"

    separator

    printf "%-25s : %s/100\n" "Security Score" "$score"

    if [[ "$score" -ge 90 ]]
    then

        success "Excellent Security"

    elif [[ "$score" -ge 75 ]]
    then

        warning "Good Security"

    else

        error "Security Needs Attention"

    fi

    echo

    security_success \
    "SECURITY_SCORE" \
    "$score"

    pause_screen

}

# ==========================================================
# Generate Security Report
# ==========================================================

security_report() {

    show_module "Security Report"

    report="reports/security_report_$(date +%Y%m%d_%H%M%S).txt"

    mkdir -p reports

    {

        echo "========================================="
        echo " LinuxOps Security Report"
        echo "========================================="
        echo
        echo "Generated : $(date)"
        echo
        echo "Hostname  : $(hostname)"
        echo
        echo "Kernel    : $(uname -r)"
        echo
        echo "Uptime"
        uptime
        echo
        echo "Logged Users"
        who
        echo
        echo "Listening Ports"
        ss -tuln
        echo
        echo "Failed Services"
        systemctl --failed

    } > "$report"

    success "Security report generated."

    info "$report"

    security_success \
    "SECURITY_REPORT" \
    "$report"

    pause_screen

}

# ==========================================================
# Security Management Menu
# ==========================================================

security_menu() {

    while true
    do

        show_module "Security Audit"

        show_menu_option 1  "Security Dashboard"
        show_menu_option 2  "Failed Login Attempts"
        show_menu_option 3  "Logged In Users"
        show_menu_option 4  "SSH Security Audit"
        show_menu_option 5  "Firewall Status"
        show_menu_option 6  "Open Ports Audit"
        show_menu_option 7  "Running Root Processes"
        show_menu_option 8  "World Writable Files"
        show_menu_option 9  "SUID / SGID Audit"
        show_menu_option 10 "Password Policy"
        show_menu_option 11 "Security Health"
        show_menu_option 12 "Security Score"
        show_menu_option 13 "Generate Security Report"

        separator

        show_menu_option 0 "Back"

        separator

        read -rp "Select Option : " option

        case "$option" in

            1)

                security_dashboard
                ;;

            2)

                failed_logins
                ;;

            3)

                logged_users_report
                ;;

            4)

                ssh_audit
                ;;

            5)

                firewall_status
                ;;

            6)

                open_ports_audit
                ;;

            7)

                running_root_processes
                ;;

            8)

                world_writable_files
                ;;

            9)

                suid_sgid_audit
                ;;

            10)

                password_policy
                ;;

            11)

                security_health
                ;;

            12)

                security_score
                ;;

            13)

                security_report
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

security_manager() {

    security_menu

}

# ==========================================================
# Execute Directly
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then

    security_manager

fi



