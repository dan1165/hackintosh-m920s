# USB port map (hardware-verified)

macOS exposes only the **first 15 ports** of an xHCI controller, so on this machine (26 ports)
the SuperSpeed ports would be trimmed unless we hand it an explicit map. This repo ships that
map as **`EFI/OC/Kexts/USBPorts.kext`** (enabled in `config.plist → Kernel → Add`), derived by
probing **this exact machine**, not guessed.

## Hardware port numbering (from the xHCI registers)
The controller's *Supported Protocol* extended capabilities report:

| Protocol | Port offset | Port count | macOS names | `port` value |
|---|---|---|---|---|
| USB 2.0 | 1 | 16 | `HS01`…`HS16` | 1–16 |
| USB 3.0 | 17 | 10 | `SS01`…`SS10` | 17–26 |

This 1:1 matches the firmware's own `_ADR` values in the DSDT (`HS01`…`HS14` = 1–14,
`USR1/USR2` = 15/16, `SS01`…`SS10` = 17–26), so a reading of `bus 2 port N` on Linux maps
straight to macOS `SS0N` = `port 16+N`.

## The map

| macOS port | `port` | Connector | Evidence it is wired |
|---|---|---|---|
| `HS01`–`HS04` | 1–4 | USB3 Type-A | USB2 companions of `SS01`–`SS04` |
| `HS06` | 6 | USB2 Type-A | Logitech receiver observed on `bus 1 port 6` |
| `HS07` | 7 | USB2 Type-A | Realtek Wi-Fi dongle observed on `bus 1 port 7` |
| `HS08`–`HS10` | 8–10 | USB3 Type-A | devices + `SS` companions |
| `SS01`–`SS04` | 17–20 | USB3 Type-A | USB3 stick plugged into 4 ports |
| `SS08`–`SS09` | 24–25 | USB3 Type-A | USB3 stick plugged into 3 more ports |

`port-count = 26`. Deliberately omitted: `HS05`, `HS11`–`HS14`, `USR1/USR2` (never observed)
and **`SS10`** (dropped to stay within the 15-port cap — that port falls back to USB 2).

## How it was derived
1. **xHCI registers** (`/sys/kernel/debug/usb/xhci/*/reg-ext-protocol:00|01`) → protocol/port ranges.
2. **Firmware DSDT** → the `XHC.RHUB` port devices and their `_ADR` values.
3. **Live plug test** → a USB3 stick was inserted into each physical port while a
   sysfs watcher logged `bus N port M`; the observed ports are the wired ones.

## Regenerating / verifying
- A helper watcher lives at `docs/`-adjacent tooling if you need to re-probe:
  `PostInstall/usb-port-report.sh` (plug a device into each port, watch the output).
- Or use **USBToolBox** (`PostInstall/USBToolBox-1.2.0-RELEASE.zip`): boot macOS, map, build
  `UTBMap.kext`, then enable `USBToolBox.kext` + `UTBMap.kext` and **disable** `USBPorts.kext`.
- Keep `UEFI → Quirks → XhciPortLimit = false` (the old 15-port-limit patch is unsafe on
  Big Sur and later).
- After any change: `./PostInstall/ocvalidate.linux EFI/OC/config.plist`.
