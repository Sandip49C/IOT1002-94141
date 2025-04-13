#!/bin/bash

# Get current date for log file naming
CURRENT_DATE=$(date +%Y-%m-%d)
LOG_FILE=~/ProcessUsageReport-${CURRENT_DATE}.log

# Function to get department from primary group
get_department() {
    local username=$1
    local group=$(id -gn "$username")
    echo "$group"  # Using primary group as department
}

# Get top 5 processes by CPU usage
echo "Analyzing system processes..."
top_processes=$(ps -eo user,pid,%cpu,stime --sort=-%cpu | head -n 6 | tail -n 5)

# Display processes to user
echo -e "\nTop 5 processes by CPU usage:"
echo "USER       PID    %CPU    START TIME"
echo "------------------------------------"
echo "$top_processes"
echo "------------------------------------"

# Ask for confirmation
read -p "Would you like to kill these processes? (y/n): " response

if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
    echo "No processes were killed. Exiting..."
    exit 0
fi

# Counter for killed processes
killed_count=0

# Create or clear log file
echo "Process Termination Log - $CURRENT_DATE" > "$LOG_FILE"
echo "------------------------------------" >> "$LOG_FILE"

# Process each line of top processes
echo "$top_processes" | while read -r line; do
    # Extract process details
    username=$(echo "$line" | awk '{print $1}')
    pid=$(echo "$line" | awk '{print $2}')

    # Skip root processes
    if [ "$username" == "root" ]; then
        continue
    fi

    # Get start time and current time
    start_time=$(echo "$line" | awk '{print $4}')
    kill_time=$(date +"%H:%M:%S")
    department=$(get_department "$username")

    # Kill the process
    kill -9 "$pid" 2>/dev/null
    if [ $? -eq 0 ]; then
        # Log details
        echo "Process PID: $pid" >> "$LOG_FILE"
        echo "Username: $username" >> "$LOG_FILE"
        echo "Department: $department" >> "$LOG_FILE"
        echo "Started: $start_time" >> "$LOG_FILE"
        echo "Killed: $kill_time" >> "$LOG_FILE"
        echo "------------------------------------" >> "$LOG_FILE"

        ((killed_count++))
    fi
done

# Display final message
echo -e "\nProcess termination complete!"
echo "Number of processes killed: $killed_count"
echo "Log file saved as: $LOG_FILE"

exit 0
