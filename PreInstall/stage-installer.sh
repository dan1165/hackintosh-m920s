#!/usr/bin/env bash
# stage-installer.sh — lay out a macOS installer USB staging folder:
#     <out>/EFI/                     (this repo's EFI)
#     <out>/com.apple.recovery.boot/ (downloaded recovery for iMac19,1)
#
# It does NOT format or touch a USB device — it only creates a folder you then copy
# to a FAT32/GUID USB. Safe to re-run.
#
#   ./PreInstall/stage-installer.sh [OUTDIR]     (default: ./installer-usb)
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$DIR/lib.sh"
ROOT="$(repo_root)"
OUT="${1:-$PWD/installer-usb}"
BOARD="Mac-AA95B1DDAB278B95"       # iMac19,1

hdr "Pre-flight"
[ -f "$ROOT/EFI/OC/config.plist" ] && pass "EFI present" || { fail "EFI missing in repo"; summary; exit 1; }
have python3 && pass "python3 available" || fail "python3 required"

hdr "Recovery download"
MCREC="$ROOT/PostInstall/macrecovery/macrecovery.py"
if [ ! -f "$MCREC" ]; then fail "PostInstall/macrecovery/macrecovery.py not found"; summary; exit 1; fi
mkdir -p "$OUT"
info "board-id $BOARD  ->  $OUT/com.apple.recovery.boot"
# macrecovery needs a TTY for its progress bar; patch it if needed.
if ! python3 -c "import os,sys
try: os.get_terminal_size()
except OSError: sys.exit(3)" 2>/dev/null; then
  info "no TTY — using non-interactive patch"
  PYTHONIOENCODING=utf-8 python3 "$MCREC" -b "$BOARD" download -o "$OUT/com.apple.recovery.boot" 2>&1 | tail -3
else
  python3 "$MCREC" -b "$BOARD" download -o "$OUT/com.apple.recovery.boot" 2>&1 | tail -3
fi
[ -f "$OUT/com.apple.recovery.boot/BaseSystem.dmg" ] && pass "BaseSystem.dmg downloaded" \
  || { fail "recovery download failed (network?)"; summary; exit 1; }

hdr "EFI copy"
rm -rf "$OUT/EFI"; cp -a "$ROOT/EFI" "$OUT/EFI"
[ -d "$OUT/EFI/OC" ] && pass "EFI copied to $OUT/EFI" || fail "EFI copy failed"

hdr "Result"
info "Staging folder: $OUT"
info "Now copy BOTH items to the ROOT of a FAT32 (GUID) USB's EFI partition:"
info "  EFI/   and   com.apple.recovery.boot/"
info "Then boot it (BIOS: Secure Boot off, CSM off)."
summary
