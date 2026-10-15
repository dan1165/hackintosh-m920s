#!/usr/bin/env bash
# check-hardware.sh — verify this machine matches the documented ThinkCentre M920s.
# Exit 0 = matches (or only warnings); 1 = a required device is missing/different.
#
# Run on the target machine BEFORE install:  ./PreInstall/check-hardware.sh
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$DIR/lib.sh"

hdr "Hardware identity"
printf "  %-22s %s\n" "Model"       "$(dmi product_family)"
printf "  %-22s %s\n" "MTM"         "$(dmi product_name)"
printf "  %-22s %s\n" "Board"       "$(dmi board_name)"
printf "  %-22s %s\n" "BIOS"        "$(dmi bios_version)"
printf "  %-22s %s\n" "CPU"         "$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^ //')"

_mdl="$(dmi product_family)"; [ -z "$_mdl" ] && _mdl="$(dmi product_version)"
case "$_mdl" in
  *M920s*) pass "model = $_mdl" ;;
  *)       warn "model = '$_mdl' (expected ThinkCentre M920s) — verify variant" ;;
esac
[ "$(dmi board_name)" = "3132" ] && pass "board = 3132" || warn "board = $(dmi board_name) (expected 3132)"

hdr "Required PCI devices"
chk_pci() { # id  label  required(0/1)
  if has_pci "$1"; then pass "$2 ($1)"; else
    [ "$3" = 1 ] && fail "$2 ($1) MISSING" || warn "$2 ($1) missing (optional)"; fi
}
chk_pci "8086:3e98" "Intel UHD 630 iGPU"     1
chk_pci "8086:a36d" "Intel xHCI (USB)"       1
chk_pci "8086:a352" "Intel SATA AHCI"        1
chk_pci "8086:15bb" "Intel I219-LM Ethernet" 1
chk_pci "8086:a348" "Intel HD Audio"         1
chk_pci "8086:a306" "Intel Q370 LPC/eSPI"    1
chk_pci "8086:a323" "Intel SMBus"            1
chk_pci "15b7:5006" "WD SN730 NVMe (target)" 0

hdr "Audio codec"
if [ -r /proc/asound/card0/codec#0 ]; then
  codec="$(grep -m1 '^Codec:' /proc/asound/card0/codec#0 | sed 's/Codec: //')"
  [ "$codec" = "Realtek ALC233" ] && pass "codec = $codec" || warn "codec = $codec (expected Realtek ALC233)"
else
  skip "no /proc/asound/card0/codec#0 (ALSA not loaded)"
fi

hdr "CPU family"
if grep -q 'model.*158' /proc/cpuinfo 2>/dev/null; then pass "CPUID model 158 (Coffee Lake)"; else warn "unexpected CPU model"; fi

summary
