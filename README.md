# System Commander
This Bash script provides a menu-driven interface for system administration tasks on Linux systems, including system updates, SSH configuration, user management, firewall management, and automation. It is designed for users with basic Linux knowledge and requires administrative privileges.

---

## Prerequisites

- **Operating System**: A supported Linux distribution (e.g., Debian/Ubuntu, Fedora, Arch Linux).
- **Permissions**: `sudo` privileges are required for most operations.
- **Dependencies**: Tools like `iptables`, `ssh`, `cron`, and package managers (`apt`, `dnf`, `pacman`) must be installed.
- **File Permissions**: The script must be executable.

To make the script executable:
```bash
chmod +x sysadmin.sh
```

---

## How to Run the Script

1. **Save the Script**: Copy the code into a file (e.g., `sysadmin.sh`).
2. **Make it Executable**: Run the command above.
3. **Execute the Script**: Use one of these commands:
   ```bash
   ./sysadmin.sh
   ```
   or
   ```bash
   sudo ./sysadmin.sh
   ```
   - Running with `sudo` is recommended to avoid repeated prompts.
4. **Navigate**: Interact with the menu using numeric inputs (0-6).

The script displays a colorful banner and a main menu. After each operation, press `Enter` to return to the main menu.

---

## Script Overview

This script simplifies common system administration tasks through a user-friendly interface. Key features:
- **Color Coding**: Green (success), red (errors), yellow (warnings/prompts).
- **Logging**: Events and errors are logged to `/var/log/script_logs/`.
- **Modularity**: Functions are organized for specific tasks, enhancing readability and maintenance.

---

## Main Menu Options

### 1. About This Device

**Purpose**: Displays detailed system information.

**Steps**:
1. Select `1`.
2. View output for:
   - Linux distribution (e.g., Ubuntu version).
   - CPU details (model, cores).
   - GPU info (if available).
   - Network interfaces and IPs.
   - Memory usage.
   - Disk usage.

**Output Example**:
```
===== System Information =====
Linux Distribution:
NAME="Ubuntu"
VERSION="22.04 LTS"
CPU Information:
Model name: AMD Ryzen 5
Memory Information:
              total        used        free
Mem:           31Gi       4.5Gi        26Gi
```

**Use Case**: Assess system health or hardware before changes.

---

### 2. System Update

**Purpose**: Updates system packages.

**Supported Systems**: Debian/Ubuntu (`apt`), Fedora (`dnf`), Arch Linux (`pacman`).

**Steps**:
1. Select `2`.
2. The script detects the package manager and runs the update.

**Output Example**:
```
===== System Update =====
Fedora detected. Using dnf package manager.
Updating system packages. This may take a while...
[SUCCESS] System updated successfully using dnf
```

**Use Case**: Ensure the system is current with security patches.

---

### 3. SSH Configuration

**Purpose**: Configures the SSH server.

**Steps**:
1. Select `3`.
2. Respond to prompts:
   - **Port**: Enter a port number (e.g., `2222`) or `0` to cancel.
   - **SSH Keys**: Choose `y` (generate keys) or `n` (use passwords).
   - **Root Login**: Choose `y` (allow) or `n` (disallow).
3. The script updates `/etc/ssh/sshd_config`, restarts SSH, and summarizes changes.

**Features**:
- Backs up the config file.
- Generates 4096-bit RSA keys if selected.

**Output Example**:
```
===== SSH Configuration =====
Which port would you prefer for SSH? Port: 2222
Would you like to use SSH keys? Choice: y
Would you like to allow root login? Choice: n
SSH private key is located at /home/user/.ssh/id_rsa.
```

**Use Case**: Secure remote access setup.

---

### 4. User Management

**Purpose**: Manages user accounts.

**Steps**:
1. Select `4`.
2. Choose a sub-option (1-3) or `0` to return.

#### Add User

**Purpose**: Creates a new user.

**Steps**:
1. Select `1`.
2. Enter a username (not `root`, not current user, or `0` to cancel).
3. Follow `adduser` prompts (e.g., password).

