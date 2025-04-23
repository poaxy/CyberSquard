#!/bin/bash

# This script is a comprehensive system management tool created by the Cybersquad team.
# It provides functionalities for system information display, updates, SSH configuration,
# user management, firewall management, and automation tasks through a user-friendly menu interface.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
OPTION_GREEN='\033[0;32m'
NC='\033[0m'

# Sets up logging directory and files for the script
setup_logging() {
    if [ ! -d "/var/log/script_logs" ]; then
        sudo mkdir -p /var/log/script_logs
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Created log directory at /var/log/script_logs${NC}"
        else
            echo -e "${RED}Failed to create log directory. Make sure you have sudo privileges.${NC}"
            exit 1
        fi
    fi
    
    sudo touch /var/log/script_logs/error.log
    sudo touch /var/log/script_logs/events.log
    
    sudo chmod 644 /var/log/script_logs/error.log
    sudo chmod 644 /var/log/script_logs/events.log
}

# Logs error messages to the error log file
log_error() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "\n${RED}[ERROR] $1${NC}"
    echo "[ERROR] $timestamp - $1" | sudo tee -a /var/log/script_logs/error.log > /dev/null
}

# Logs success messages to the events log file
log_success() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "\n${GREEN}[SUCCESS] $1${NC}"
    echo "[SUCCESS] $timestamp - $1" | sudo tee -a /var/log/script_logs/events.log > /dev/null
}

# Displays warning messages in the terminal
log_warning() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "\n${YELLOW}[WARNING] $1${NC}"
}

# Displays a colorful banner for the script
display_banner() {
    R='\033[38;5;196m'
    O='\033[38;5;202m'
    Y='\033[38;5;226m'
    G='\033[38;5;46m'
    B='\033[38;5;21m'
    I='\033[38;5;93m'
    V='\033[38;5;129m'
    BLINK='\033[5m'
    clear
    echo -e "${R}    ______      ${O}__              ${BLINK}${Y}_____                            ${G}__   ${NC}"
    echo -e "${R}   / ____/_  ${O}__/ /_  ___  ${BLINK}${Y}_____/ ___/____ ___  ______ ${G}__________/ /  ${NC}"
    echo -e "${R}  / /   / / ${O}/ / __ \\/ * \\/ ${BLINK}${Y}*__/\\__ \\/ __ \`/ / / / ${G}__ \`/ ___/ __  /  ${NC}"
    echo -e "${B}  / /___/ /_${I}/ / /_/ /  __/ ${BLINK}${V}/   ___/ / /_/ / /_/ / ${R}/_/ / /  / /_/ /   ${NC}"
    echo -e "${B}  \\____/\\__${I},_/_.___/\\___/${BLINK}${V}_/   /____/\\__, /\\__,_/${R}\\__,_/_/   \\__,_/    ${NC}"
    echo -e "${B}        /${I}____/                 ${BLINK}${V}        /_/          ${R}                 ${NC}"
}

# Adds a cron job if it doesn't already exist
add_cron_job() {
    local cron_command="$1"
    if crontab -l 2>/dev/null | grep -F "$cron_command" > /dev/null; then
        echo -e "\n${YELLOW}This cron job already exists.${NC}"
        return 0
    fi
    if (crontab -l 2>/dev/null; echo "$cron_command") | crontab -; then
        echo -e "\n${GREEN}Cron job added successfully.${NC}"
        return 0
    else
        echo -e "\n${RED}Failed to add cron job.${NC}"
        return 1
    fi
}

# Sets up automated system updates via cron job
setup_system_update() {
    echo -e "\n${GREEN}===== Automated System Update =====${NC}"
    local update_command=""
    if command -v apt &> /dev/null; then
        echo -e "\n${GREEN}Debian/Ubuntu detected. Using apt package manager.${NC}"
        update_command="0 3 * * * sudo apt update && sudo apt upgrade -y >> /var/log/script_logs/events.log 2>> /var/log/script_logs/error.log"
    elif command -v dnf &> /dev/null; then
        echo -e "\n${GREEN}Fedora detected. Using dnf package manager.${NC}"
        update_command="0 3 * * * sudo dnf update -y >> /var/log/script_logs/events.log 2>> /var/log/script_logs/error.log"
    elif command -v pacman &> /dev/null; then
        echo -e "\n${GREEN}Arch Linux detected. Using pacman package manager.${NC}"
        update_command="0 3 * * * sudo pacman -Syu --noconfirm >> /var/log/script_logs/events.log 2>> /var/log/script_logs/error.log"
    else
        log_error "This Linux distribution is not supported for automated updates"
        echo -e "\n${RED}This Linux distribution is not supported for automated updates.${NC}"
        return 1
    fi
    echo -e "\n${YELLOW}Setting up a cron job to run system updates at 3 AM daily.${NC}"
    if add_cron_job "$update_command"; then
        log_success "Automated system update cron job created successfully"
    else
        log_error "Failed to create automated system update cron job"
        return 1
    fi
    return 0
}

# Sets up automated temporary file cleaning via cron job
setup_temp_cleaning() {
    echo -e "\n${GREEN}===== Automated Temporary File Cleaning =====${NC}"
    local clean_command="0 4 * * * find /tmp -type f -mtime +1 -delete >> /var/log/script_logs/events.log 2>> /var/log/script_logs/error.log"
    echo -e "\n${YELLOW}Setting up a cron job to clean temporary files at 4 AM daily.${NC}"
    if add_cron_job "$clean_command"; then
        log_success "Automated temporary file cleaning cron job created successfully"
    else
        log_error "Failed to create automated temporary file cleaning cron job"
        return 1
    fi
    return 0
}

