# First boot

What to do the very first time macOS boots on this machine. Keep the install USB plugged in.
Full list: [`POST-INSTALL.md`](POST-INSTALL.md).

## 1. Confirm it booted cleanly
- Boot with `-v keepsyms=1` (already default) and watch for errors.
- You should reach Setup Assistant, then the desktop.

## 2. Get these working before anything else
| Order | Check | Command / action |
|---|---|---|
| 1 | **Graphics** | `system_profiler SPDisplaysDataType` → UHD 630 + Metal |
| 2 | **Ethernet** | plug in; `ifconfig en0` shows a MAC (gives you network/updates) |
| 3 | **Audio** | try the jacks; if silent, walk `alcid` (see [`AUDIO.md`](AUDIO.md)) |
| 4 | **USB** | plug a stick into every port (the shipped map should give full speed) |
| 5 | **Sleep** | sleep and wake once (see [`POWER-SLEEP.md`](POWER-SLEEP.md)) |

## 3. Move the EFI to the internal disk
Once it's stable, copy `EFI/` to the internal disk's EFI partition so it boots **without** the USB
(see [`INSTALL.md`](INSTALL.md) §6). Keep the USB as your rescue disk.

## 4. Identity & services (optional)
- Sign in to the App Store / iMessage. If it fails, see
  [`SECURITY-PRIVACY.md`](SECURITY-PRIVACY.md) and regenerate the SMBIOS.
- Set the clock/timezone; confirm the RTC is stable (see [`POWER-SLEEP.md`](POWER-SLEEP.md)).

## 5. First-boot sanity script
```bash
kextstat | grep -E "Lilu|VirtualSMC|WhateverGreen|AppleALC|IntelMausi|NVMeFix|USBPorts"
kextstat | grep -E "AppleSMBusController|AppleSMBusPCI"
sysctl machdep.xcpm.mode            # -> 1
```

## 6. Then
- Read [`MAINTENANCE.md`](MAINTENANCE.md) before applying any macOS/OpenCore update.
- Keep a known-good EFI on a USB ([`RECOVERY.md`](RECOVERY.md)).
- Optional polish: [`OPTIONAL-COMPONENTS.md`](OPTIONAL-COMPONENTS.md), [`UPGRADES.md`](UPGRADES.md).
