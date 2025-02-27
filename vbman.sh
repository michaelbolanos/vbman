#!/bin/bash
################################################################################
# vbman.sh - VirtualBox CLI Management Script for Windows via Git Bash, WSL, or Cygwin
################################################################################

# Detect Windows environment and set VBoxManage path
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "linux-gnu" && -n "$(grep -i microsoft /proc/version)" ]]; then
    VBOXMANAGE="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
else
    VBOXMANAGE="VBoxManage"
fi

# Colors for output
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
CYAN="$(tput setaf 6)"
RESET="$(tput sgr0)"

# List all VMs
list_vms() {
    echo -e "${CYAN}Available Virtual Machines:${RESET}"
    running_vms=$($VBOXMANAGE list runningvms | awk -F\" '{print $2}')
    
    i=1
    $VBOXMANAGE list vms | while read -r line; do
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

# Start a VM
start_vm() {
    local vm_uuid="$1"
    echo -e "${YELLOW}Starting VM: $vm_uuid...${RESET}"
    $VBOXMANAGE startvm "$vm_uuid" --type headless
}

# Shutdown a VM
shutdown_vm() {
    local vm_uuid="$1"
    echo -e "${YELLOW}Attempting graceful shutdown: $vm_uuid...${RESET}"
    $VBOXMANAGE controlvm "$vm_uuid" acpipowerbutton
    sleep 5
    if $VBOXMANAGE list runningvms | grep -q "$vm_uuid"; then
        echo -e "${RED}Force shutting down: $vm_uuid...${RESET}"
        $VBOXMANAGE controlvm "$vm_uuid" poweroff
    fi
}

# Menu
menu() {
    while true; do
        echo -e "${CYAN}======================================${RESET}"
        echo -e "${YELLOW} VirtualBox VM Management Script ${RESET}"
        echo -e "${CYAN}======================================${RESET}"
        echo -e "${GREEN}1)${RESET} List all VMs"
        echo -e "${GREEN}2)${RESET} Start a VM"
        echo -e "${GREEN}3)${RESET} Shut down a VM"
        echo -e "${RED}4) Exit${RESET}"
        echo -e "${CYAN}======================================${RESET}"
        echo -n "Enter your choice: "
        read -r choice
        case $choice in
            1) list_vms ;;
            2)
                list_vms
                echo -n "Enter VM number to start: "
                read -r vm_num
                vm_uuid=$($VBOXMANAGE list vms | awk -F\" '{print $3}' | tr -d '{} ' | sed -n "${vm_num}p" | xargs)
                [ -n "$vm_uuid" ] && start_vm "$vm_uuid"
                ;;
            3)
                list_vms
                echo -n "Enter VM number to shut down: "
                read -r vm_num
                vm_uuid=$($VBOXMANAGE list vms | awk -F\" '{print $3}' | tr -d '{} ' | sed -n "${vm_num}p" | xargs)
                [ -n "$vm_uuid" ] && shutdown_vm "$vm_uuid"
                ;;
            4) echo -e "${GREEN}Exiting...${RESET}"; exit 0 ;;
            *) echo -e "${RED}Invalid choice!${RESET}" ;;
        esac
    done
}

# Run menu
menu