# Sets up automated backups via cron job
setup_backup() {
    echo -e "\n${GREEN}===== Automated Backup =====${NC}"
    local source=""
    while true; do
        echo -e "\n${YELLOW}Enter the source path to back up (or 0 to return to the automation menu):${NC}"
        read -p "Source path: " source
        if [ "$source" = "0" ]; then
            return 0
        fi
        if [ -d "$source" ] || [ -f "$source" ]; then
            break
        else
            echo -e "\n${RED}Error: Source path does not exist.${NC}"
            continue
        fi
    done
    local dest=""
    while true; do
        echo -e "\n${YELLOW}Enter the destination path (or 0 to return to the automation menu):${NC}"
        read -p "Destination path: " dest
        if [ "$dest" = "0" ]; then
            return 0
        fi
        if [ ! -d "$dest" ]; then
            echo -e "\n${YELLOW}Destination directory does not exist. Creating it...${NC}"
            if sudo mkdir -p "$dest"; then
                echo -e "\n${GREEN}Destination directory created successfully.${NC}"
            else
                echo -e "\n${RED}Failed to create destination directory.${NC}"
                continue
            fi
        fi
        break
    done
    source=$(echo "$source" | sed 's/\//\\\//g')
    dest=$(echo "$dest" | sed 's/\//\\\//g')
    local backup_command="0 5 * * * cp -rf $source $dest >> /var/log/script_logs/events.log 2>> /var/log/script_logs/error.log"
    echo -e "\n${YELLOW}Setting up a cron job to backup files at 5 AM daily.${NC}"
    if add_cron_job "$backup_command"; then
        log_success "Automated backup cron job created successfully"
    else
        log_error "Failed to create automated backup cron job"
        return 1
    fi
    return 0
}

# Main automation menu handler
automation() {
    echo -e "\n${GREEN}===== Automation =====${NC}"
    while true; do
        echo -e "\n${YELLOW}Select an option:${NC}"
        echo -e "1) System Update"
        echo -e "2) Cleaning Temporary Files"
        echo -e "3) Backup"
        echo -e "0) Return to main menu"
        read -p "Option: " option
        case $option in
            1)
                setup_system_update
                ;;
            2)
                setup_temp_cleaning
                ;;
            3)
                setup_backup
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
    done
}

# Ensures basic firewall rules for established connections
ensure_firewall_rules() {
    if ! sudo iptables -C INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null; then
        sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    fi
    if ! sudo iptables -C OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null; then
        sudo iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    fi
}

# Displays comprehensive system information
display_system_info() {
    echo -e "\n${GREEN}===== System Information =====${NC}"
    echo -e "\n${GREEN}Linux Distribution:${NC}"
    if [ -f /etc/os-release ]; then
        cat /etc/os-release | grep -E "^NAME=|^VERSION="
    elif command -v lsb_release &> /dev/null; then
        lsb_release -a
    else
        echo -e "${YELLOW}Could not determine distribution information${NC}"
    fi
    echo -e "\n${GREEN}CPU Information:${NC}"
    if command -v lscpu &> /dev/null; then
        lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread\(s\) per core|Core\(s\) per socket"
    else
        cat /proc/cpuinfo | grep "model name" | head -1
    fi
    echo -e "\n${GREEN}GPU Information:${NC}"
    if command -v lspci &> /dev/null; then
        lspci | grep -i vga
    else
        echo -e "${YELLOW}Could not determine GPU information (lspci not available)${NC}"
    fi
    echo -e "\n${GREEN}Network Information:${NC}"
    if command -v ip &> /dev/null; then
        ip addr | grep -E "^[0-9]+:|inet " | grep -v "127.0.0.1" | grep -v "::1"
    elif command -v ifconfig &> /dev/null; then
        ifconfig | grep -E "^[a-z]|inet " | grep -v "127.0.0.1" | grep -v "::1"
    else
        echo -e "${YELLOW}Could not determine network information (ip and ifconfig not available)${NC}"
    fi
    echo -e "\n${GREEN}Memory Information:${NC}"
    free -h
    echo -e "\n${GREEN}Disk Usage:${NC}"
    df -h | grep -v tmpfs | grep -v loop
    log_success "System information displayed successfully"
}

# Performs a full system update using the appropriate package manager
update_system() {
    echo -e "\n${GREEN}===== System Update =====${NC}"
    if command -v apt &> /dev/null; then
        echo -e "\n${GREEN}Debian/Ubuntu detected. Using apt package manager.${NC}"
        echo -e "\n${YELLOW}Updating system packages. This may take a while...${NC}"
        if sudo apt update && sudo apt upgrade -y; then
            log_success "System updated successfully using apt"
        else
            log_error "Failed to update system using apt"
            return 1
        fi
    elif command -v dnf &> /dev/null; then
        echo -e "\n${GREEN}Fedora detected. Using dnf package manager.${NC}"
        echo -e "\n${YELLOW}Updating system packages. This may take a while...${NC}"
        if sudo dnf update -y; then
            log_success "System updated successfully using dnf"
        else
            log_error "Failed to update system using dnf"
            return 1
        fi
    elif command -v pacman &> /dev/null; then
        echo -e "\n${GREEN}Arch Linux detected. Using pacman package manager.${NC}"
        echo -e "\n${YELLOW}Updating system packages. This may take a while...${NC}"
        if sudo pacman -Syu --noconfirm; then
            log_success "System updated successfully using pacman"
        else
            log_error "Failed to update system using pacman"
            return 1
        fi
    else
        log_error "This Linux distribution is not supported"
        return 1
    fi
    return 0
}

