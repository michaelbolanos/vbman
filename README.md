# vbman - VirtualBox VM Manager

<img src="https://upload.wikimedia.org/wikipedia/commons/d/d5/Virtualbox_logo.png" width="163" alt="VirtualBox Logo">

## Overview
**vbman** is a lightweight command-line tool for managing VirtualBox virtual machines (VMs) on Linux and macOS. It provides an interactive menu to list, start, and stop VMs with both graceful and force shutdown options. This script simplifies VM management without the need for the VirtualBox GUI.

---

## 🎯 Features
✅ List all available VMs with their status (Running/Stopped)  
✅ Start VMs in **Headed (GUI)** or **Headless (background)** mode  
✅ Gracefully shut down VMs using **ACPI Power Button**  
✅ Force shutdown VMs when necessary  
✅ Bulk shutdown options for all running VMs  
✅ Interactive menu for easy management  

---

## 📌 Quick Install & Run (One-Liner)

**Run this command to instantly download & run vbman**

```bash
bash <(curl -sSL https://raw.githubusercontent.com/michaelbolanos/vbman/main/vbman.sh)
```

> No need to manually clone the repository! Just copy, paste, and go!

---

## Prerequisites
Ensure that VirtualBox and `VBoxManage` are installed on your system:
```bash
# Install VirtualBox (Linux)
sudo apt install virtualbox  # Debian-based
sudo dnf install virtualbox  # Fedora-based

# Install VirtualBox (macOS, via Homebrew)
brew install --cask virtualbox
```

---

## Installation (Manual)
Clone the repository and make the script executable:
```bash
git clone https://github.com/michaelbolanos/vbman.git
cd vbman
chmod +x vbman.sh
```

---

## Usage
Run the script to open the interactive menu:
```bash
./vbman.sh
```

Alternatively, run specific commands directly:
```bash
# List all VMs
./vbman.sh list

# Start a specific VM (by name or UUID)
./vbman.sh start <vm_name_or_uuid>

# Gracefully shut down a VM
./vbman.sh shutdown <vm_name_or_uuid>

# Force shut down a VM
./vbman.sh force-shutdown <vm_name_or_uuid>
```

---

## Example Output
```
======================================
 🎛️ VirtualBox VM Management Script 🎛️
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

---

## History: Iteration from Curl to Bash
Initially, **vbman** was designed to be executed via a direct `curl` pipe:
```bash
curl -sSL https://raw.githubusercontent.com/michaelbolanos/vbman/main/vbman.sh | bash
```
However, this method caused **input issues** where the script could not properly capture user choices in the interactive menu. This was due to `bash` reading input directly from the pipe instead of allowing keyboard interaction.

### Iteration Process:
1. **Direct Pipe Execution (`curl | bash`)** → Caused input issues.
2. **Writing to a Temporary File First** → Allowed execution but cluttered the system.
3. **Process Substitution (`bash <(curl ...)`)** → Fixed interactive input while keeping the one-liner simple.

### Final Solution:
The final iteration settled on:
```bash
bash <(curl -sSL https://raw.githubusercontent.com/michaelbolanos/vbman/main/vbman.sh)
```
✅ Ensures full script execution before user input.  
✅ Maintains simplicity—no need to manually download the script.  
✅ Works consistently across macOS and Linux environments.

---

## 👤 Author
Created by [Michael Bolanos](https://github.com/michaelbolanos)

