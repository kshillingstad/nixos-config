#!/usr/bin/env bash
# Quick TPM + LUKS enrollment check for bfgpu (reusable)
set -euo pipefail

LUKS_UUID="aa186915-f570-4fc8-bb82-41685fd81007"
LUKS_DEV="/dev/disk/by-uuid/${LUKS_UUID}"

color() { local c="$1"; shift; printf "\033[1;${c}m%s\033[0m\n" "$*"; }
yellow() { color 33 "$*"; }
green()  { color 32 "$*"; }
red()    { color 31 "$*"; }

echo "=== TPM / LUKS Status Check ==="
echo "Target LUKS device: $LUKS_DEV"
echo

# 1. Verify device exists
if [[ ! -e "$LUKS_DEV" ]]; then
  red "ERROR: $LUKS_DEV not found. Check UUID."; exit 1; fi
green "Device exists."

# 2. Confirm it is LUKS
if ! sudo cryptsetup isLuks "$LUKS_DEV"; then
  red "ERROR: Device is not a LUKS container."; exit 1; fi
green "Device is a LUKS container."

# 3. Show LUKS version
VERSION=$(sudo cryptsetup luksDump "$LUKS_DEV" | awk -F': ' '/Version:/ {gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}')
echo "LUKS version: $VERSION"
[[ "$VERSION" != "2" ]] && yellow "Warning: TPM auto-unlock strongly prefers LUKS2."

# 4. TPM tool availability
if ! command -v tpm2_getcap &>/dev/null; then
  red "tpm2-tools not installed (enable security.tpm2)."
else
  green "tpm2-tools present."
fi

# 5. systemd-cryptenroll slot inspection
echo; echo "--- systemd-cryptenroll output ---"
ENROLL_OUT=$(sudo systemd-cryptenroll "$LUKS_DEV" || true)
echo "$ENROLL_OUT"
echo "----------------------------------"; echo

TPM_SLOT_LINE=$(printf "%s\n" "$ENROLL_OUT" | awk '/^[[:space:]]+[0-9]+[[:space:]]+tpm2( |$)/ {print}')
if [[ -n "$TPM_SLOT_LINE" ]]; then
  green "TPM slot present: $TPM_SLOT_LINE"
  PCRS=$(printf "%s\n" "$TPM_SLOT_LINE" | sed -n 's/.*PCRs: *//p')
  [[ -n "$PCRS" ]] && echo "Sealed to PCRs: $PCRS"
  STATUS=0
else
  red "No TPM2 slot enrolled."
  STATUS=1
fi

# 6. Check NixOS systemd initrd (best-effort)
if grep -R "boot.initrd.systemd.enable = true" /nix/store 2>/dev/null | head -n1 >/dev/null; then
  green "Systemd initrd appears enabled."
else
  yellow "Could not verify systemd initrd; assume module sets it."
fi

echo
if [[ $STATUS -eq 0 ]]; then
  green "RESULT: LUKS should auto-unlock via TPM on boot."
else
  red "RESULT: TPM auto-unlock not enrolled. Enroll with:";
  echo "  sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7 $LUKS_DEV"
fi

echo "=== Done ==="
exit $STATUS
