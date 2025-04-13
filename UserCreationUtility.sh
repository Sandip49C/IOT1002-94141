#!/bin/bash

# Variables to keep track of the number of users and groups added
new_users_count=0
new_groups_count=0

# Read the file line by line
while IFS=',' read -r first_name last_name department; do
    # Create the username
    username="${first_name:0:1}${last_name:0:7}"
    
    # Check if the user already exists
    if id -u "$username" >/dev/null 2>&1; then
        echo "Error: User $username already exists."
        continue
    else
        # Create the user
        sudo useradd -m "$username" -c "$first_name $last_name"
        echo "User $username created."
        ((new_users_count++))
    fi

    # Check if the group (department) exists
    if getent group "$department" >/dev/null 2>&1; then
        echo "Error: Group $department already exists."
    else
        # Create the group
        sudo groupadd "$department"
        echo "Group $department created."
        ((new_groups_count++))
    fi

    # Check if the user is already a member of the group
    if id -nG "$username" | grep -qw "$department"; then
        echo "Error: User $username is already a member of group $department."
    else
        # Add the user to the group
        sudo usermod -aG "$department" "$username"
        echo "User $username added to group $department."
    fi

done < /home/vboxuser/EmployeeNames.csv

# Output the final message
echo "Total new users added: $new_users_count"
echo "Total new groups added: $new_groups_count"

# Proper comments
# Script reads user details from a CSV file
# Creates users and groups as needed
# Adds users to their respective groups