# Configures SSH server with user-specified settings
configure_ssh() {
    echo -e "\n${GREEN}===== SSH Configuration =====${NC}"
    if ! command -v ssh &> /dev/null; then
        log_error "SSH is not installed on this system. Please install it first."
        return 1
    fi
    SSH_CONFIG="/etc/ssh/sshd_config"
    if [ ! -f "$SSH_CONFIG" ]; then
        log_error "SSH configuration file not found at $SSH_CONFIG"
        return 1
    fi
    REAL_USER="${SUDO_USER:-$USER}"
    HOME_DIR=$(eval echo ~${REAL_USER})
    local ssh_port=0
    while true; do
        echo -e "\n${YELLOW}Which port would you prefer for SSH? (Note: It's recommended to change from 22 to another port)${NC}"
        echo -e "Enter 0 to return to the main menu."
        read -p "Port: " ssh_port
        if [ "$ssh_port" = "0" ]; then
            log_warning "User canceled SSH configuration"
            return 0
        fi
        if [[ "$ssh_port" =~ ^[0-9]+$ ]]; then
            break
        else
            echo -e "\n${RED}Error: Please enter a numeric value for the port.${NC}"
        fi
    done
    local use_ssh_keys=""
    while true; do
        echo -e "\n${YELLOW}Would you like to use SSH keys? (y/n)${NC}"
        echo -e "Enter 0 to return to the main menu."
        read -p "Choice: " use_ssh_keys
        if [ "$use_ssh_keys" = "0" ]; then
            log_warning "User canceled SSH configuration"
            return 0
        fi
        if [[ "$use_ssh_keys" == "y" || "$use_ssh_keys" == "n" ]]; then
            break
        else
            echo -e "\n${RED}Error: Please enter either 'y' or 'n'.${NC}"
        fi
    done
    local allow_root_login=""
    while true; do
        echo -e "\n${YELLOW}Would you like to allow root login? (y/n)${NC}"
        echo -e "Enter 0 to return to the main menu."
        read -p "Choice: " allow_root_login
        if [ "$allow_root_login" = "0" ]; then
            log_warning "User canceled SSH configuration"
            return 0
        fi
        if [[ "$allow_root_login" == "y" || "$allow_root_login" == "n" ]]; then
            break
        else
            echo -e "\n${RED}Error: Please enter either 'y' or 'n'.${NC}"
        fi
    done
    if [ "$allow_root_login" == "y" ]; then
        allow_root_login="yes"
    else
        allow_root_login="no"
    fi
    sudo cp "$SSH_CONFIG" "${SSH_CONFIG}.backup.$(date +%Y%m%d%H%M%S)"
    log_success "Created backup of SSH configuration file"
    if [ "$use_ssh_keys" == "y" ]; then
        echo -e "\n${YELLOW}Generating SSH key pair for user '${REAL_USER}'...${NC}"
        if [ ! -d "${HOME_DIR}/.ssh" ]; then
            mkdir -p "${HOME_DIR}/.ssh"
            chmod 700 "${HOME_DIR}/.ssh"
            chown "${REAL_USER}:${REAL_USER}" "${HOME_DIR}/.ssh"
        fi
        if [ "$REAL_USER" != "root" ]; then
            su - ${REAL_USER} -c "ssh-keygen -t rsa -b 4096 -f ${HOME_DIR}/.ssh/id_rsa -N ''"
            su - ${REAL_USER} -c "touch ${HOME_DIR}/.ssh/authorized_keys"
            su - ${REAL_USER} -c "chmod 600 ${HOME_DIR}/.ssh/authorized_keys"
            su - ${REAL_USER} -c "cat ${HOME_DIR}/.ssh/id_rsa.pub >> ${HOME_DIR}/.ssh/authorized_keys"
        else
            ssh-keygen -t rsa -b 4096 -f "${HOME_DIR}/.ssh/id_rsa" -N ""
            touch "${HOME_DIR}/.ssh/authorized_keys"
            chmod 600 "${HOME_DIR}/.ssh/authorized_keys"
            cat "${HOME_DIR}/.ssh/id_rsa.pub" >> "${HOME_DIR}/.ssh/authorized_keys"
        fi
        log_success "SSH key pair generated successfully for user '${REAL_USER}'"
        sudo sed -i "s/^#*Port .*/Port $ssh_port/" "$SSH_CONFIG"
        sudo sed -i "s/^#*PasswordAuthentication .*/PasswordAuthentication no/" "$SSH_CONFIG"
        sudo sed -i "s/^#*PubkeyAuthentication .*/PubkeyAuthentication yes/" "$SSH_CONFIG"
        sudo sed -i "s/^#*PermitRootLogin .*/PermitRootLogin $allow_root_login/" "$SSH_CONFIG"
        sudo sed -i "s/^#*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/" "$SSH_CONFIG"
        sudo sed -i "s/^#*KbdInteractiveAuthentication .*/KbdInteractiveAuthentication no/" "$SSH_CONFIG"
    else
        sudo sed -i "s/^#*Port .*/Port $ssh_port/" "$SSH_CONFIG"
        sudo sed -i "s/^#*PasswordAuthentication .*/PasswordAuthentication yes/" "$SSH_CONFIG"
        sudo sed -i "s/^#*PermitRootLogin .*/PermitRootLogin $allow_root_login/" "$SSH_CONFIG"
    fi
    sudo sed -i "s/^#*Protocol .*/Protocol 2/" "$SSH_CONFIG"
    sudo sed -i "s/^#*MaxAuthTries .*/MaxAuthTries 3/" "$SSH_CONFIG"
    sudo sed -i "s/^#*LoginGraceTime .*/LoginGraceTime 30/" "$SSH_CONFIG"
    echo -e "\n${YELLOW}Restarting SSH service...${NC}"
    if sudo systemctl restart ssh &> /dev/null || sudo service ssh restart &> /dev/null; then
        log_success "SSH service restarted successfully"
    else
        log_error "Failed to restart SSH service"
        return 1
    fi
    echo -e "\n${GREEN}===== SSH Configuration Summary =====${NC}"
    echo -e "\n  - SSH port: $ssh_port"
    echo -e "  - Root login: $allow_root_login"
    echo -e "  - Configured for user: ${REAL_USER}"
    if [ "$use_ssh_keys" == "y" ]; then
        echo -e "\n${GREEN}SSH private key is located at ${HOME_DIR}/.ssh/id_rsa. Use this to connect.${NC}"
        echo -e "${GREEN}Public key copied to ${HOME_DIR}/.ssh/authorized_keys.${NC}"
        echo -e "\n${YELLOW}Note: Password authentication has been disabled.${NC}"
        echo -e "${YELLOW}You must use SSH keys to log in.${NC}"
    fi
    echo -e "\n${YELLOW}[WARNING] After Ubuntu 24, for SSH changes to fully take effect,${NC}"
    echo -e "${YELLOW}           the device needs to be rebooted.${NC}"
    log_success "SSH configuration completed successfully for user '${REAL_USER}'"
    return 0
}

