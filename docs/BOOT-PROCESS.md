# Boot process

How this machine goes from power button to macOS login, and where OpenCore fits in.

## The chain
```
UEFI firmware (Lenovo M1UKT79A)
        │  reads NVRAM boot order
        ▼
EFI/BOOT/BOOTx64.efi            ← OpenCore bootstrap
        │
        ▼
EFI/OC/OpenCore.efi             ← OpenCore core
        │
        ├── Drivers (OpenRuntime, OpenHfsPlus, OpenCanopy, AudioDxe, ResetNvramEntry, HiiDatabase)
        ├── ACPI  (SSDT-AWAC, EC-USBX, PLUG, PMC, SBUS-MCHC)  → patched DSDT namespace
        ├── Kernel (Lilu, VirtualSMC(+plugins), WhateverGreen, AppleALC,
        │           IntelMausi, NVMeFix, RestrictEvents, USBPorts)  → injected, ordered
        ├── NVRAM (boot-args, csr-active-config, prev-lang:kbd)
        └── PlatformInfo (SMBIOS iMac19,1 — serial/MLB/UUID/ROM)
        │
        ▼
mach_kernel (from macOS on the NVMe)  → XCPM (SSDT-PLUG), kexts load
        │
        ▼
launchd → WindowServer → login
```

## What each stage does for **this** machine
| Stage | Machine-specific detail |
|---|---|
| ACPI injection | `SSDT-AWAC` flips `STAS=1` so macOS uses the legacy **RTC** (not AWAC). `SSDT-PMC` restores **NVRAM** (Q370 has no PMC device). |
| Kernel injection | `Lilu` first (root patcher); `VirtualSMC` before its plugins; `USBPorts` merges the port map onto `AppleUSBXHCIPCI`. |
| DeviceProperties | `PciRoot(0x0)/Pci(0x2,0x0)` sets the iGPU framebuffer (`0x3E9B0007` + stolenmem). |
| Quirks | `AppleXcpmCfgLock=true` (CFG Lock verified locked), `DisableIoMapper=true` (DMAR present). |
| PlatformInfo | SMBIOS `iMac19,1` so macOS's CPU/GPU matching lines up with the i7-9700 + UHD 630. |

## OpenCore picker → macOS
- The picker (OpenCanopy) lists boot entries. **NVRAM reset** is available as a picker entry
  (`ResetNvramEntry.efi`).
- Default boot entry + timeout are set in `Misc → Boot`.
- Verbose (`-v`) is enabled in `boot-args` for first boots; remove it for a silent boot.

## Where to look when it stops
| Symptom | Likely stage |
|---|---|
| No picker at all | firmware (Secure Boot/CSM) or `BOOTx64.efi` |
| Picker but macOS entry missing | storage driver / `OpenHfsPlus` / NVRAM boot entry |
| `OC: ... not found` on screen | a referenced kext/ACPI file is missing (re-check `config.plist`) |
| Kernel panic / instant reboot | ACPI or kext issue — try `-v keepsyms=1`, check `SSDT-*` |
| Boots but no GPU/audio/net | a kext didn't load (`kextstat`), or a DeviceProperties/ACPI path is wrong |

Troubleshooting detail: [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md). Emergency rollback:
[`RECOVERY.md`](RECOVERY.md).
