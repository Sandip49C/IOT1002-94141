#!/bin/bash

# FolderCreation.sh - Script to create folder structure under /EmployeeData with specific permissions

# Create the base directory /EmployeeData as root
sudo mkdir -p /EmployeeData

# Array of all department folders
folders=("HR" "IT" "Finance" "Executive" "Administrative" "Call Centre")

# Counter for folders created
folder_count=0

# Loop through each folder to create it, set permissions, and ownership
for folder in "${folders[@]}"; do
    sudo mkdir -p "/EmployeeData/$folder"
    ((folder_count++))
    group_name=$(echo "$folder" | tr -d ' ')
    sudo chown root:"$group_name" "/EmployeeData/$folder"
    if [ "$folder" = "HR" ] || [ "$folder" = "Executive" ]; then
        sudo chmod -R 760 "/EmployeeData/$folder"  # Sensitive: u=rwx,g=rw,o=
    else
        sudo chmod -R 764 "/EmployeeData/$folder"  # Non-sensitive: u=rwx,g=rw,o=r
    fi
done

# Display final message
echo "Folder creation complete. $folder_count folders were created."
