#!/bin/bash

# TPM LUKS Enrollment Script
# Run this script after rebuilding NixOS with TPM support

set -e

LUKS_DEVICE="/dev/disk/by-uuid/e74e8861-32b3-4863-acb0-a3d0d554202d"

echo "=== TPM LUKS Enrollment Setup ==="
echo "LUKS Device: $LUKS_DEVICE"
echo

# Step 1: Check TPM status
echo "1. Checking TPM status..."
if ! command -v tpm2_getcap &> /dev/null; then
    echo "ERROR: tpm2-tools not found. Make sure you've rebuilt NixOS first."
    exit 1
fi

tpm2_getcap properties-fixed
echo

# Step 2: Verify LUKS device exists
echo "2. Verifying LUKS device exists..."
if [ ! -e "$LUKS_DEVICE" ]; then
    echo "ERROR: LUKS device $LUKS_DEVICE not found"
    exit 1
fi
echo "LUKS device found: $LUKS_DEVICE"
echo

# Step 3: Show current enrollment status
echo "3. Current LUKS enrollment status:"
sudo systemd-cryptenroll "$LUKS_DEVICE" || true
echo

# Step 4: Enroll TPM key
echo "4. Enrolling TPM key..."
echo "This will prompt for your current LUKS passphrase."
echo "PCRs used: 0 (BIOS/UEFI), 2 (boot config), 7 (secure boot)"
echo

sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7 "$LUKS_DEVICE"

# Step 5: Verify enrollment
echo
echo "5. Verifying TPM enrollment..."
sudo systemd-cryptenroll "$LUKS_DEVICE"
echo

echo "=== Setup Complete ==="
echo "Your LUKS partition should now unlock automatically via TPM on boot."
echo "If TPM unlock fails, you can still use your passphrase as fallback."
echo
echo "To test TPM unlock without rebooting:"
echo "  sudo cryptsetup open --test-passphrase $LUKS_DEVICE"
echo
echo "To remove TPM enrollment (if needed):"
echo "  sudo systemd-cryptenroll --wipe-slot=tpm2 $LUKS_DEVICE"