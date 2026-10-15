#!/usr/bin/env bash
# check-efi.sh — validate the EFI tree: config parses, every referenced file exists,
# ocvalidate is clean, kext/ACPI/driver inventory is consistent.
#   ./PreInstall/check-efi.sh
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$DIR/lib.sh"
ROOT="$(repo_root)"; CFG="$ROOT/EFI/OC/config.plist"

hdr "config.plist"
if [ -f "$CFG" ]; then pass "present: EFI/OC/config.plist"; else fail "EFI/OC/config.plist MISSING"; summary; exit 1; fi

if python3 - "$CFG" >/dev/null 2>&1 <<'PY'
import plistlib,sys
plistlib.load(open(sys.argv[1],'rb'))
PY
then pass "parses as an XML plist"; else fail "config.plist does not parse"; fi

hdr "Referenced files exist"
missing_report="$(python3 - "$ROOT" "$CFG" <<'PY'
import plistlib, sys, os
root, cfg = sys.argv[1], sys.argv[2]
c = plistlib.load(open(cfg, 'rb'))
miss = []
for e in c.get('ACPI', {}).get('Add', []):
    if e.get('Enabled') and not os.path.exists(os.path.join(root,'EFI/OC/ACPI',e['Path'])): miss.append('ACPI: '+e['Path'])
for k in c.get('Kernel', {}).get('Add', []):
    if k.get('Enabled') and not os.path.isdir(os.path.join(root,'EFI/OC/Kexts',k['BundlePath'])): miss.append('KEXT: '+k['BundlePath'])
for d in c.get('UEFI', {}).get('Drivers', []):
    if d.get('Enabled') and not os.path.exists(os.path.join(root,'EFI/OC/Drivers',d['Path'])): miss.append('DRIVER: '+d['Path'])
for t in c.get('Misc', {}).get('Tools', []):
    if t.get('Enabled') and not os.path.exists(os.path.join(root,'EFI/OC/Tools',t['Path'])): miss.append('TOOL: '+t['Path'])
print(len(miss))
for m in miss: print('        '+m)
PY
)"
missing_count="${missing_report%%$'\n'*}"
if [ "$missing_count" = "0" ]; then
  pass "all enabled ACPI/kext/driver/tool files are present"
else
  fail "$missing_count referenced file(s) missing"
  printf '%s\n' "$missing_report" | tail -n +2
fi

hdr "ocvalidate"
OCV="$ROOT/PostInstall/ocvalidate.linux"
if [ -x "$OCV" ]; then
  if out="$("$OCV" "$CFG" 2>&1)"; then pass "ocvalidate clean"; else fail "ocvalidate reported problems"; fi
  printf '%s\n' "$out" | tail -2 | sed 's/^/        /'
else
  skip "PostInstall/ocvalidate.linux not present/executable"
fi

hdr "Inventory"
printf "  ACPI:  %s\n" "$(ls "$ROOT/EFI/OC/ACPI" 2>/dev/null | tr '\n' ' ')"
printf "  Kexts: %s\n" "$(ls "$ROOT/EFI/OC/Kexts" 2>/dev/null | tr '\n' ' ')"
printf "  Drvrs: %s\n" "$(ls "$ROOT/EFI/OC/Drivers" 2>/dev/null | tr '\n' ' ')"
printf "  Tools: %s\n" "$(ls "$ROOT/EFI/OC/Tools" 2>/dev/null | tr '\n' ' ')"

hdr "USBPorts.kext"
UP="$ROOT/EFI/OC/Kexts/USBPorts.kext/Contents/Info.plist"
if [ -f "$UP" ]; then
  n="$(python3 - "$UP" <<'PY'
import plistlib,sys
d=plistlib.load(open(sys.argv[1],'rb'))
p=list(d['IOKitPersonalities'].values())[0]
print(len(p['ports']))
PY
)"
  [ "$n" -ge 1 ] && [ "$n" -le 15 ] && pass "USBPorts.kext declares $n ports (<=15)" \
    || warn "USBPorts.kext declares $n ports (should be <=15)"
else
  skip "USBPorts.kext not present (map not shipped)"
fi

summary
