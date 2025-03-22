# CyberSquard
Overview

The CyberSquad Script is a comprehensive Bash script designed to simplify system management tasks on Linux-based systems. It provides a user-friendly menu-driven interface to perform various system administration tasks, including system updates, SSH configuration, user management, firewall management, and automation of routine tasks.
Features

    System Information:

        Display detailed system information, including Linux distribution, CPU, GPU, network, memory, and disk usage.

    System Update:

        Automatically detect the package manager (apt, dnf, or pacman) and update the system packages.

    SSH Configuration:

        Configure SSH settings, including changing the SSH port, enabling/disabling password authentication, and generating SSH keys.

    User Management:

        Add, delete, and manage users, including granting or revoking sudo privileges.

    Firewall Management:

        View, flush, and set default firewall rules.

        Manage open/closed ports and block/unblock IP addresses.

        Save and restore firewall rules.

        Apply common firewall presets (e.g., Basic SSH Server, Web Server).

    Automation:

        Set up automated system updates, temporary file cleaning, and backups using cron jobs.

    Logging:

        Log all script actions and errors to /var/log/script_logs/ for easy troubleshooting.

Installation

    Download the Script:

        Download the CyberSquad-script.sh file to your system.

    Make the Script Executable:

        Run the following command to make the script executable:
        bash
        Copy

        chmod +x CyberSquad-script.sh

    Run the Script:

        Execute the script with root privileges:
        bash
        Copy

        sudo ./CyberSquad-script.sh

Usage

    Main Menu:

        Upon running the script, you will be presented with a main menu offering various options.

        Use the corresponding number to select the desired task.

    System Information:

        Select option 1 to view detailed system information.

    System Update:

        Select option 2 to update the system packages.

    SSH Configuration:

        Select option 3 to configure SSH settings.

    User Management:

        Select option 4 to manage users (add, delete, or modify sudo privileges).

    Firewall Management:

        Select option 5 to manage firewall rules, ports, and IP addresses.

    Automation:

        Select option 6 to set up automated tasks like system updates, file cleaning, and backups.

    Exit:

        Select option 0 to exit the script.

Logging

    All script actions and errors are logged in /var/log/script_logs/.

        events.log: Logs successful operations.

        error.log: Logs errors encountered during script execution.

Notes

    Firewall Rules: Ensure you understand the implications of changing firewall rules before applying them.

    SSH Configuration: Be cautious when disabling password authentication or changing the SSH port, as it may lock you out of the system if not configured correctly.

    Automation: Cron jobs are set to run at specific times (e.g., 3 AM for system updates). Adjust these times as needed.

License

This script is provided under the MIT License. Feel free to modify and distribute it as needed.
Disclaimer

This script is provided as-is, without any warranties. Use it at your own risk. The author is not responsible for any damage or data loss caused by the use of this script.
