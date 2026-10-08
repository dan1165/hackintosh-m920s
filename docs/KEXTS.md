# Kexts (kernel extensions)

A kext is a driver/driver-patch macOS loads at boot. All are injected by OpenCore
from `EFI/OC/Kexts/` — nothing is installed into the system.

## Enabled (loaded every boot)
| Kext | Version | What it does | Source |
|---|---|---|---|
| **Lilu** | 1.7.2 | Core patching engine; required by the others | acidanthera |
| **VirtualSMC** | 1.3.8 | Emulates Apple's SMC chip | acidanthera |
| **SMCProcessor** | 1.3.8 | CPU temperature/voltage sensors | acidanthera |
| **SMCSuperIO** | 1.3.8 | SuperIO (fan/voltage) sensors | acidanthera |
| **WhateverGreen** | 1.7.1 | GPU fixes (framebuffer, connector, backlight) | acidanthera |
| **AppleALC** | 1.9.8 | Audio (Realtek ALC233) | acidanthera |
| **IntelMausi** | 1.0.8 | Intel I219-LM Ethernet | acidanthera |
| **NVMeFix** | 1.1.3 | NVMe power management / compatibility | acidanthera |
| **RestrictEvents** | 1.1.6 | Hides "Unsupported CPU/GPU" banners, cleans board-id | acidanthera |

## Bundled but disabled
| Kext | Version | What it's for | Why disabled |
|---|---|---|---|
| **CPUFriend** | 1.3.0 | Custom CPU power profiles | Native XCPM is already correct; needs a DataProvider |
| **USBToolBox** | 1.2.0 | Injects a `UTBMap.kext` USB port map | Enable together with a generated `UTBMap.kext` (see POST-INSTALL §4) |

## Load order (matters)
Lilu **must** be first. Then VirtualSMC, then its plugins, then the rest:
```
Lilu → VirtualSMC → WhateverGreen → AppleALC → SMCProcessor → SMCSuperIO
     → IntelMausi → NVMeFix → RestrictEvents
```

## Adding a kext
1. Copy the `.kext` into `EFI/OC/Kexts/`.
2. Add an entry under `config.plist → Kernel → Add`:
   - `BundlePath` = `Name.kext`
   - `ExecutablePath` = `Contents/MacOS/Name` (empty for codeless/kernel-injector kexts)
   - `PlistPath` = `Contents/Info.plist`
   - `Enabled` = true
3. Put Lilu-dependent kexts **after** Lilu.
4. Re-run `ocvalidate`.

## Notes
- Do **not** rename `H_EC` to `EC` on this desktop — the firmware EC is already hidden and
  `AppleACPIEC` must not bind. The fake `EC` (`ACID0001`) in `SSDT-EC-USBX` is what macOS sees.
- Keep kexts updated from the official acidanthera GitHub releases (only the `RELEASE.zip`).
