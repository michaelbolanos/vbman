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

# Run the menu
menu()
{
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
        echo "DEBUG: User entered choice='$choice'"
        case $choice in
            1) 
                list_vms
                ;;
            2)
                list_vms
                echo -n "Enter the number of the VM to start: "
                read -r vm_num
                vm_uuid=$(get_vm_uuids | sed -n "${vm_num}p" | xargs)
                echo "DEBUG: Selected VM UUID='$vm_uuid'"
                if [ -n "$vm_uuid" ]; then
                    start_vm "$vm_uuid"
                else
                    echo -e "${RED}Invalid selection.${RESET}"
                fi
                ;;
            7) 
                echo -e "${GREEN}Exiting...${RESET}"
                read -p "Press Enter to close the script..."
                exit 0
                ;;
            *) 
                echo -e "${RED}Invalid choice, please try again.${RESET}"
                sleep 1
                echo "DEBUG: Invalid choice detected, user entered='$choice'"
                ;;
        esac
    done
}

# Detect if script is running from curl and provide an option for GitHub execution
if [[ "$0" == "bash" || "$0" == "-bash" ]]; then
    echo -e "${YELLOW}Running in GitHub execution mode...${RESET}"
    menu
    exit 0
fi

# Run the menu
menu() {
    while true; do
        # clear (Disabled for debugging)
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
        # stty sane removed to prevent stdin issue
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
        fi # Trim spaces
        echo "DEBUG: User entered choice='$choice'"

        case $choice in
            1) 
                list_vms
                # echo "Returning to menu..."; sleep 1 (Removed to prevent loop issue)
                ;;
            2)
                list_vms
                echo -n "Enter the number of the VM to start: "
                read -r vm_num
                vm_uuid=$(get_vm_uuids | sed -n "${vm_num}p" | xargs)
                echo "DEBUG: Selected VM UUID='$vm_uuid'"
                if [ -n "$vm_uuid" ]; then
                    start_vm "$vm_uuid"
                else
                    echo -e "${RED}Invalid selection.${RESET}"
                fi
                
                ;;
            7) 
                echo -e "${GREEN}Exiting...${RESET}"
                read -p "Press Enter to close the script..."
                exit 0
                ;;
            *) 
                echo -e "${RED}Invalid choice, please try again.${RESET}"
                sleep 1
                echo "DEBUG: Invalid choice detected, user entered='$choice'"
                
                ;;
        esac
    done
}

# Run the menu
menu

