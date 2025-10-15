#!/bin/bash

# Quick swap setup script for Surface
# Run this before nixos-rebuild to prevent crashes during updates

set -e

echo "Setting up 8GB swap file for Surface..."

# Create an 8GB swap file
echo "Creating swap file..."
sudo fallocate -l 8G /var/lib/swapfile

# Set proper permissions (important for security)
echo "Setting permissions..."
sudo chmod 600 /var/lib/swapfile

# Format it as swap
echo "Formatting as swap..."
sudo mkswap /var/lib/swapfile

# Enable it immediately
echo "Enabling swap..."
sudo swapon /var/lib/swapfile

# Verify it's working
echo "Swap status:"
free -h
swapon --show

echo "Swap setup complete! You can now run nixos-rebuild."