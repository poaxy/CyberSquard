# CyberSquad Script

## Overview
The **CyberSquad Script** is a comprehensive Bash script designed to simplify system management tasks on Linux-based systems. It provides a user-friendly menu-driven interface to perform various system administration tasks, including system updates, SSH configuration, user management, firewall management, and automation of routine tasks.

## Features

1. **System Information**:
   - Display detailed system information, including Linux distribution, CPU, GPU, network, memory, and disk usage.

2. **System Update**:
   - Automatically detect the package manager (apt, dnf, or pacman) and update the system packages.

3. **SSH Configuration**:
   - Configure SSH settings, including changing the SSH port, enabling/disabling password authentication, and generating SSH keys.

4. **User Management**:
   - Add, delete, and manage users, including granting or revoking sudo privileges.

5. **Firewall Management**:
   - View, flush, and set default firewall rules.
   - Manage open/closed ports and block/unblock IP addresses.
   - Save and restore firewall rules.
   - Apply common firewall presets (e.g., Basic SSH Server, Web Server).

6. **Automation**:
   - Set up automated system updates, temporary file cleaning, and backups using cron jobs.

7. **Logging**:
   - Log all script actions and errors to `/var/log/script_logs/` for easy troubleshooting.

## Installation

1. **Download the Script**:
   - Download the `CyberSquad-script.sh` file to your system.

2. **Make the Script Executable**:
   - Run the following command to make the script executable:
     ```bash
     chmod +x CyberSquad-script.sh
     ```

3. **Run the Script**:
   - Execute the script with root privileges:
     ```bash
     sudo ./CyberSquad-script.sh
     ```

## Usage

1. **Main Menu**:
   - Upon running the script, you will be presented with a main menu offering various options.
   - Use the corresponding number to select the desired task.

2. **System Information**:
   - Select option `1` to view detailed system information.

3. **System Update**:
   - Select option `2` to update the system packages.

4. **SSH Configuration**:
   - Select option `3` to configure SSH settings.

5. **User Management**:
   - Select option `4` to manage users (add, delete, or modify sudo privileges).

6. **Firewall Management**:
   - Select option `5` to manage firewall rules, ports, and IP addresses.

7. **Automation**:
   - Select option `6` to set up automated tasks like system updates, file cleaning, and backups.

8. **Exit**:
   - Select option `0` to exit the script.

## Logging

- All script actions and errors are logged in `/var/log/script_logs/`.
  - `events.log`: Logs successful operations.
  - `error.log`: Logs errors encountered during script execution.

## Notes

- **Firewall Rules**: Ensure you understand the implications of changing firewall rules before applying them.
- **SSH Configuration**: Be cautious when disabling password authentication or changing the SSH port, as it may lock you out of the system if not configured correctly.
- **Automation**: Cron jobs are set to run at specific times (e.g., 3 AM for system updates). Adjust these times as needed.

## License

This script is provided under the MIT License. Feel free to modify and distribute it as needed.

## Disclaimer

This script is provided as-is, without any warranties. Use it at your own risk. The author is not responsible for any damage or data loss caused by the use of this script.

---

Enjoy managing your system with the **CyberSquad Script**!