# Adds a new system user
add_user() {
    echo -e "\n${GREEN}===== Add User =====${NC}"
    local current_user=$(whoami)
    local username=""
    while true; do
        echo -e "\n${YELLOW}Enter the name of the user to add (or 0 to return to the main menu):${NC}"
        read -p "Username: " username
        if [ "$username" = "0" ]; then
            return 0
        fi
        if [ "$username" = "$current_user" ] || [ "$username" = "root" ]; then
            echo -e "\n${RED}Cannot add invalid or current user.${NC}"
            continue
        fi
        if [ -z "$username" ]; then
            echo -e "\n${RED}Username cannot be empty.${NC}"
            continue
        fi
        if id "$username" &>/dev/null; then
            echo -e "\n${RED}User '$username' already exists.${NC}"
            continue
        fi
        break
    done
    echo -e "\n${YELLOW}Adding user '$username'...${NC}"
    if sudo adduser "$username"; then
        log_success "User '$username' added successfully"
        return 0
    else
        log_error "Failed to add user '$username'"
        return 1
    fi
}

# Deletes an existing system user
delete_user() {
    echo -e "\n${GREEN}===== Delete User =====${NC}"
    local current_user=$(whoami)
    local username=""
    while true; do
        echo -e "\n${YELLOW}Enter the name of the user to delete (or 0 to return to the main menu):${NC}"
        read -p "Username: " username
        if [ "$username" = "0" ]; then
            return 0
        fi
        if [ "$username" = "$current_user" ] || [ "$username" = "root" ]; then
            echo -e "\n${RED}Cannot delete invalid, current, or root user.${NC}"
            continue
        fi
        if [ -z "$username" ]; then
            echo -e "\n${RED}Username cannot be empty.${NC}"
            continue
        fi
        if ! id "$username" &>/dev/null; then
            echo -e "\n${RED}User '$username' does not exist.${NC}"
            continue
        fi
        break
    done
    echo -e "\n${YELLOW}Deleting user '$username'...${NC}"
    if sudo deluser "$username"; then
        log_success "User '$username' deleted successfully"
        return 0
    else
        log_error "Failed to delete user '$username'"
        return 1
    fi
}

# Manages sudo privileges for users
manage_user() {
    echo -e "\n${GREEN}===== Manage User =====${NC}"
    echo -e "\n${GREEN}List of Users:${NC}"
    echo -e "${YELLOW}Username - Sudo status${NC}"
    echo -e "------------------------"
    awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | while read user; do
        if groups "$user" 2>/dev/null | grep -q sudo; then
            sudo_status="Yes"
        else
            sudo_status="No"
        fi
        echo -e "$user - Sudo: $sudo_status"
    done
    local current_user=$(whoami)
    local username=""
    while true; do
        echo -e "\n${YELLOW}Enter the name of the user to manage (or 0 to return to the main menu):${NC}"
        read -p "Username: " username
        if [ "$username" = "0" ]; then
            return 0
        fi
        if [ "$username" = "$current_user" ] || [ "$username" = "root" ]; then
            echo -e "\n${RED}Cannot manage invalid, current, or root user.${NC}"
            continue
        fi
        if [ -z "$username" ]; then
            echo -e "\n${RED}Username cannot be empty.${NC}"
            continue
        fi
        if ! id "$username" &>/dev/null; then
            echo -e "\n${RED}User '$username' does not exist.${NC}"
            continue
        fi
        break
    done
    if groups "$username" | grep -q sudo; then
        current_sudo_status="Yes"
    else
        current_sudo_status="No"
    fi
    echo -e "\n${GREEN}User '$username' - Current sudo status: $current_sudo_status${NC}"
    echo -e "\n${YELLOW}Select an option:${NC}"
    echo -e "1) Add sudo privileges"
    echo -e "2) Remove sudo privileges"
    echo -e "0) Return to user management menu"
    read -p "Option: " option
    case $option in
        1)
            if [ "$current_sudo_status" = "Yes" ]; then
                echo -e "\n${YELLOW}User '$username' already has sudo privileges.${NC}"
                log_warning "User '$username' already has sudo privileges"
                return 0
            fi
            echo -e "\n${YELLOW}Adding sudo privileges to user '$username'...${NC}"
            if sudo usermod -aG sudo "$username"; then
                log_success "Sudo privileges added to user '$username'"
                echo -e "\n${GREEN}Sudo privileges added to user '$username' successfully.${NC}"
            else
                log_error "Failed to add sudo privileges to user '$username'"
                echo -e "\n${RED}Failed to add sudo privileges to user '$username'.${NC}"
            fi
            ;;
        2)
            if [ "$current_sudo_status" = "No" ]; then
                echo -e "\n${YELLOW}User '$username' does not have sudo privileges.${NC}"
                log_warning "User '$username' does not have sudo privileges"
                return 0
            fi
            echo -e "\n${YELLOW}Removing sudo privileges from user '$username'...${NC}"
            if sudo gpasswd -d "$username" sudo 2>/dev/null || sudo deluser "$username" sudo 2>/dev/null; then
                log_success "Sudo privileges removed from user '$username'"
                echo -e "\n${GREEN}Sudo privileges removed from user '$username' successfully.${NC}"
            else
                log_error "Failed to remove sudo privileges from user '$username'"
                echo -e "\n${RED}Failed to remove sudo privileges from user '$username'.${NC}"
            fi
            ;;
        0)
            return 0
            ;;
        *)
            echo -e "\n${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
    return 0
}

