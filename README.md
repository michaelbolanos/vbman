# vbmain - VirtualBox VM Manager

## Overview
**vbmain** is a lightweight command-line tool for managing VirtualBox virtual machines (VMs) on Linux and macOS. It provides an interactive menu to list, start, and stop VMs with both graceful and force shutdown options. This script simplifies VM management without the need for the VirtualBox GUI.

## Features
- List all available VMs with their status (Running/Stopped)
- Start VMs in **Headed (GUI)** or **Headless (background)** mode
- Gracefully shut down VMs using **ACPI Power Button**
- Force shutdown VMs when necessary
- Bulk shutdown options for all running VMs
- Interactive menu for easy management

## Prerequisites
Ensure that VirtualBox and `VBoxManage` are installed on your system:
```bash
# Install VirtualBox (Linux)
sudo apt install virtualbox  # Debian-based
sudo dnf install virtualbox  # Fedora-based

# Install VirtualBox (macOS, via Homebrew)
brew install --cask virtualbox
```

## Installation
Clone the repository and make the script executable:
```bash
git clone https://github.com/yourusername/vbmain.git
cd vbmain
chmod +x vbmain.sh
```

## Usage
Run the script to open the interactive menu:
```bash
./vbmain.sh
```

Alternatively, run specific commands directly:
```bash
# List all VMs
./vbmain.sh list

# Start a specific VM (by name or UUID)
./vbmain.sh start <vm_name_or_uuid>

# Gracefully shut down a VM
./vbmain.sh shutdown <vm_name_or_uuid>

# Force shut down a VM
./vbmain.sh force-shutdown <vm_name_or_uuid>
```

## Example Output
```
======================================
 VirtualBox VM Management Script
======================================
1) List all VMs (Show Status)
2) Start a VM
3) Shut down a VM
4) Force shut down a VM
5) Shut down ALL running VMs
6) Force shut down ALL running VMs
7) Exit
======================================
Enter your choice:
```

## Contributions
Feel free to contribute by submitting a pull request or opening an issue!

## License
This project is licensed under the MIT License.

## Author
Created by [Your Name] - [Your GitHub Profile]

