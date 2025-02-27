#!/bin/bash
################################################################################
# vbman.sh - Single Script to Install & Run VirtualBox Manager
#
# Usage:
#   1) Remote (GitHub) Installation:
#       curl -sSL https://raw.githubusercontent.com/<username>/<repo>/main/vbman.sh | bash
#       - Automatically installs vbman.sh to ~/scripts (or ~ if ~/scripts creation fails)
#       - Immediately runs vbman.sh
#   2) Local Execution (already downloaded):
#       chmod +x vbman.sh
#       ./vbman.sh
#
################################################################################

set -e  # Exit on errors

################################################################################
# Installation Logic
################################################################################
# If script is piped from curl, $0 is often 'bash' or '-bash'
if [[ "$0" == "bash" || "$0" == "-bash" || "$0" == "sh" ]]; then
    echo "[INFO] Running in piped mode (GitHub execution). Installing..."

    # Attempt to install to ~/scripts or fallback to ~
    TARGET_DIR="$HOME/scripts"
    if [ ! -d "$TARGET_DIR" ]; then
        echo "[INFO] ~/scripts not found; attempting to create it..."
        if ! mkdir -p "$TARGET_DIR"; then
            echo "[WARN] Could not create ~/scripts. Using ~ instead."
            TARGET_DIR="$HOME"
        fi
    fi
    INSTALL_PATH="$TARGET_DIR/vbman.sh"

    echo "[INFO] Saving vbman.sh to: $INSTALL_PATH"

    # Write the full script (including the VirtualBox menu code) into INSTALL_PATH
    cat << 'EOF' > "$INSTALL_PATH"
#!/bin/bash

################################################################################
# vbman.sh - VirtualBox CLI Management Script
################################################################################

# Colors for fancy output
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
CYAN="$(tput setaf 6)"
RESET="$(tput sgr0)"

################################################################################
# Functions
################################################################################