# Main user management menu handler
user_management() {
    echo -e "\n${GREEN}===== User Management =====${NC}"
    while true; do
        echo -e "\n${YELLOW}Select an option:${NC}"
        echo -e "1) Add User"
        echo -e "2) Delete User"
        echo -e "3) Manage User"
        echo -e "0) Return to main menu"
        read -p "Option: " option
        case $option in
            1)
                add_user
                ;;
            2)
                delete_user
                ;;
            3)
                manage_user
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
    done
}

# Displays current firewall rules
view_firewall_rules() {
    echo -e "\n${GREEN}===== Current Firewall Rules =====${NC}"
    if command -v iptables &> /dev/null; then
        echo -e "\n${YELLOW}Current iptables rules:${NC}"
        sudo iptables -L -v -n --line-numbers
        log_success "Displayed current firewall rules"
    else
        log_error "iptables not found on this system"
        echo -e "\n${RED}Error: iptables not found on this system${NC}"
        return 1
    fi
    return 0
}

# Flushes all firewall rules and reapplies basic rules
flush_firewall_rules() {
    echo -e "\n${GREEN}===== Flush Firewall Rules =====${NC}"
    echo -e "\n${YELLOW}Are you sure you want to flush all iptables rules? (y/n)${NC}"
    echo -e "This will remove all current firewall rules."
    read -p "Confirm (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo -e "\n${YELLOW}Operation cancelled${NC}"
        return 0
    fi
    if command -v iptables &> /dev/null; then
        echo -e "\n${YELLOW}Flushing all iptables rules...${NC}"
        if sudo iptables -F && sudo iptables -X && sudo iptables -t nat -F; then
            ensure_firewall_rules
            log_success "All firewall rules flushed successfully and essential rules reapplied"
            echo -e "\n${GREEN}All firewall rules flushed successfully. Essential rules reapplied.${NC}"
        else
            log_error "Failed to flush firewall rules"
            echo -e "\n${RED}Failed to flush firewall rules${NC}"
            return 1
        fi
    else
        log_error "iptables not found on this system"
        echo -e "\n${RED}Error: iptables not found on this system${NC}"
        return 1
    fi
    return 0
}

# Sets default firewall policies for chains
set_default_policies() {
    echo -e "\n${GREEN}===== Set Default Policies =====${NC}"
    if ! command -v iptables &> /dev/null; then
        log_error "iptables not found on this system"
        echo -e "\n${RED}Error: iptables not found on this system${NC}"
        return 1
    fi
    local chains=("INPUT" "OUTPUT" "FORWARD")
    local policies=()
    for chain in "${chains[@]}"; do
        local policy=""
        while true; do
            echo -e "\n${YELLOW}Enter policy for ${chain} (ACCEPT/DROP):${NC}"
            echo -e "Enter 0 to return to the firewall menu."
            read -p "Policy: " policy
            if [ "$policy" = "0" ]; then
                return 0
            fi
            policy=$(echo "$policy" | tr '[:lower:]' '[:upper:]')
            if [[ "$policy" == "ACCEPT" || "$policy" == "DROP" ]]; then
                policies+=("$policy")
                break
            else
                echo -e "\n${RED}Error: Please enter either 'ACCEPT' or 'DROP'.${NC}"
            fi
        done
    done
    echo -e "\n${YELLOW}Setting default policies...${NC}"
    local success=true
    for i in "${!chains[@]}"; do
        echo -e "Setting ${chains[$i]} policy to ${policies[$i]}..."
        if ! sudo iptables -P "${chains[$i]}" "${policies[$i]}"; then
            log_error "Failed to set ${chains[$i]} policy to ${policies[$i]}"
            echo -e "\n${RED}Failed to set ${chains[$i]} policy to ${policies[$i]}${NC}"
            success=false
        fi
    done
    if [ "$success" = true ]; then
        log_success "Default policies set successfully"
        echo -e "\n${GREEN}Default policies set successfully${NC}"
    else
        echo -e "\n${RED}Some policies could not be set. See error log for details.${NC}"
        return 1
    fi
    return 0
}

