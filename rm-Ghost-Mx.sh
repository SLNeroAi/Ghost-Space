#!/bin/bash

# @fileOverview Uninstaller for GHOST VPN Monitor
# @author MasterHide
# @Copyright © 2025 x404 MASTER™
# @license MIT
#
# You may not reproduce or distribute this work, in whole or in part, 
# without the express written consent of the copyright owner.
#
# For more information, visit: https://t.me/Dark_Evi

SERVICE_NAME="ghost-vpn"
PROJECT_DIR="ghost-vpn-monitor"

# Ask user for confirmation
echo "This script will uninstall GHOST VPN and all associated files. Are you sure you want to proceed? (y/n)"
read CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Uninstallation canceled."
    exit 0
fi

# Stop and disable the systemd service
echo "Stopping and disabling the GHOST VPN service..."
sudo systemctl stop $SERVICE_NAME
sudo systemctl disable $SERVICE_NAME

# Remove the systemd service file
echo "Removing the GHOST VPN systemd service file..."
sudo rm -f /etc/systemd/system/$SERVICE_NAME.service

# Reload systemd to reflect changes
sudo systemctl daemon-reload

# Ask for the OS username used during installation
echo "Enter the OS username used during installation (e.g., ubuntu):"
read USERNAME

# Remove the GHOST VPN directory and its contents
echo "Removing the GHOST VPN directory..."
sudo rm -rf /home/$USERNAME/$PROJECT_DIR

# Remove SSL certificates
echo "Removing SSL certificates..."
sudo rm -rf /var/lib/$SERVICE_NAME/certs

# Remove acme.sh (optional, if it was installed specifically for this app)
echo "Removing acme.sh (SSL certificate tool)..."
# We only remove acme.sh if it was installed in the root directory by default
sudo rm -rf /root/.acme.sh

# Remove cron job added by acme.sh (if any)
echo "Removing acme.sh cron job..."
# This attempts to clean the default acme.sh cron entry
sudo crontab -l | grep -v "/root/.acme.sh/acme.sh --cron" | sudo crontab -

# Remove log files
echo "Removing GHOST VPN log files..."
sudo rm -f /var/log/$SERVICE_NAME.log

# Optional: Remove Python dependencies (if no longer needed)
echo "Do you want to uninstall Python dependencies installed for GHOST VPN? (y/n)"
read REMOVE_DEPS

if [ "$REMOVE_DEPS" == "y" ]; then
    echo "Uninstalling Python dependencies..."
    # Note: These are general dependencies, only remove if the user confirms
    sudo apt remove -y python3-pip python3-venv git sqlite3 socat
    sudo apt autoremove -y
else
    echo "Skipping Python dependency removal."
fi

# Final message
echo "GHOST VPN has been successfully uninstalled."