# List all VMs with their status (Running or Stopped)
list_vms() {
    echo -e "${CYAN}Available Virtual Machines:${RESET}"
    running_vms=$(VBoxManage list runningvms | awk -F\" '{print $2}')

    i=1  # Counter for numbering
    VBoxManage list vms | while read -r line; do
        vm_name=$(echo "$line" | awk -F\" '{print $2}')
        vm_uuid=$(echo "$line" | awk -F\" '{print $3}' | tr -d '{} ')
        
        if echo "$running_vms" | grep -Fxq "$vm_name"; then
            status="${GREEN}Running${RESET}"
        else
            status="${RED}Stopped${RESET}"
        fi
        
        printf "%d) %-40s UUID: %-38s [%s]\n" "$i" "$vm_name" "$vm_uuid" "$status"
        ((i++))  # Increment counter
    done
    echo ""
}

# Get VM UUIDs
get_vm_uuids() {
    VBoxManage list vms | awk -F\" '{print $3}' | tr -d '{} '
}

# Get running VM UUIDs
get_running_vm_uuids() {
    VBoxManage list runningvms | awk -F\" '{print $3}' | tr -d '{} '
}

# Start a VM with choice of head or headless
start_vm() {
    local vm_uuid="$1"
    echo -e "${YELLOW}Do you want to start the VM in:${RESET}"
    echo -e "  ${GREEN}1) Headed (GUI) Mode${RESET}"
    echo -e "  ${GREEN}2) Headless (Background) Mode${RESET}"

    read -r mode

    if [[ $mode == "1" ]]; then
        echo -e "${GREEN}Starting VM with GUI: $vm_uuid...${RESET}"
        VBoxManage startvm "$vm_uuid"
    elif [[ $mode == "2" ]]; then
        echo -e "${GREEN}Starting VM in Headless mode: $vm_uuid...${RESET}"
        VBoxManage startvm "$vm_uuid" --type headless
    else
        echo -e "${RED}Invalid choice. VM not started.${RESET}"
        return
    fi

    echo -e "${YELLOW}VM is now running.${RESET}"
}

# Graceful shutdown (with force fallback)
shutdown_vm() {
    local vm_uuid="$1"
    echo -e "${YELLOW}Attempting graceful shutdown: $vm_uuid...${RESET}"
    VBoxManage controlvm "$vm_uuid" acpipowerbutton
    sleep 5

    # If still running, force off
    if VBoxManage list runningvms | grep -q "$vm_uuid"; then
        echo -e "${RED}ACPI shutdown failed! Forcing power off...${RESET}"
        VBoxManage controlvm "$vm_uuid" poweroff
        echo -e "${GREEN}Forced shutdown of $vm_uuid completed.${RESET}"
    else
        echo -e "${GREEN}VM $vm_uuid shut down successfully.${RESET}"
    fi
}

# Force shut down a VM
force_shutdown_vm() {
    local vm_uuid="$1"
    echo -e "${RED}Force shutting down VM: $vm_uuid...${RESET}"
    VBoxManage controlvm "$vm_uuid" poweroff
    echo -e "${GREEN}Forced shutdown executed for $vm_uuid.${RESET}"
}

################################################################################
# Menu
################################################################################
menu() {
    while true; do
        echo -e "${CYAN}======================================${RESET}"
        echo -e "${YELLOW} VirtualBox VM Management Script ${RESET}"
        echo -e "${CYAN}======================================${RESET}"
        echo -e "${GREEN}1)${RESET} List all VMs (Show Status)"
        echo -e "${GREEN}2)${RESET} Start a VM"
        echo -e "${GREEN}3)${RESET} Shut down a VM"
        echo -e "${GREEN}4)${RESET} Force shut down a VM"
        echo -e "${GREEN}5)${RESET} Shut down ALL running VMs"
        echo -e "${GREEN}6)${RESET} Force shut down ALL running VMs"
        echo -e "${RED}7) Exit${RESET}"
        echo -e "${CYAN}======================================${RESET}"
        echo -n "Enter your choice: "
        read -r choice
        if [ -z "$choice" ]; then
            echo -e "${RED}No input detected. Please enter a valid option.${RESET}"
            sleep 1
            continue
        fi
        choice=$(echo "$choice" | tr -d '[:space:]')
        if [ -z "$choice" ]; then
            echo -e "${RED}No input detected. Please enter a valid option.${RESET}"
            continue
        fi
        case $choice in
            1)
                list_vms
                ;;
            2)
                list_vms
                echo -n "Enter the number of the VM to start: "
                read -r vm_num
                vm_uuid=$(get_vm_uuids | sed -n "${vm_num}p" | xargs)
                if [ -n "$vm_uuid" ]; then
                    start_vm "$vm_uuid"
                else
                    echo -e "${RED}Invalid selection.${RESET}"
                fi
                ;;
            3)
                list_vms
                echo -n "Enter the number of the VM to shut down: "
                read -r vm_num
                vm_uuid=$(get_vm_uuids | sed -n "${vm_num}p" | xargs)
                if [ -n "$vm_uuid" ]; then
                    shutdown_vm "$vm_uuid"
                else
                    echo -e "${RED}Invalid selection.${RESET}"
                fi
                ;;
            4)
                list_vms
                echo -n "Enter the number of the VM to FORCE shut down: "
                read -r vm_num
                vm_uuid=$(get_vm_uuids | sed -n "${vm_num}p" | xargs)
                if [ -n "$vm_uuid" ]; then
                    force_shutdown_vm "$vm_uuid"
                else
                    echo -e "${RED}Invalid selection.${RESET}"
                fi
                ;;
            5)
                echo -e "${YELLOW}Shutting down all running VMs...${RESET}"
                for vm_uuid in $(get_running_vm_uuids); do
                    shutdown_vm "$vm_uuid"
                done
                ;;
            6)
                echo -e "${RED}Force shutting down all running VMs...${RESET}"
                for vm_uuid in $(get_running_vm_uuids); do
                    force_shutdown_vm "$vm_uuid"
                done
                ;;
            7)
                echo -e "${GREEN}Exiting...${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice, please try again.${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Run menu
menu
EOF

    chmod +x "$INSTALL_PATH"
    echo "[INFO] Successfully installed vbman.sh to $INSTALL_PATH"

    # Execute it right away
    exec "$INSTALL_PATH"
fi

################################################################################
# Local Execution (not from pipe)
################################################################################

# If we get here, we're presumably running locally (file-based)
echo "[INFO] Running locally as '$0'."  
echo "[INFO] Launching the VirtualBox Manager menu..."

# The code below is the same as the final script, but we can just jump to menu if desired:
# Colors for fancy output
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
CYAN="$(tput setaf 6)"
RESET="$(tput sgr0)"