**Output Example**:
```
Enter the name of the user to add: testuser
Adding user 'testuser'...
[SUCCESS] User 'testuser' added successfully
```

#### Delete User

**Purpose**: Removes an existing user.

**Steps**:
1. Select `2`.
2. Enter a username (not `root`, not current user, or `0` to cancel).

**Output Example**:
```
Enter the name of the user to delete: testuser
Deleting user 'testuser'...
[SUCCESS] User 'testuser' deleted successfully
```

#### Manage User

**Purpose**: Modifies sudo privileges.

**Steps**:
1. Select `3`.
2. View user list with sudo status.
3. Enter a username.
4. Choose:
   - `1` Add sudo privileges.
   - `2` Remove sudo privileges.
   - `0` Return.

**Output Example**:
```
List of Users:
Username - Sudo status
------------------------
user1 - Sudo: Yes
Enter the name of the user to manage: user1
User 'user1' - Current sudo status: Yes
1) Add sudo privileges
2) Remove sudo privileges
Option: 2
Removing sudo privileges from user 'user1'...
[SUCCESS] Sudo privileges removed from user 'user1'
```

**Use Case**: Control user access and privileges.

---

### 5. Firewall Management

**Purpose**: Configures `iptables` firewall rules.

**Steps**:
1. Select `5`.
2. Choose a sub-option (1-7) or `0` to return.

#### View Current Rules

**Purpose**: Displays active `iptables` rules.

**Steps**: Select `1`.

**Output Example**:
```
===== Current Firewall Rules =====
Current iptables rules:
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out    source               destination
1        0     0 ACCEPT     tcp  --  *      *      0.0.0.0/0            0.0.0.0/0            tcp dpt:22
```

**Use Case**: Inspect current firewall state.

#### Flush All Rules

**Purpose**: Clears all rules and reapplies essentials.

**Steps**:
1. Select `2`.
2. Confirm with `y` or cancel with `n`.

**Output Example**:
```
Are you sure you want to flush all iptables rules? (y/n)
Confirm (y/n): y
Flushing all iptables rules...
[SUCCESS] All firewall rules flushed successfully
```

**Use Case**: Reset firewall to a clean state.

#### Set Default Policies

**Purpose**: Sets default policies for INPUT, OUTPUT, and FORWARD chains.

**Steps**:
1. Select `3`.
2. For each chain, enter `ACCEPT` or `DROP` (or `0` to cancel).

**Output Example**:
```
Enter policy for INPUT (ACCEPT/DROP): DROP
Enter policy for OUTPUT (ACCEPT/DROP): ACCEPT
Enter policy for FORWARD (ACCEPT/DROP): DROP
Setting default policies...
[SUCCESS] Default policies set successfully
```

**Use Case**: Define baseline firewall behavior.

#### Manage Ports

**Purpose**: Opens or closes TCP/UDP ports.

**Sub-options**:
1. **Open a Port**
2. **Close a Port**
3. **List Open Ports**
0. **Return**

**Steps**:
1. Select `4`.
2. Choose a sub-option:
   - **Open a Port**: Enter protocol (`tcp`/`udp`) and port (1-65535).
   - **Close a Port**: Enter protocol and port; removes ACCEPT rule and adds DROP.
   - **List Open Ports**: Shows ACCEPT rules.

**Output Example**:
```
Select an option:
1) Open a Port
Enter protocol (tcp/udp): tcp
Enter port number (1-65535): 80
Opening tcp port 80...
[SUCCESS] Successfully opened tcp port 80
```

**Use Case**: Control service accessibility.

#### Block/Unblock IP Addresses

**Purpose**: Manages IP-based rules.

**Sub-options**:
1. **Block an IP Address**
2. **Unblock an IP Address**
3. **List Blocked IP Addresses**
0. **Return**

**Steps**:
1. Select `5`.
2. Choose a sub-option:
   - **Block**: Enter an IP (e.g., `192.168.1.100`).
   - **Unblock**: Enter an IP to remove from DROP rules.
   - **List**: Shows DROP rules for IPs.

