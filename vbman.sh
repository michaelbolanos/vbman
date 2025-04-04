#!/bin/bash

# Colors for fancy output
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

# Function to list all VMs with their status (Running or Stopped)
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

# Function to get VM UUIDs
get_vm_uuids() {
    VBoxManage list vms | awk -F\" '{print $3}' | tr -d '{} '
}

# Function to get running VM UUIDs
get_running_vm_uuids() {
    VBoxManage list runningvms | awk -F\" '{print $3}' | tr -d '{} '
}

# Function to start a VM with choice of head or headless
start_vm() {
    local vm_uuid="$1"
    echo -e "${YELLOW}Do you want to start the VM in:${RESET}"
    echo -e "  ${GREEN}1) Headed (GUI) Mode${RESET}"
    echo -e "  ${GREEN}2) Headless (Background) Mode${RESET}"
    echo -n "Enter your choice: "
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

# Function to shut down a VM gracefully with force shutdown fallback
shutdown_vm() {
    local vm_uuid="$1"
    echo -e "${YELLOW}Attempting to gracefully shut down VM: $vm_uuid...${RESET}"
    VBoxManage controlvm "$vm_uuid" acpipowerbutton
    sleep 5  # Wait a few seconds for ACPI to take effect

    # Check if VM is still running after ACPI shutdown attempt
    if VBoxManage list runningvms | grep -q "$vm_uuid"; then
        echo -e "${RED}ACPI shutdown failed! Forcing power off...${RESET}"
        VBoxManage controlvm "$vm_uuid" poweroff
        echo -e "${GREEN}VM $vm_uuid has been forcefully shut down.${RESET}"
    else
        echo -e "${GREEN}VM $vm_uuid has been shut down successfully.${RESET}"
    fi
}

# Function to forcefully shut down a VM
force_shutdown_vm() {
    local vm_uuid="$1"
    echo -e "${RED}Force shutting down VM with UUID: $vm_uuid...${RESET}"
    VBoxManage controlvm "$vm_uuid" poweroff
    echo -e "${GREEN}Forced shutdown executed.${RESET}"
}

# Fancy menu function
menu() {
    while true; do
        clear
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

        case $choice in
            1) 
                list_vms
                read -p "Press Enter to return to the menu..."
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
                read -p "Press Enter to return to the menu..."
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
                read -p "Press Enter to return to the menu..."
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
                read -p "Press Enter to return to the menu..."
                ;;
            5)
                echo -e "${YELLOW}Shutting down all running VMs...${RESET}"
                for vm_uuid in $(get_running_vm_uuids); do
                    shutdown_vm "$vm_uuid"
                done
                read -p "Press Enter to return to the menu..."
                ;;
            6)
                echo -e "${RED}Force shutting down all running VMs...${RESET}"
                for vm_uuid in $(get_running_vm_uuids); do
                    force_shutdown_vm "$vm_uuid"
                done
                read -p "Press Enter to return to the menu..."
                ;;
            7) 
                echo -e "${GREEN}Exiting...${RESET}"
                exit 0
                ;;
            *) 
                echo -e "${RED}Invalid choice, please try again.${RESET}"
                read -p "Press Enter to return to the menu..."
                ;;
        esac
    done
}

# Run the menu
menu

