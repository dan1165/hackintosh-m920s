# Diagnostics & logging

How to gather evidence when something misbehaves — on the pre-install host and on macOS.

## Pre-install (Linux)
```bash
# full hardware + firmware snapshot
./PreInstall/preflight.sh --all
lspci -nn; lsusb; lsusb -t
dmidecode -t 0,1,2,16,17
cat /sys/class/dmi/id/*            # model, BIOS, board
sudo cp /sys/firmware/acpi/tables/* /tmp/acpi/ && iasl -d -p /tmp/DSDT.dsl /tmp/acpi/DSDT
sudo cat /sys/kernel/debug/usb/xhci/*/reg-ext-protocol:00 /sys/kernel/debug/usb/xhci/*/reg-ext-protocol:01
```
See [`FIRMWARE-ANALYSIS.md`](FIRMWARE-ANALYSIS.md) and [`VERIFICATION.md`](VERIFICATION.md).

## macOS — boot issues
| Need | How |
|---|---|
| Verbose boot | add `-v keepsyms=1` to `boot-args` (already default here) |
| Keep the panic on screen | `debug=0x100` (disables the watchdog) |
| Screenshot the picker | `CrScreenshotDxe.efi` → press **F10** (saved to the ESP) |
| Text-only UI | `Misc → Output → ConsoleMode`, or boot `-v` |
| Memory-map issues (`DevirtualiseMmio`) | picker → `MmapDump.efi` |
| OpenCore log file | `Misc → Debug → Target = 67` (file+serial) → `EFI/OC/opencore-*.txt` |

## macOS — runtime
```bash
kextstat | grep -v com.apple            # third-party kexts loaded
kmutil showloaded                       # modern equivalent
ioreg -l -p IODeviceTree | head         # device tree
ioreg -l | grep -i ig-platform-id       # iGPU
log show --last 5m --predicate 'process == "kernel"' | tail -60
pmset -g log
system_profiler SPHardwareDataType SPUSBDataType SPDisplaysDataType SPAudioDataType
```

## Doctor one-liners
```bash
# is the audio codec alive?
system_profiler SPAudioDataType | grep -i alc
# is the SMBus device present?
kextstat | grep -i AppleSMBus
# sensors
# (install Stats / HWMonitorSMC2 for a GUI)
```

## What to attach to a bug report
`./PreInstall/ocvalidate.linux EFI/OC/config.plist`, a photo of the `-v` screen, and the outputs
above. Template: [`.github/ISSUE_TEMPLATE/bug_report.yml`](../.github/ISSUE_TEMPLATE/bug_report.yml).
