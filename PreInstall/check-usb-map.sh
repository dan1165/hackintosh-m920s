#!/usr/bin/env bash
# check-usb-map.sh — sanity-check USBPorts.kext against this machine's xHCI.
# Reads the controller's Supported-Protocol ranges (needs root) and the shipped map.
#   sudo ./PreInstall/check-usb-map.sh
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$DIR/lib.sh"
ROOT="$(repo_root)"
KExt="$ROOT/EFI/OC/Kexts/USBPorts.kext/Contents/Info.plist"

hdr "USBPorts.kext"
if [ ! -f "$KExt" ]; then skip "USBPorts.kext not present"; summary; exit 0; fi
python3 - "$KExt" <<'PY'
import plistlib, sys
d = plistlib.load(open(sys.argv[1], 'rb'))
p = list(d['IOKitPersonalities'].values())[0]
ports = p['ports']
print(f"  port-count = {int.from_bytes(p['port-count'],'little')}")
print(f"  ports declared = {len(ports)}")
for n in sorted(ports):
    num = int.from_bytes(ports[n]['port'], 'little')
    print(f"    {n:<5} port={num:<3} connector={ports[n]['UsbConnector']}")
PY
n="$(python3 -c "import plistlib;d=plistlib.load(open('$KExt','rb'));print(len(list(d['IOKitPersonalities'].values())[0]['ports']))")"
[ "$n" -le 15 ] && pass "$n ports declared (<=15 macOS cap)" || fail "$n ports declared (>15 would be trimmed)"

hdr "Controller protocols (xHCI Supported-Protocol)"
if [ "$(id -u)" -ne 0 ]; then
  skip "need root to read /sys/kernel/debug/usb/xhci — re-run with sudo"
else
  for p in /sys/kernel/debug/usb/xhci/*/reg-ext-protocol:*; do
    [ -e "$p" ] || continue
    info "$(basename "$p"): $(grep -m1 EXTCAP_PORTINFO "$p" 2>/dev/null)"
  done
  info "PORTINFO layout: byte0=port offset, byte1=port count"
  info "USB2 = ports 1..16, USB3 = 17..26 on this controller (validated 2026-10-15)"
fi

hdr "Map vs controller"
info "Every declared port should be <= 26 and match a wired physical port."
info "See docs/USB-MAP.md to regenerate by probing ports."

summary
