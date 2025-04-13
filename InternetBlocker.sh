#!/bin/bash

# Script Name: InternetBlocker.sh
# Purpose: Block HTTP/HTTPS traffic for all users except IT group and allow local web server

# Get list of users in IT group 
IT_USERS=$(getent group itgroup | cut -d: -f4 | tr ',' ' ')
COUNT=0

# Loop through each IT user and create iptables rule for HTTPS (port 443)
for USER in $IT_USERS
do
    # Add rule to allow HTTPS traffic for this user
    sudo iptables -A OUTPUT -p tcp --dport 443 -m owner --uid-owner $USER -j ACCEPT
    # Add rule for HTTP too (port 80) since assignment mentions both
    sudo iptables -A OUTPUT -p tcp --dport 80 -m owner --uid-owner $USER -j ACCEPT
    COUNT=$((COUNT + 1)) # Count how many users we process
done

# Add exception for local web server (HTTPS traffic to 192.168.2.3)
sudo iptables -A OUTPUT -p tcp --dport 443 -d 192.168.2.3 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 80 -d 192.168.2.3 -j ACCEPT # Adding HTTP as well

# Block special access ports as specified
sudo iptables -t filter -A OUTPUT -p tcp --dport 8003 -j DROP
sudo iptables -t filter -A OUTPUT -p tcp --dport 1979 -j DROP

# Block all other HTTP/HTTPS traffic for everyone else
sudo iptables -A OUTPUT -p tcp --dport 443 -j DROP
sudo iptables -A OUTPUT -p tcp --dport 80 -j DROP

# Show final message with number of IT users granted access
echo "Internet access granted to $COUNT IT users."

# End of script
exit 0
