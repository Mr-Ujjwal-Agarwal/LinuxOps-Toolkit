#!/bin/bash

# ==========================================================
# LinuxOps Toolkit
# Module : User Management
# Version : 1.0.0
# ==========================================================

source utils/colors.sh
source utils/ui.sh
source utils/validator.sh
source utils/logger.sh
source utils/loader.sh

MODULE_NAME="USER_MANAGER"

# ==========================================================
# Helper Functions
# ==========================================================

user_success() {

    log_success \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

user_failure() {

    log_error \
    "$MODULE_NAME" \
    "$1" \
    "$2"

}

confirm_user_action() {

    local message="$1"

    echo
    warning "$message"

    read -rp "Continue? (y/n): " answer

    validate_yes_no "$answer"

    [[ $? -eq 0 ]]

}

# ==========================================================
# User Dashboard
# ==========================================================

user_dashboard() {

    show_module "User Dashboard"

    total_users=$(awk -F: '$3>=1000 && $3<65534 {count++} END{print count+0}' /etc/passwd)

    sudo_users=$(getent group sudo | awk -F: '{print $4}' | tr ',' '\n' | grep -c .)

    logged_users=$(who | wc -l)

    echo

    highlight "User Summary"

    separator

    printf "%-20s : %s\n" "Regular Users" "$total_users"
    printf "%-20s : %s\n" "Logged In Users" "$logged_users"
    printf "%-20s : %s\n" "Sudo Users" "$sudo_users"

    echo

    pause_screen

}

# ==========================================================
# List Users
# ==========================================================

list_users() {

    show_module "System Users"

    echo

    printf "%-25s %-8s %-25s\n" "USERNAME" "UID" "HOME"

    separator

    awk -F: '

    $3>=1000 && $3<65534 {

        printf "%-25s %-8s %-25s\n",$1,$3,$6

    }

    ' /etc/passwd

    echo

    user_success \
    "LIST_USERS" \
    "Displayed system users"

    pause_screen

}

# ==========================================================
# Create User
# ==========================================================

create_user() {

    show_module "Create User"

    read -rp "Username : " username

    validate_not_empty "$username" || return

    loading "Creating User..."

    if id "$username" >/dev/null 2>&1
    then

        error "User already exists."

        user_failure \
        "CREATE_USER" \
        "$username"

        pause_screen

        return

    fi

    if sudo useradd -m "$username"
    then

        success "User created successfully."

        user_success \
        "CREATE_USER" \
        "$username"

    else

        error "Failed to create user."

        user_failure \
        "CREATE_USER" \
        "$username"

    fi

    pause_screen

}

# ==========================================================
# Delete User
# ==========================================================

delete_user() {

    show_module "Delete User"

    read -rp "Username : " username

    validate_not_empty "$username" || return

    id "$username" >/dev/null 2>&1 || {

        error "User not found."

        pause_screen

        return

    }

    confirm_user_action \
    "Delete user '$username' permanently?" || return

    loading "Deleting User..."

    if sudo userdel -r "$username"
    then

        success "User deleted."

        user_success \
        "DELETE_USER" \
        "$username"

    else

        error "Unable to delete user."

        user_failure \
        "DELETE_USER" \
        "$username"

    fi

    pause_screen

}

# ==========================================================
# Lock User
# ==========================================================

lock_user() {

    show_module "Lock User"

    read -rp "Username : " username

    validate_not_empty "$username" || return

    loading "Locking Account..."

    if sudo passwd -l "$username"
    then

        success "User locked."

        user_success \
        "LOCK_USER" \
        "$username"

    else

        error "Failed to lock user."

        user_failure \
        "LOCK_USER" \
        "$username"

    fi

    pause_screen

}
# ==========================================================
# Unlock User
# ==========================================================

unlock_user() {

    show_module "Unlock User"

    read -rp "Username : " username

    validate_not_empty "$username" || return

    loading "Unlocking User..."

    if sudo passwd -u "$username"
    then

        success "User unlocked successfully."

        user_success \
        "UNLOCK_USER" \
        "$username"

    else

        error "Failed to unlock user."

        user_failure \
        "UNLOCK_USER" \
        "$username"

    fi

    pause_screen

}

# ==========================================================
# Change Password
# ==========================================================

change_password() {

    show_module "Change Password"

    read -rp "Username : " username

    validate_not_empty "$username" || return

    id "$username" >/dev/null 2>&1 || {

        error "User not found."

        pause_screen

        return

    }

    info "Enter new password."

    echo

    if sudo passwd "$username"
    then

        success "Password updated successfully."

        user_success \
        "CHANGE_PASSWORD" \
        "$username"

    else

        error "Password update failed."

        user_failure \
        "CHANGE_PASSWORD" \
        "$username"

    fi

    pause_screen

}

# ==========================================================
# User Information
# ==========================================================

user_information() {

    show_module "User Information"

    read -rp "Username : " username

    validate_not_empty "$username" || return

    id "$username" >/dev/null 2>&1 || {

        error "User not found."

        pause_screen

        return

    }

    echo

    id "$username"

    echo

    getent passwd "$username"

    echo

    chage -l "$username"

    echo

    user_success \
    "USER_INFORMATION" \
    "$username"

    pause_screen

}

# ==========================================================
# List Groups
# ==========================================================

list_groups() {

    show_module "System Groups"

    echo

    cut -d: -f1 /etc/group | sort

    echo

    user_success \
    "LIST_GROUPS" \
    "Displayed groups"

    pause_screen

}

# ==========================================================
# Add User To Group
# ==========================================================

add_user_group() {

    show_module "Add User To Group"

    read -rp "Username : " username

    validate_not_empty "$username" || return

    read -rp "Group : " group

    validate_not_empty "$group" || return

    loading "Updating Group..."

    if sudo usermod -aG "$group" "$username"
    then

        success "User added to group."

        user_success \
        "ADD_GROUP" \
        "$username -> $group"

    else

        error "Operation failed."

        user_failure \
        "ADD_GROUP" \
        "$username"

    fi

    pause_screen

}

# ==========================================================
# Remove User From Group
# ==========================================================

remove_user_group() {

    show_module "Remove User From Group"

    read -rp "Username : " username

    validate_not_empty "$username" || return

    read -rp "Group : " group

    validate_not_empty "$group" || return

    loading "Updating Group..."

    if sudo gpasswd -d "$username" "$group"
    then

        success "User removed from group."

        user_success \
        "REMOVE_GROUP" \
        "$username -> $group"

    else

        error "Operation failed."

        user_failure \
        "REMOVE_GROUP" \
        "$username"

    fi

    pause_screen

}

# ==========================================================
# Login History
# ==========================================================

login_history() {

    show_module "Login History"

    read -rp "Username : " username

    validate_not_empty "$username" || return

    echo

    last "$username"

    echo

    user_success \
    "LOGIN_HISTORY" \
    "$username"

    pause_screen

}

# ==========================================================
# Password Expiry
# ==========================================================

password_expiry() {

    show_module "Password Expiry"

    read -rp "Username : " username

    validate_not_empty "$username" || return

    echo

    chage -l "$username"

    echo

    user_success \
    "PASSWORD_EXPIRY" \
    "$username"

    pause_screen

}
# ==========================================================
# Account Expiry Information
# ==========================================================

account_expiry() {

    show_module "Account Expiry"

    read -rp "Username : " username

    validate_not_empty "$username" || return

    id "$username" >/dev/null 2>&1 || {

        error "User not found."

        pause_screen

        return

    }

    echo

    sudo chage -l "$username"

    echo

    user_success \
    "ACCOUNT_EXPIRY" \
    "$username"

    pause_screen

}

# ==========================================================
# Grant Sudo Access
# ==========================================================

grant_sudo() {

    show_module "Grant Sudo Access"

    read -rp "Username : " username

    validate_not_empty "$username" || return

    loading "Updating Privileges..."

    if sudo usermod -aG sudo "$username"
    then

        success "Sudo access granted."

        user_success \
        "GRANT_SUDO" \
        "$username"

    else

        error "Unable to grant sudo access."

        user_failure \
        "GRANT_SUDO" \
        "$username"

    fi

    pause_screen

}

# ==========================================================
# Revoke Sudo Access
# ==========================================================

revoke_sudo() {

    show_module "Revoke Sudo Access"

    read -rp "Username : " username

    validate_not_empty "$username" || return

    loading "Updating Privileges..."

    if sudo gpasswd -d "$username" sudo
    then

        success "Sudo access revoked."

        user_success \
        "REVOKE_SUDO" \
        "$username"

    else

        error "Unable to revoke sudo access."

        user_failure \
        "REVOKE_SUDO" \
        "$username"

    fi

    pause_screen

}

# ==========================================================
# User Statistics
# ==========================================================

user_statistics() {

    show_module "User Statistics"

    total_users=$(awk -F: '$3>=1000 && $3<65534 {count++} END{print count+0}' /etc/passwd)

    locked_users=$(passwd -S $(awk -F: '$3>=1000 && $3<65534 {print $1}' /etc/passwd) 2>/dev/null | awk '$2=="L"{count++} END{print count+0}')

    logged_users=$(who | wc -l)

    echo

    highlight "User Statistics"

    separator

    printf "%-25s : %s\n" "Total Users" "$total_users"
    printf "%-25s : %s\n" "Locked Users" "$locked_users"
    printf "%-25s : %s\n" "Logged In Users" "$logged_users"

    echo

    pause_screen

}

# ==========================================================
# User Management Menu
# ==========================================================

users_menu() {

    while true
    do

        show_module "User Management"

        show_menu_option 1  "User Dashboard"
        show_menu_option 2  "List Users"
        show_menu_option 3  "Create User"
        show_menu_option 4  "Delete User"
        show_menu_option 5  "Lock User"
        show_menu_option 6  "Unlock User"
        show_menu_option 7  "Change Password"
        show_menu_option 8  "User Information"
        show_menu_option 9  "List Groups"
        show_menu_option 10 "Add User To Group"
        show_menu_option 11 "Remove User From Group"
        show_menu_option 12 "Login History"
        show_menu_option 13 "Password Expiry"
        show_menu_option 14 "Account Expiry"
        show_menu_option 15 "Grant Sudo Access"
        show_menu_option 16 "Revoke Sudo Access"
        show_menu_option 17 "User Statistics"

        separator

        show_menu_option 0 "Back"

        separator

        read -rp "Select Option : " option

        case "$option" in

            1)  user_dashboard ;;
            2)  list_users ;;
            3)  create_user ;;
            4)  delete_user ;;
            5)  lock_user ;;
            6)  unlock_user ;;
            7)  change_password ;;
            8)  user_information ;;
            9)  list_groups ;;
            10) add_user_group ;;
            11) remove_user_group ;;
            12) login_history ;;
            13) password_expiry ;;
            14) account_expiry ;;
            15) grant_sudo ;;
            16) revoke_sudo ;;
            17) user_statistics ;;
            0)  break ;;

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

users_manager() {

    users_menu

}

# ==========================================================
# Execute Directly
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then

    users_manager

fi