# Manages port opening/closing in firewall
manage_ports() {
    echo -e "\n${GREEN}===== Manage Ports =====${NC}"
    if ! command -v iptables &> /dev/null; then
        log_error "iptables not found on this system"
        echo -e "\n${RED}Error: iptables not found on this system${NC}"
        return 1
    fi
    local option=0
    while true; do
        echo -e "\n${YELLOW}Select an option:${NC}"
        echo -e "1) Open a Port"
        echo -e "2) Close a Port"
        echo -e "3) List Open Ports"
        echo -e "0) Return to firewall menu"
        read -p "Option: " option
        case $option in
            1)
                local protocol=""
                local port=0
                while true; do
                    echo -e "\n${YELLOW}Enter protocol (tcp/udp):${NC}"
                    echo -e "Enter 0 to return to the port management menu."
                    read -p "Protocol: " protocol
                    if [ "$protocol" = "0" ]; then
                        break
                    fi
                    protocol=$(echo "$protocol" | tr '[:upper:]' '[:lower:]')
                    if [[ "$protocol" == "tcp" || "$protocol" == "udp" ]]; then
                        break
                    else
                        echo -e "\n${RED}Error: Please enter either 'tcp' or 'udp'.${NC}"
                    fi
                done
                if [ "$protocol" = "0" ]; then
                    continue
                fi
                while true; do
                    echo -e "\n${YELLOW}Enter port number (1-65535):${NC}"
                    echo -e "Enter 0 to return to the port management menu."
                    read -p "Port: " port
                    if [ "$port" = "0" ]; then
                        break
                    fi
                    if [[ "$port" =~ ^[0-9]+$ && "$port" -ge 1 && "$port" -le 65535 ]]; then
                        break
                    else
                        echo -e "\n${RED}Error: Please enter a valid port number (1-65535).${NC}"
                    fi
                done
                if [ "$port" = "0" ]; then
                    continue
                fi
                echo -e "\n${YELLOW}Opening ${protocol} port ${port}...${NC}"
                if sudo iptables -A INPUT -p "$protocol" --dport "$port" -j ACCEPT; then
                    log_success "Opened ${protocol} port ${port}"
                    echo -e "\n${GREEN}Successfully opened ${protocol} port ${port}${NC}"
                else
                    log_error "Failed to open ${protocol} port ${port}"
                    echo -e "\n${RED}Failed to open ${protocol} port ${port}${NC}"
                fi
                ;;
            2)
                local protocol=""
                local port=0
                while true; do
                    echo -e "\n${YELLOW}Enter protocol (tcp/udp):${NC}"
                    echo -e "Enter 0 to return to the port management menu."
                    read -p "Protocol: " protocol
                    if [ "$protocol" = "0" ]; then
                        break
                    fi
                    protocol=$(echo "$protocol" | tr '[:upper:]' '[:lower:]')
                    if [[ "$protocol" == "tcp" || "$protocol" == "udp" ]]; then
                        break
                    else
                        echo -e "\n${RED}Error: Please enter either 'tcp' or 'udp'.${NC}"
                    fi
                done
                if [ "$protocol" = "0" ]; then
                    continue
                fi
                while true; do
                    echo -e "\n${YELLOW}Enter port number (1-65535):${NC}"
                    echo -e "Enter 0 to return to the port management menu."
                    read -p "Port: " port
                    if [ "$port" = "0" ]; then
                        break
                    fi
                    if [[ "$port" =~ ^[0-9]+$ && "$port" -ge 1 && "$port" -le 65535 ]]; then
                        break
                    else
                        echo -e "\n${RED}Error: Please enter a valid port number (1-65535).${NC}"
                    fi
                done
                if [ "$port" = "0" ]; then
                    continue
                fi
                echo -e "\n${YELLOW}Closing ${protocol} port ${port}...${NC}"
                local rule_num=$(sudo iptables -L INPUT --line-numbers | grep "ACCEPT" | grep "$protocol dpt:$port" | awk '{print $1}')
                if [ -n "$rule_num" ]; then
                    if sudo iptables -D INPUT "$rule_num"; then
                        log_success "Deleted existing ACCEPT rule for ${protocol} port ${port}"
                        echo -e "\n${GREEN}Deleted existing ACCEPT rule for ${protocol} port ${port}${NC}"
                    else
                        log_error "Failed to delete existing ACCEPT rule for ${protocol} port ${port}"
                        echo -e "\n${RED}Failed to delete existing ACCEPT rule for ${protocol} port ${port}${NC}"
                    fi
                fi
                if sudo iptables -A INPUT -p "$protocol" --dport "$port" -j DROP; then
                    log_success "Closed ${protocol} port ${port}"
                    echo -e "\n${GREEN}Successfully closed ${protocol} port ${port}${NC}"
                else
                    log_error "Failed to close ${protocol} port ${port}"
                    echo -e "\n${RED}Failed to close ${protocol} port ${port}${NC}"
                fi
                ;;
            3)
                echo -e "\n${YELLOW}Listing open ports...${NC}"
                echo -e "\n${GREEN}Open ports (ACCEPT rules):${NC}"
                sudo iptables -L INPUT -v -n | grep "ACCEPT"
                log_success "Listed open ports"
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
    done
}

