#!/usr/bin/env bash
# postflight.sh — run ON macOS after install to verify the system came up as expected.
#   ./PostInstall/postflight.sh        (from the repo, or copy just this file over)
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/../PreInstall/lib.sh" 2>/dev/null || {
  PASS=0; WARN=0; FAIL=0; SKIP=0
  hdr(){ printf "\n%s\n%s\n" "$1" "$(printf '%*s' ${#1} '' | tr ' ' '-')"; }
  pass(){ printf "  PASS  %s\n" "$1"; PASS=$((PASS+1)); }
  warn(){ printf "  WARN  %s\n" "$1"; WARN=$((WARN+1)); }
  fail(){ printf "  FAIL  %s\n" "$1"; FAIL=$((FAIL+1)); }
  skip(){ printf "  SKIP  %s\n" "$1"; SKIP=$((SKIP+1)); }
  info(){ printf "  INFO  %s\n" "$1"; }
  summary(){ hdr Summary; printf "  %d pass %d warn %d fail\n" "$PASS" "$WARN" "$FAIL"; [ "$FAIL" -eq 0 ]; }
}

[ "$(uname)" = "Darwin" ] || { echo "This script must run on macOS."; exit 1; }

hdr "macOS"
printf "  %s\n" "$(sw_vers | tr '\n' ' ')"

hdr "Loaded third-party kexts"
want="Lilu VirtualSMC SMCProcessor SMCSuperIO WhateverGreen AppleALC IntelMausi NVMeFix RestrictEvents USBPorts"
loaded="$(kextstat 2>/dev/null | grep -v com.apple)"
for k in $want; do
  echo "$loaded" | grep -qi "$k" && pass "$k loaded" || warn "$k NOT loaded"
done

hdr "SMBus (SSDT-SBUS-MCHC)"
kextstat 2>/dev/null | grep -qE "AppleSMBusController|AppleSMBusPCI" && pass "AppleSMBus present" || warn "AppleSMBus not present"

hdr "CPU power management"
[ "$(sysctl -n machdep.xcpm.mode 2>/dev/null)" = "1" ] && pass "XCPM active" || warn "XCPM not active (SSDT-PLUG?)"

hdr "Graphics"
if system_profiler SPDisplaysDataType 2>/dev/null | grep -qi "UHD Graphics 630"; then
  pass "UHD 630 detected"; else warn "UHD 630 not reported"; fi

hdr "Ethernet"
if networksetup -listallhardwareports 2>/dev/null | grep -qi "Ethernet"; then pass "Ethernet port present"; else warn "no Ethernet port"; fi

hdr "SMBIOS"
sp="$(sysctl -n hw.model 2>/dev/null)"; [ -n "$sp" ] && info "hw.model = $sp"
info "serial/MLB/ROM: check System Settings → General → About, and iMessage sign-in"

summary
