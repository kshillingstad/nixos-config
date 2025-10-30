#!/usr/bin/env bash
# TPM + LUKS diagnostic helper
# Usage: ./tpm-debug.sh [/dev/disk/by-uuid/UUID]
set -euo pipefail

section() { echo -e "\n=== $1 ==="; }

TPM_TCTI="device:/dev/tpmrm0"
if [[ ! -e /dev/tpmrm0 && -e /dev/tpm0 ]]; then
  TPM_TCTI="device:/dev/tpm0"
fi
export TPM2TOOLS_TCTI="$TPM_TCTI"

LUKS_DEV="${1:-/dev/disk/by-uuid/065901f2-5652-4d3d-b1ba-48569f358729}"

section "Environment"
echo "DATE: $(date)"
echo "Kernel: $(uname -r)"
echo "TPM2TOOLS_TCTI=$TPM2TOOLS_TCTI"

section "Device nodes"
ls -l /dev/tpm* 2>/dev/null || echo "No /dev/tpm* devices."

section "Loaded TPM modules"
lsmod | grep -E '^tpm' || echo "No TPM modules loaded."

section "Attempting to load modules"
for m in tpm_crb tpm_tis tpm_tis_spi; do
  if modprobe "$m" 2>/dev/null; then
    echo "Loaded module: $m"
  else
    echo "Module load failed or not present: $m"
  fi
done

section "Device nodes after modprobe"
ls -l /dev/tpm* 2>/dev/null || echo "Still none."

section "dmesg (recent TPM lines)"
dmesg | grep -i -E 'tpm|crb|tis' | tail -n 50 || echo "No TPM related dmesg lines."

section "TPM capabilities test"
if command -v tpm2_getcap >/dev/null; then
  if tpm2_getcap properties-fixed >/dev/null 2>&1; then
    tpm2_getcap properties-fixed | head -n 30
  else
    echo "tpm2_getcap failed (exit $?)."
  fi
else
  echo "tpm2-tools missing (install pkgs.tpm2-tools)."
fi

section "LUKS device check"
if [[ -e "$LUKS_DEV" ]]; then
  echo "Found LUKS device: $LUKS_DEV"
else
  echo "Missing LUKS device: $LUKS_DEV"
fi

section "systemd-cryptenroll status"
if command -v systemd-cryptenroll >/dev/null; then
  systemd-cryptenroll "$LUKS_DEV" || echo "cryptenroll status retrieval failed."
else
  echo "systemd-cryptenroll missing."
fi

section "Summary"
if [[ -e /dev/tpmrm0 || -e /dev/tpm0 ]]; then
  echo "TPM device node present."
else
  echo "TPM device node absent; check BIOS/UEFI TPM/fTPM setting."
fi
if lsmod | grep -q '^tpm'; then
  echo "TPM kernel modules loaded."
else
  echo "No TPM kernel modules loaded."
fi
if command -v tpm2_getcap >/dev/null && tpm2_getcap properties-fixed >/dev/null 2>&1; then
  echo "TPM responds to capability queries."
else
  echo "TPM capability query failed."
fi
