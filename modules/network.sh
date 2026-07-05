#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Module : Network Management
# Version : 1.0.0
# ==========================================================

source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/logger.sh
source utils/loader.sh

MODULE_NAME="NETWORK_MANAGER"

# ==========================================================
# Helper Functions
# ==========================================================

network_success() {

    log_success \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

network_failure() {

    log_error \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

# ==========================================================
# Network Dashboard
# ==========================================================

network_dashboard() {

    show_module "Network Dashboard"

    interfaces=$(ip -o link show | wc -l)

    ip_count=$(ip -4 addr | grep inet | wc -l)

    routes=$(ip route | wc -l)

    dns_servers=$(grep -c nameserver /etc/resolv.conf)

    echo

    highlight "Network Summary"

    separator

    printf "%-24s : %s\n" "Interfaces" "$interfaces"

    printf "%-24s : %s\n" "IPv4 Addresses" "$ip_count"

    printf "%-24s : %s\n" "Routing Entries" "$routes"

    printf "%-24s : %s\n" "DNS Servers" "$dns_servers"

    echo

    pause_screen

}

# ==========================================================
# Network Interfaces
# ==========================================================

network_interfaces() {

    show_module "Network Interfaces"

    echo

    ip -br address

    echo

    network_success \
    "INTERFACES" \
    "Viewed interfaces"

    pause_screen

}

# ==========================================================
# IP Address
# ==========================================================

ip_addresses() {

    show_module "IP Addresses"

    echo

    ip addr show

    echo

    network_success \
    "IP_ADDRESS" \
    "Viewed IP addresses"

    pause_screen

}

# ==========================================================
# Routing Table
# ==========================================================

routing_table() {

    show_module "Routing Table"

    echo

    ip route

    echo

    network_success \
    "ROUTES" \
    "Viewed routing table"

    pause_screen

}

# ==========================================================
# DNS Information
# ==========================================================

dns_information() {

    show_module "DNS Information"

    echo

    cat /etc/resolv.conf

    echo

    network_success \
    "DNS_INFORMATION" \
    "Viewed DNS configuration"

    pause_screen

}

# ==========================================================
# Ping Host
# ==========================================================

ping_host() {

    show_module "Ping Host"

    read -rp "Host/IP : " host

    validate_not_empty "$host" || return

    echo

    ping -c 4 "$host"

    echo

    if [[ $? -eq 0 ]]
    then

        network_success \
        "PING" \
        "$host"

    else

        network_failure \
        "PING" \
        "$host"

    fi

    pause_screen

}
# ==========================================================
# Traceroute
# ==========================================================

traceroute_host() {

    show_module "Traceroute"

    read -rp "Host/IP : " host

    validate_not_empty "$host" || return

    echo

    if command -v traceroute >/dev/null 2>&1
    then

        traceroute "$host"

    else

        warning "traceroute is not installed."

        info "Install using your package manager."

    fi

    echo

    network_success \
    "TRACEROUTE" \
    "$host"

    pause_screen

}

# ==========================================================
# Open Listening Ports
# ==========================================================

open_ports() {

    show_module "Open Ports"

    echo

    if command -v ss >/dev/null 2>&1
    then

        ss -tulnp

    else

        netstat -tulnp

    fi

    echo

    network_success \
    "OPEN_PORTS" \
    "Viewed listening ports"

    pause_screen

}

# ==========================================================
# Active Connections
# ==========================================================

active_connections() {

    show_module "Active Connections"

    echo

    if command -v ss >/dev/null 2>&1
    then

        ss -tunap

    else

        netstat -tunap

    fi

    echo

    network_success \
    "ACTIVE_CONNECTIONS" \
    "Viewed active connections"

    pause_screen

}

# ==========================================================
# Gateway Information
# ==========================================================

gateway_information() {

    show_module "Gateway Information"

    echo

    ip route | grep default

    echo

    network_success \
    "GATEWAY_INFORMATION" \
    "Viewed default gateway"

    pause_screen

}

# ==========================================================
# Interface Details
# ==========================================================

interface_details() {

    show_module "Interface Details"

    read -rp "Interface Name : " interface

    validate_not_empty "$interface" || return

    echo

    ip addr show "$interface"

    echo

    ip -s link show "$interface"

    echo

    network_success \
    "INTERFACE_DETAILS" \
    "$interface"

    pause_screen

}

# ==========================================================
# Network Statistics
# ==========================================================

network_statistics() {

    show_module "Network Statistics"

    echo

    highlight "Network Statistics"

    separator

    echo

    ip -s link

    echo

    network_success \
    "NETWORK_STATISTICS" \
    "Viewed interface statistics"

    pause_screen

}

# ==========================================================
# Network Health Check
# ==========================================================

network_health() {

    show_module "Network Health Check"

    echo

    highlight "Connectivity Test"

    separator

    if ping -c 2 8.8.8.8 >/dev/null 2>&1
    then

        success "Internet Connectivity : Available"

    else

        error "Internet Connectivity : Unavailable"

    fi

    echo

    highlight "DNS Resolution"

    separator

    if getent hosts google.com >/dev/null 2>&1
    then

        success "DNS Resolution : Working"

    else

        error "DNS Resolution : Failed"

    fi

    echo

    highlight "Default Gateway"

    separator

    ip route | grep default

    echo

    network_success \
    "NETWORK_HEALTH" \
    "Completed health check"

    pause_screen

}
# ==========================================================
# Network Management Menu
# ==========================================================

network_menu() {

    while true
    do

        show_module "Network Management"

        show_menu_option 1  "Network Dashboard"
        show_menu_option 2  "Network Interfaces"
        show_menu_option 3  "IP Addresses"
        show_menu_option 4  "Routing Table"
        show_menu_option 5  "DNS Information"
        show_menu_option 6  "Ping Host"
        show_menu_option 7  "Traceroute"
        show_menu_option 8  "Open Listening Ports"
        show_menu_option 9  "Active Connections"
        show_menu_option 10 "Gateway Information"
        show_menu_option 11 "Interface Details"
        show_menu_option 12 "Network Statistics"
        show_menu_option 13 "Network Health Check"

        separator

        show_menu_option 0 "Back"

        separator

        read -rp "Select Option : " option

        case "$option" in

            1)

                network_dashboard
                ;;

            2)

                network_interfaces
                ;;

            3)

                ip_addresses
                ;;

            4)

                routing_table
                ;;

            5)

                dns_information
                ;;

            6)

                ping_host
                ;;

            7)

                traceroute_host
                ;;

            8)

                open_ports
                ;;

            9)

                active_connections
                ;;

            10)

                gateway_information
                ;;

            11)

                interface_details
                ;;

            12)

                network_statistics
                ;;

            13)

                network_health
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

network_manager() {

    network_menu

}

# ==========================================================
# Execute Directly
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then

    network_manager

fi

