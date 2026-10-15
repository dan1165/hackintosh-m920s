#!/usr/bin/env bash
# check-msr.sh — check CFG Lock (MSR 0xE2 bit 15) and VT-d, which decide two config quirks.
#   CFG Lock locked  -> Kernel > Quirks > AppleXcpmCfgLock = true   (this build sets true)
#   VT-d / DMAR      -> Kernel > Quirks > DisableIoMapper   = true   (this build sets true)
# Needs root + the msr module on Linux.  ./PreInstall/check-msr.sh
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$DIR/lib.sh"

hdr "CFG Lock (MSR 0xE2)"
if [ "$(id -u)" -ne 0 ]; then
  skip "needs root — re-run: sudo $0"
else
  if have rdmsr; then
    val="$(rdmsr -a 0xE2 2>/dev/null | head -1)"
    if [ -n "$val" ]; then
      # bit 15 of the low 32 bits
      lo=$(( 16#${val:8:2}${val:10:2}${val:12:2}${val:14:2} ))
      if [ $(( lo & 0x8000 )) -ne 0 ]; then
        pass "CFG Lock LOCKED (MSR 0xE2 = 0x$val) -> AppleXcpmCfgLock=true is correct"
      else
        warn "CFG Lock appears UNLOCKED -> you may set AppleXcpmCfgLock=false"
      fi
    else
      warn "rdmsr returned nothing (module not loaded? run: modprobe msr)"
    fi
  else
    skip "rdmsr not installed (install 'msr-tools' / 'msr' package)"
  fi
fi

hdr "DMAR / VT-d"
if [ -e /sys/firmware/acpi/tables/DMAR ]; then
  pass "DMAR table present (VT-d firmware-side) -> DisableIoMapper=true is correct"
else
  info "no DMAR table — DisableIoMapper may not be needed"
fi

summary