# Manages IP address blocking/unblocking
manage_ip_addresses() {
    echo -e "\n${GREEN}===== Manage IP Addresses =====${NC}"
    if ! command -v iptables &> /dev/null; then
        log_error "iptables not found on this system"
        echo -e "\n${RED}Error: iptables not found on this system${NC}"
        return 1
    fi
    local option=0
    while true; do
        echo -e "\n${YELLOW}Select an option:${NC}"
        echo -e "1) Block an IP Address"
        echo -e "2) Unblock an IP Address"
        echo -e "3) List Blocked IP Addresses"
        echo -e "0) Return to firewall menu"
        read -p "Option: " option
        case $option in
            1)
                local ip=""
                while true; do
                    echo -e "\n${YELLOW}Enter IP address to block (e.g., 192.168.1.100):${NC}"
                    echo -e "Enter 0 to return to the IP management menu."
                    read -p "IP Address: " ip
                    if [ "$ip" = "0" ]; then
                        break
                    fi
                    if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                        break
                    else
                        echo -e "\n${RED}Error: Please enter a valid IP address.${NC}"
                    fi
                done
                if [ "$ip" = "0" ]; then
                    continue
                fi
                echo -e "\n${YELLOW}Blocking IP address ${ip}...${NC}"
                if sudo iptables -A INPUT -s "$ip" -j DROP; then
                    log_success "Blocked IP address ${ip}"
                    echo -e "\n${GREEN}Successfully blocked IP address ${ip}${NC}"
                else
                    log_error "Failed to block IP address ${ip}"
                    echo -e "\n${RED}Failed to block IP address ${ip}${NC}"
                fi
                ;;
            2)
                local ip=""
                while true; do
                    echo -e "\n${YELLOW}Enter IP address to unblock (e.g., 192.168.1.100):${NC}"
                    echo -e "Enter 0 to return to the IP management menu."
                    read -p "IP Address: " ip
                    if [ "$ip" = "0" ]; then
                        break
                    fi
                    if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                        break
                    else
                        echo -e "\n${RED}Error: Please enter a valid IP address.${NC}"
                    fi
                done
                if [ "$ip" = "0" ]; then
                    continue
                fi
                echo -e "\n${YELLOW}Unblocking IP address ${ip}...${NC}"
                local rule_num=$(sudo iptables -L INPUT --line-numbers | grep "DROP" | grep "$ip" | awk '{print $1}')
                if [ -n "$rule_num" ]; then
                    if sudo iptables -D INPUT "$rule_num"; then
                        log_success "Unblocked IP address ${ip}"
                        echo -e "\n${GREEN}Successfully unblocked IP address ${ip}${NC}"
                    else
                        log_error "Failed to unblock IP address ${ip}"
                        echo -e "\n${RED}Failed to unblock IP address ${ip}${NC}"
                    fi
                else
                    log_warning "No block rule found for IP address ${ip}"
                    echo -e "\n${YELLOW}No block rule found for IP address ${ip}${NC}"
                fi
                ;;
            3)
                echo -e "\n${YELLOW}Listing blocked IP addresses...${NC}"
                echo -e "\n${GREEN}Blocked IP addresses (DROP rules):${NC}"
                sudo iptables -L INPUT -v -n | grep "DROP"
                log_success "Listed blocked IP addresses"
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
    done
}

# Handles saving and restoring firewall rules
manage_rule_persistence() {
    echo -e "\n${GREEN}===== Save and Restore Firewall Rules =====${NC}"
    if ! command -v iptables &> /dev/null; then
        log_error "iptables not found on this system"
        echo -e "\n${RED}Error: iptables not found on this system${NC}"
        return 1
    fi
    if [ ! -d "/etc/iptables" ]; then
        if sudo mkdir -p /etc/iptables; then
            echo -e "\n${GREEN}Created directory /etc/iptables${NC}"
        else
            log_error "Failed to create directory /etc/iptables"
            echo -e "\n${RED}Failed to create directory /etc/iptables${NC}"
            return 1
        fi
    fi
    local option=0
    while true; do
        echo -e "\n${YELLOW}Select an option:${NC}"
        echo -e "1) Save Rules"
        echo -e "2) Restore Rules"
        echo -e "0) Return to firewall menu"
        read -p "Option: " option
        case $option in
            1)
                echo -e "\n${YELLOW}Saving firewall rules to /etc/iptables/rules.v4...${NC}"
                if sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null; then
                    log_success "Firewall rules saved to /etc/iptables/rules.v4"
                    echo -e "\n${GREEN}Firewall rules saved successfully${NC}"
                else
                    log_error "Failed to save firewall rules"
                    echo -e "\n${RED}Failed to save firewall rules${NC}"
                fi
                ;;
            2)
                if [ ! -f "/etc/iptables/rules.v4" ]; then
                    log_error "Rules file not found at /etc/iptables/rules.v4"
                    echo -e "\n${RED}Rules file not found at /etc/iptables/rules.v4${NC}"
                    continue
                fi
                echo -e "\n${YELLOW}Restoring firewall rules from /etc/iptables/rules.v4...${NC}"
                if sudo iptables-restore < /etc/iptables/rules.v4; then
                    log_success "Firewall rules restored from /etc/iptables/rules.v4"
                    echo -e "\n${GREEN}Firewall rules restored successfully${NC}"
                else
                    log_error "Failed to restore firewall rules"
                    echo -e "\n${RED}Failed to restore firewall rules${NC}"
                fi
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
    done
}

