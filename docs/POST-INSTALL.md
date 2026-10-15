# Post-Install

Once Sonoma is installed and booting from the internal disk, do these in order.
Validate the config after **every** edit:

```bash
./PostInstall/ocvalidate.linux EFI/OC/config.plist
```

---

## 1. Reset NVRAM once
OpenCore picker → press **Space** → **Reset NVRAM**, then boot macOS.
(Or boot the **Tools → Reset Nvram** entry.) Do this after changing any setting below.

## 2. Remove verbose logging
Edit `config.plist → NVRAM → Add → 7C436110-… → boot-args` and drop `-v`:

```
keepsyms=1 alcid=3
```

## 3. Audio (Realtek ALC233)
Default layout is **3**. AppleALC's supported ALC233 layouts are:

`3, 4, 5, 13, 21, 27, 28, 29, 32, 33` *(11 is NOT valid for ALC233)*

Try, in order, by changing **one** of:
- `boot-args`: `alcid=N`, **or**
- `DeviceProperties → PciRoot(0x0)/Pci(0x1F,0x3) → layout-id` (hex: `03000000` = 3)

Order to try: `3 → 13 → 21 → 4 → 5 → 27 → 28 → 29 → 32 → 33`.
**Reset NVRAM between tries** (the old layout is cached).

If truly none work, the next step is an `SSDT-HPET` IRQ fix (see `TROUBLESHOOTING.md`).

## 4. USB 3 (port mapping) — ✅ already done
macOS exposes only the first 15 controller ports, so without a map the SuperSpeed ports run at
USB 2 speed. This repo **ships a hardware-verified map** (`EFI/OC/Kexts/USBPorts.kext`, enabled
in `Kernel → Add`) built by probing this machine — see **[USB-MAP](USB-MAP.md)**.

To regenerate your own instead (optional):
1. Boot macOS (USB 2 works everywhere).
2. Run **USBToolBox** (`PostInstall/USBToolBox-1.2.0-RELEASE.zip`) on Windows or macOS.
3. Plug a device into **every** port, then **K → Build UTBMap.kext**.
4. Copy `UTBMap.kext` into `EFI/OC/Kexts/`, then enable `USBToolBox.kext` + `UTBMap.kext`
   (USBToolBox first) and **disable** `USBPorts.kext`.
5. Keep `UEFI → Quirks → XhciPortLimit = false`.

## 5. iMessage / FaceTime / App Store
The SMBIOS is a valid `iMac19,1` with a consistent serial/MLB/ROM (see §SMBIOS below).
1. Sign in with your Apple ID in **System Settings**.
2. If it fails: Reset NVRAM once and retry. Make sure Ethernet is connected during sign-in.
3. Do not change serial/MLB/UUID/ROM after services work.

## 6. CPU power management (optional)
Native XCPM is already active. To install a custom frequency profile:
```bash
./PostInstall/ResourceConverter.sh --kext /path/to/iMac19_1.plist
# produces CPUFriendDataProvider.kext; add it to Kexts/ and enable CPUFriend.kext
```

## 7. Sensors
`SMCProcessor` and `SMCSuperIO` are already loaded. Install a tool (e.g. Stats, HWMonitorSMC2)
to view CPU/SuperIO sensors.

## 8. Security updates
Minor macOS updates are usually safe. **Before any update:**
1. Back up.
2. Make sure your USB installer still boots (rescue).
3. Update OpenCore/kexts to the latest releases first, re-validate, then update macOS.

## 9. Turn off verbose on the picker (cosmetic)
`Misc → Debug → Target = 3` is fine; set to `0` for a silent boot.

---

## SMBIOS reference (already set)
| Field | Value |
|---|---|
| SystemProductName | `iMac19,1` |
| SystemSerialNumber | `C02C80E9JV3Q` |
| MLB | `C020077004NLNV91F` |
| SystemUUID | `5A9F2C7E-3B14-4D6A-9C8E-1F2A3B4C5D6E` |
| ROM | `6C:4B:90:CE:BA:90` (onboard MAC) |

**iGPU-only fallback:** `Macmini8,1` serial `C07LPYZ4JYVX`, MLB `C07346902GUKXPGJA`
(same UUID/ROM). Use this only if iMac19,1 shows graphics/power oddities.