list_vms() {
    echo -e "${CYAN}Available Virtual Machines:${RESET}"
    running_vms=$(VBoxManage list runningvms | awk -F\" '{print $2}')

    i=1
    VBoxManage list vms | while read -r line; do
        vm_name=$(echo "$line" | awk -F\" '{print $2}')
        vm_uuid=$(echo "$line" | awk -F\" '{print $3}' | tr -d '{} ')
        if echo "$running_vms" | grep -Fxq "$vm_name"; then
            status="${GREEN}Running${RESET}"
        else
            status="${RED}Stopped${RESET}"
        fi
        printf "%d) %-40s UUID: %-38s [%s]\n" "$i" "$vm_name" "$vm_uuid" "$status"
        ((i++))
    done
    echo ""
}

get_vm_uuids() {
    VBoxManage list vms | awk -F\" '{print $3}' | tr -d '{} '
}

get_running_vm_uuids() {
    VBoxManage list runningvms | awk -F\" '{print $3}' | tr -d '{} '
}

start_vm() {
    local vm_uuid="$1"
    echo -e "${YELLOW}Do you want to start the VM in:${RESET}"
    echo -e "  ${GREEN}1) Headed (GUI) Mode${RESET}"
    echo -e "  ${GREEN}2) Headless (Background) Mode${RESET}"
    read -r mode
    if [[ $mode == "1" ]]; then
        echo -e "${GREEN}Starting VM with GUI: $vm_uuid...${RESET}"
        VBoxManage startvm "$vm_uuid"
    elif [[ $mode == "2" ]]; then
        echo -e "${GREEN}Starting VM in Headless mode: $vm_uuid...${RESET}"
        VBoxManage startvm "$vm_uuid" --type headless
    else
        echo -e "${RED}Invalid choice. VM not started.${RESET}"
        return
    fi
    echo -e "${YELLOW}VM is now running.${RESET}"
}

shutdown_vm() {
    local vm_uuid="$1"
    echo -e "${YELLOW}Attempting graceful shutdown: $vm_uuid...${RESET}"
    VBoxManage controlvm "$vm_uuid" acpipowerbutton
    sleep 5
    if VBoxManage list runningvms | grep -q "$vm_uuid"; then
        echo -e "${RED}ACPI shutdown failed! Forcing power off...${RESET}"
        VBoxManage controlvm "$vm_uuid" poweroff
        echo -e "${GREEN}Forced shutdown of $vm_uuid completed.${RESET}"
    else
        echo -e "${GREEN}VM $vm_uuid shut down successfully.${RESET}"
    fi
}

force_shutdown_vm() {
    local vm_uuid="$1"
    echo -e "${RED}Force shutting down VM: $vm_uuid...${RESET}"
    VBoxManage controlvm "$vm_uuid" poweroff
    echo -e "${GREEN}Forced shutdown executed for $vm_uuid.${RESET}"
}

menu() {
    while true; do
        echo -e "${CYAN}======================================${RESET}"
        echo -e "${YELLOW} VirtualBox VM Management Script ${RESET}"
        echo -e "${CYAN}======================================${RESET}"
        echo -e "${GREEN}1)${RESET} List all VMs (Show Status)"
        echo -e "${GREEN}2)${RESET} Start a VM"
        echo -e "${GREEN}3)${RESET} Shut down a VM"
        echo -e "${GREEN}4)${RESET} Force shut down a VM"
        echo -e "${GREEN}5)${RESET} Shut down ALL running VMs"
        echo -e "${GREEN}6)${RESET} Force shut down ALL running VMs"
        echo -e "${RED}7) Exit${RESET}"
        echo -e "${CYAN}======================================${RESET}"
        echo -n "Enter your choice: "
        read -r choice
        if [ -z "$choice" ]; then
            echo -e "${RED}No input detected. Please enter a valid option.${RESET}"
            sleep 1
            continue
        fi
        choice=$(echo "$choice" | tr -d '[:space:]')
        if [ -z "$choice" ]; then
            echo -e "${RED}No input detected. Please enter a valid option.${RESET}"
            continue
        fi
        case $choice in
            1)
                list_vms
                ;;
            2)
                list_vms
                echo -n "Enter the number of the VM to start: "
                read -r vm_num
                vm_uuid=$(get_vm_uuids | sed -n "${vm_num}p" | xargs)
                if [ -n "$vm_uuid" ]; then
                    start_vm "$vm_uuid"
                else
                    echo -e "${RED}Invalid selection.${RESET}"
                fi
                ;;
            3)
                list_vms
                echo -n "Enter the number of the VM to shut down: ""
                read -r vm_num
                vm_uuid=$(get_vm_uuids | sed -n "${vm_num}p" | xargs)
                if [ -n "$vm_uuid" ]; then
                    shutdown_vm "$vm_uuid"
                else
                    echo -e "${RED}Invalid selection.${RESET}"
                fi
                ;;
            4)
                list_vms
                echo -n "Enter the number of the VM to FORCE shut down: "
                read -r vm_num
                vm_uuid=$(get_vm_uuids | sed -n "${vm_num}p" | xargs)
                if [ -n "$vm_uuid" ]; then
                    force_shutdown_vm "$vm_uuid"
                else
                    echo -e "${RED}Invalid selection.${RESET}"
                fi
                ;;
            5)
                echo -e "${YELLOW}Shutting down all running VMs...${RESET}"
                for vm_uuid in $(get_running_vm_uuids); do
                    shutdown_vm "$vm_uuid"
                done
                ;;
            6)
                echo -e "${RED}Force shutting down all running VMs...${RESET}"
                for vm_uuid in $(get_running_vm_uuids); do
                    force_shutdown_vm "$vm_uuid"
                done
                ;;
            7)
                echo -e "${GREEN}Exiting...${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice, please try again.${RESET}"
                sleep 1
                ;;
        esac
    done
}

menu