# Applies predefined firewall rule sets
apply_firewall_presets() {
    echo -e "\n${GREEN}===== Common Firewall Presets =====${NC}"
    if ! command -v iptables &> /dev/null; then
        log_error "iptables not found on this system"
        echo -e "\n${RED}Error: iptables not found on this system${NC}"
        return 1
    fi
    local option=0
    while true; do
        echo -e "\n${YELLOW}Select a preset:${NC}"
        echo -e "1) Basic SSH Server"
        echo -e "2) Web Server"
        echo -e "3) Reset to Open"
        echo -e "0) Return to firewall menu"
        read -p "Option: " option
        case $option in
            1)
                echo -e "\n${YELLOW}Applying Basic SSH Server preset...${NC}"
                echo -e "This will:"
                echo -e "  - Flush all existing rules"
                echo -e "  - Set INPUT chain policy to DROP"
                echo -e "  - Set OUTPUT chain policy to ACCEPT"
                echo -e "  - Allow established connections"
                echo -e "  - Allow SSH (port 22)"
                echo -e "  - Allow loopback traffic"
                echo -e "\n${YELLOW}Are you sure you want to continue? (y/n)${NC}"
                read -p "Confirm (y/n): " confirm
                if [[ "$confirm" != "y" ]]; then
                    echo -e "\n${YELLOW}Operation cancelled${NC}"
                    continue
                fi
                if sudo iptables -F && \
                   sudo iptables -X && \
                   sudo iptables -P INPUT DROP && \
                   sudo iptables -P OUTPUT ACCEPT && \
                   sudo iptables -P FORWARD DROP && \
                   sudo iptables -A INPUT -i lo -j ACCEPT && \
                   sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT && \
                   sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT; then
                    log_success "Applied Basic SSH Server firewall preset"
                    echo -e "\n${GREEN}Basic SSH Server preset applied successfully${NC}"
                else
                    log_error "Failed to apply Basic SSH Server firewall preset"
                    echo -e "\n${RED}Failed to apply Basic SSH Server preset${NC}"
                fi
                ;;
            2)
                echo -e "\n${YELLOW}Applying Web Server preset...${NC}"
                echo -e "This will:"
                echo -e "  - Flush all existing rules"
                echo -e "  - Set INPUT chain policy to DROP"
                echo -e "  - Set OUTPUT chain policy to ACCEPT"
                echo -e "  - Allow established connections"
                echo -e "  - Allow SSH (port 22)"
                echo -e "  - Allow HTTP (port 80)"
                echo -e "  - Allow HTTPS (port 443)"
                echo -e "  - Allow loopback traffic"
                echo -e "\n${YELLOW}Are you sure you want to continue? (y/n)${NC}"
                read -p "Confirm (y/n): " confirm
                if [[ "$confirm" != "y" ]]; then
                    echo -e "\n${YELLOW}Operation cancelled${NC}"
                    continue
                fi
                if sudo iptables -F && \
                   sudo iptables -X && \
                   sudo iptables -P INPUT DROP && \
                   sudo iptables -P OUTPUT ACCEPT && \
                   sudo iptables -P FORWARD DROP && \
                   sudo iptables -A INPUT -i lo -j ACCEPT && \
                   sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT && \
                   sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT && \
                   sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT && \
                   sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT; then
                    log_success "Applied Web Server firewall preset"
                    echo -e "\n${GREEN}Web Server preset applied successfully${NC}"
                else
                    log_error "Failed to apply Web Server firewall preset"
                    echo -e "\n${RED}Failed to apply Web Server preset${NC}"
                fi
                ;;
            3)
                echo -e "\n${YELLOW}Resetting firewall to Open...${NC}"
                echo -e "This will:"
                echo -e "  - Flush all existing rules"
                echo -e "  - Set all chain policies to ACCEPT"
                echo -e "\n${YELLOW}Are you sure you want to continue? (y/n)${NC}"
                read -p "Confirm (y/n): " confirm
                if [[ "$confirm" != "y" ]]; then
                    echo -e "\n${YELLOW}Operation cancelled${NC}"
                    continue
                fi
                if sudo iptables -F && \
                   sudo iptables -X && \
                   sudo iptables -P INPUT ACCEPT && \
                   sudo iptables -P OUTPUT ACCEPT && \
                   sudo iptables -P FORWARD ACCEPT; then
                    log_success "Reset firewall to Open"
                    echo -e "\n${GREEN}Firewall reset to Open successfully${NC}"
                else
                    log_error "Failed to reset firewall to Open"
                    echo -e "\n${RED}Failed to reset firewall to Open${NC}"
                fi
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${NC}"
                ;;
        esac
    done
}

# Main firewall management menu handler
firewall_management() {
    echo -e "\n${GREEN}===== Firewall Management =====${NC}"
    ensure_firewall_rules
    while true; do
        echo -e "\n${YELLOW}Select an option:${NC}"
        echo -e "${GREEN}1${NC}) View Current Rules"
        echo -e "${GREEN}2${NC}) Flush All Rules"
        echo -e "${GREEN}3${NC}) Set Default Policies"
        echo -e "${GREEN}4${NC}) Manage Ports"
        echo -e "${GREEN}5${NC}) Block/Unblock IP Addresses"
        echo -e "${GREEN}6${NC}) Save and Restore Rules"
        echo -e "${GREEN}7${NC}) Common Presets"
        echo -e "${GREEN}0${NC}) Return to main menu"
        read -p "Option: " option
        case $option in
            1) view_firewall_rules ;;
            2) flush_firewall_rules ;;
            3) set_default_policies ;;
            4) manage_ports ;;
            5) manage_ip_addresses ;;
            6) manage_rule_persistence ;;
            7) apply_firewall_presets ;;
            0) return 0 ;;
            *) echo -e "\n${RED}Invalid option. Please try again.${NC}" ;;
        esac
    done
}

# Displays the main menu interface
display_menu() {
    display_banner
    echo
    echo
    echo -e "${GREEN}1${NC} - About this device"
    echo -e "${GREEN}2${NC} - System Update"
    echo -e "${GREEN}3${NC} - SSH Configuration"
    echo -e "${GREEN}4${NC} - User Management"
    echo -e "${GREEN}5${NC} - Firewall Management"
    echo -e "${GREEN}6${NC} - Automation"
    echo -e "${GREEN}0${NC} - Exit"
    echo -ne "\nEnter your choice: "
}

# Main script execution - sets up logging and displays menu
setup_logging
while true; do
    display_menu
    read choice
    case $choice in
        1)
            display_system_info
            ;;
        2)
            update_system
            ;;
        3)
            configure_ssh
            ;;
        4)
            user_management
            ;;
        5)
            firewall_management
            ;;
        6)
            automation
            ;;
        0)
            echo -e "\n${GREEN}Exiting script${NC}"
            log_success "User exited the script"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
done