**Output Example**:
```
Select an option:
1) Block an IP Address
Enter IP address to block: 192.168.1.100
Blocking IP address 192.168.1.100...
[SUCCESS] Successfully blocked IP address 192.168.1.100
```

**Use Case**: Restrict specific IPs.

#### Save and Restore Rules

**Purpose**: Persists or reloads firewall rules.

**Sub-options**:
1. **Save Rules**: Saves to `/etc/iptables/rules.v4`.
2. **Restore Rules**: Loads from `/etc/iptables/rules.v4`.
0. **Return**

**Steps**:
1. Select `6`.
2. Choose a sub-option.

**Output Example**:
```
Select an option:
1) Save Rules
Saving firewall rules to /etc/iptables/rules.v4...
[SUCCESS] Firewall rules saved successfully
```

**Use Case**: Ensure rules persist across reboots.

#### Common Presets

**Purpose**: Applies predefined firewall configurations.

**Sub-options**:
1. **Basic SSH Server**: Allows SSH only.
2. **Web Server**: Allows SSH, HTTP (80), HTTPS (443).
3. **Reset to Open**: Sets all policies to ACCEPT.
0. **Return**

**Steps**:
1. Select `7`.
2. Choose a preset and confirm with `y`.

**Output Example**:
```
Select a preset:
2) Web Server
Applying Web Server preset...
Are you sure you want to continue? (y/n): y
[SUCCESS] Web Server preset applied successfully
```

**Use Case**: Quickly secure common setups.

**Overall Use Case**: Fine-tune network security.

---

### 6. Automation

**Purpose**: Schedules tasks via cron.

**Steps**:
1. Select `6`.
2. Choose a sub-option (1-3) or `0` to return.

#### System Update (Automation)

**Purpose**: Schedules daily updates at 3 AM.

**Steps**: Select `1`.

**Output Example**:
```
===== Automated System Update =====
Debian/Ubuntu detected. Using apt package manager.
Setting up a cron job to run system updates at 3 AM daily...
[SUCCESS] Automated system update cron job created
```

#### Cleaning Temporary Files

**Purpose**: Deletes `/tmp` files older than 1 day at 4 AM.

**Steps**: Select `2`.

**Output Example**:
```
===== Automated Temporary File Cleaning =====
Setting up a cron job to clean temporary files at 4 AM daily...
[SUCCESS] Automated temporary file cleaning cron job created
```

#### Backup

**Purpose**: Schedules a daily backup at 5 AM.

**Steps**:
1. Select `3`.
2. Enter source and destination paths (or `0` to cancel).

**Output Example**:
```
Enter the source path to back up: /home/user/docs
Enter the destination path: /backup
Setting up a cron job to backup files at 5 AM daily...
[SUCCESS] Automated backup cron job created
```

**Use Case**: Automate maintenance tasks.

---

### 0. Exit

**Purpose**: Exits the script.

**Steps**: Select `0`.

**Output**:
```
Exiting script
[SUCCESS] User exited the script
```

---

## Logging

- **Location**: `/var/log/script_logs/`.
- **Files**:
  - `events.log`: Successes (e.g., `[SUCCESS] 2025-03-31 10:00:00 - System updated`).
  - `error.log`: Failures (e.g., `[ERROR] 2025-03-31 10:01:00 - Failed to restart SSH`).
- **View**: `cat /var/log/script_logs/events.log`.

---

## Troubleshooting

- **Permission Errors**: Run with `sudo`.
- **Missing Tools**: Install dependencies (e.g., `sudo apt install iptables`).
- **Firewall Issues**: Check rules with `sudo iptables -L`.
- **SSH Not Working**: Verify `systemctl status ssh`.

---

## Safety Notes

- **Test Environment**: Use on a test system first.
- **Backups**: Manually back up critical data beyond SSH config.
- **Firewall Changes**: May disrupt active connections.
