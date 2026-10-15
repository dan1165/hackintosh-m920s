#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# usb-port-report.sh — collect physical USB port numbers for a USBPorts.kext
#
# Purpose: build the port map used by macOS on this machine's Intel xHCI
#          (16 USB2 ports + 10 USB3 ports). Run as a NORMAL user on Linux.
#
# Usage:
#   1) chmod +x usb-port-report.sh
#   2) ./usb-port-report.sh
#   3) Plug a USB stick/keyboard into EACH physical USB port, one at a time,
#      waiting ~2 s between plugs (unplug before moving to the next port).
#   4) Note every distinct "bus <b> port <p>" line it prints.
#   5) Ctrl-C when finished.
#
# Reading the result:
#   "bus 1 port N"  -> a USB2 lane  -> macOS HS0N   (port value = N)
#   "bus 2 port N"  -> a USB3 lane  -> macOS SS0N   (port value = N)
#   A physical USB3 port reports bus 1 with a USB2 device and bus 2 with a
#   USB3 device, i.e. it needs BOTH an HS and an SS entry.
#
# Then feed those port numbers into USBToolBox (recommended) or create
# USBPorts.kext, and add it to config.plist -> Kernel -> Add.
# A pre-made template is in tools/USBPorts-template.plist.
# ---------------------------------------------------------------------------
set -u
DEVDIR=/sys/bus/usb/devices
declare -A seen

list_ports() {
  for p in "$DEVDIR"/*/; do
    n=$(basename "$p")
    # devices look like "1-6" or "1-6.2"; ignore interfaces "1-6:1.0" and roots
    case "$n" in
      [0-9]*-[0-9]*) case "$n" in *:*) ;; *) echo "$n";; esac;;
    esac
  done
}

echo "=================== USB controller summary ==================="
for h in "$DEVDIR"/usb[0-9]*; do
  [ -e "$h" ] || continue
  printf "  %-10s %2s ports @ %s Mbps\n" "$(basename "$h")" \
         "$(cat "$h/maxchild" 2>/dev/null)" "$(cat "$h/speed" 2>/dev/null)"
done
echo "=============================================================="
echo
echo "Watching for port changes. Plug a device into each physical port."
echo "Press Ctrl-C when done."
echo

while read -r n; do seen[$n]=1; done < <(list_ports)

while true; do
  while read -r n; do
    if [ -z "${seen[$n]:-}" ]; then
      seen[$n]=1
      v=$(cat "$DEVDIR/$n/idVendor"  2>/dev/null)
      p=$(cat "$DEVDIR/$n/idProduct" 2>/dev/null)
      s=$(cat "$DEVDIR/$n/speed"     2>/dev/null)
      bus=${n%%-*}; port=${n#*-}; port=${port%%.*}
      proto=USB2; [ "$bus" = "2" ] && proto=USB3
      printf "[%s]  bus %s  port %-2s  %-4s  %s:%s  %s Mbps\n" \
             "$(date +%T)" "$bus" "$port" "$proto" "${v:-----}" "${p:-----}" "${s:-?}"
    fi
  done < <(list_ports)
  for n in "${!seen[@]}"; do [ -e "$DEVDIR/$n" ] || unset "seen[$n]"; done
  sleep 0.4
done
