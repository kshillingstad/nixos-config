#!/bin/bash

# TPM LUKS Enrollment Script for bfgpu
# Run this after rebuilding NixOS with tpm2 + systemd initrd enabled.

set -e

LUKS_DEVICE="/dev/disk/by-uuid/aa186915-f570-4fc8-bb82-41685fd81007"

echo "=== bfgpu TPM LUKS Enrollment Setup ==="
echo "LUKS Device: $LUKS_DEVICE"
echo

echo "1. Checking TPM status..."
if ! command -v tpm2_getcap &> /dev/null; then
  echo "ERROR: tpm2-tools not found. Rebuild NixOS first (security.tpm2.enable)."
  exit 1
fi

tpm2_getcap properties-fixed || true
echo

echo "2. Verifying LUKS device exists..."
if [ ! -e "$LUKS_DEVICE" ]; then
  echo "ERROR: $LUKS_DEVICE not found. Confirm UUID matches crypt volume."
  exit 1
fi
echo "Found: $LUKS_DEVICE"
echo

echo "3. Current LUKS enrollment status (slots):"
sudo systemd-cryptenroll "$LUKS_DEVICE" || true
echo

echo "4. Enrolling TPM key (PCRs 0,2,7)..."
echo "You will be prompted for your current LUKS passphrase."
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7 "$LUKS_DEVICE"

echo

echo "5. Verifying TPM enrollment..."
sudo systemd-cryptenroll "$LUKS_DEVICE"

echo

echo "=== Complete ==="
echo "Automatic TPM unlock should now work on next boot."
echo "Fallback: use your passphrase if TPM fails."
echo

echo "Test without reboot (will still require passphrase prompt here):"
echo "  sudo cryptsetup open --test-passphrase $LUKS_DEVICE"
echo

echo "Remove TPM enrollment if needed:"
echo "  sudo systemd-cryptenroll --wipe-slot=tpm2 $LUKS_DEVICE"
