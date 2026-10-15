#!/usr/bin/env bash
# Shared helpers for the PreInstall checks. Source this; don't run it.
# Works on Linux (pre-install) and macOS (post-install) where noted.

set -u

# --- colours (auto-disabled when not a TTY) ---------------------------------
if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'; C_BLU=$'\033[34m'; C_BLD=$'\033[1m'
else
  C_RESET=; C_RED=; C_GRN=; C_YEL=; C_BLU=; C_BLD=
fi

# --- result counters --------------------------------------------------------
PASS=0; WARN=0; FAIL=0; SKIP=0

hdr()   { printf "\n%s%s%s\n%s\n" "$C_BLD" "$1" "$C_RESET" "$(printf '%*s' "${#1}" '' | tr ' ' '-')"; }
pass()  { printf "  %sPASS%s  %s\n" "$C_GRN" "$C_RESET" "$1"; PASS=$((PASS+1)); }
warn()  { printf "  %sWARN%s  %s\n" "$C_YEL" "$C_RESET" "$1"; WARN=$((WARN+1)); }
fail()  { printf "  %sFAIL%s  %s\n" "$C_RED" "$C_RESET" "$1"; FAIL=$((FAIL+1)); }
skip()  { printf "  %sSKIP%s  %s\n" "$C_BLU" "$C_RESET" "$1"; SKIP=$((SKIP+1)); }
info()  { printf "  %sINFO%s  %s\n" "$C_BLU" "$C_RESET" "$1"; }

# --- utilities --------------------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }

# has_pci <vendor:device>  -> 0 if present in lspci -nn
has_pci() { lspci -nn 2>/dev/null | grep -qi -- "$1"; }

# dmi <field>
dmi() { cat "/sys/class/dmi/id/$1" 2>/dev/null; }

# repo_root: print the repo root (dir containing EFI/ and docs/)
repo_root() {
  local d; d="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  echo "$d"
}

# summary: print the tail summary and exit non-zero if any FAIL
summary() {
  hdr "Summary"
  printf "  %s%d passed%s, %s%d warnings%s, %s%d failed%s, %d skipped\n" \
    "$C_GRN" "$PASS" "$C_RESET" "$C_YEL" "$WARN" "$C_RESET" "$C_RED" "$FAIL" "$C_RESET" "$SKIP"
  if [ "$FAIL" -gt 0 ]; then
    printf "  %sRESULT: FAIL%s\n" "$C_RED" "$C_RESET"; return 1
  elif [ "$WARN" -gt 0 ]; then
    printf "  %sRESULT: PASS (with warnings)%s\n" "$C_YEL" "$C_RESET"; return 0
  else
    printf "  %sRESULT: PASS%s\n" "$C_GRN" "$C_RESET"; return 0
  fi
}
