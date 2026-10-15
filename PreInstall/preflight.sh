#!/usr/bin/env bash
# preflight.sh — run every pre-install check in one go.
#   ./PreInstall/preflight.sh            # hardware + EFI (fast, offline)
#   ./PreInstall/preflight.sh --all      # also MSR (needs root) + upstream hash check (network)
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$DIR/lib.sh"

ALL=0; [ "${1:-}" = "--all" ] && ALL=1

printf "%sThinkCentre M920s — pre-install preflight%s\n" "$C_BLD" "$C_RESET"

"$DIR/check-hardware.sh"; HW=$?

"$DIR/check-efi.sh"; EFI=$?

if [ "$ALL" = 1 ]; then
  "$DIR/check-msr.sh" || true
  "$DIR/verify-upstream.sh" || true
else
  info "run with --all to also check MSR (root) and upstream hashes (network)"
fi

hdr "Preflight result"
rc=0
[ "$HW"  -eq 0 ] || { fail "hardware check reported a FAIL"; rc=1; }
[ "$EFI" -eq 0 ] || { fail "EFI check reported a FAIL"; rc=1; }
if [ "$rc" -eq 0 ]; then
  printf "  %sReady to build the USB / install.%s\n" "$C_GRN" "$C_RESET"
  printf "  Next: %s./PreInstall/stage-installer.sh%s\n" "$C_BLD" "$C_RESET"
else
  printf "  %sFix the FAIL items above before installing.%s\n" "$C_RED" "$C_RESET"
fi
exit "$rc"
