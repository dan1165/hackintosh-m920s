# Compatibility matrix (device → driver)

Every device on this exact machine and what macOS uses to drive it. `lspci`/`lsusb` IDs are as
reported by the hardware. "Status" reflects macOS **Sonoma 14.x** with this EFI.

## PCI devices
| # | Device | ID | macOS driver / mechanism | Status |
|---|--------|----|--------------------------|--------|
| 00:00.0 | Coffee Lake-S Host Bridge | `8086:3E30` | native (platform) | ✅ |
| 00:02.0 | **UHD Graphics 630** | `8086:3E98` | WhateverGreen + `AAPL,ig-platform-id 0x3E9B0007` | ✅ Metal |
| 00:08.0 | Gaussian Mixture Model | `8086:1911` | not required by macOS | ✅ |
| 00:14.0 | **Cannon Lake xHCI** | `8086:A36D` | native `AppleUSBXHCIPCI` + `USBPorts.kext` | ✅ (see USB-MAP) |
| 00:14.2 | Shared SRAM | `8086:A36F` | not required | ✅ |
| 00:16.0 | HECI / MEI | `8086:A360` | not required by macOS | ✅ |
| 00:16.3 | KT Redirection (serial) | `8086:A363` | not required | ✅ |
| 00:17.0 | **SATA AHCI** | `8086:A352` | native `AppleAHCIPort` / `IOAHCIFamily` | ✅ |
| 00:1B.0 | PCIe Root Port #21 | `8086:A32C` | native `IOPP` | ✅ |
| 00:1F.0 | Q370 LPC/eSPI | `8086:A306` | native + `SSDT-PMC` | ✅ |
| 00:1F.3 | **HD Audio (Realtek ALC233)** | `8086:A348` | AppleALC, `alcid=3` | ✅ |
| 00:1F.4 | **SMBus** | `8086:A323` | native AppleSMBus + `SSDT-SBUS-MCHC` | ✅ |
| 00:1F.5 | SPI Flash | `8086:A324` | not required | ✅ |
| 00:1F.6 | **Intel I219-LM Ethernet** | `8086:15BB` | IntelMausi | ✅ |
| 01:00.0 | **WD SN730 NVMe** | `15B7:5006` | native NVMe + NVMeFix | ✅ |

## USB devices / classes
| Device | ID | macOS |
|---|---|---|
| xHCI root hubs (USB2 ×16, USB3 ×10) | — | native (`USBPorts.kext` maps the wired set) |
| USB HID (keyboard/mouse/receivers) | any | native `IOHIDFamily` |
| USB mass storage | any | native |
| **Realtek 802.11ax USB Wi-Fi/BT** | `3625:010B` | ❌ no macOS driver (see UPGRADES) |

## Kexts
| Kext | Role |
|---|---|
| Lilu | root patcher (dependency) |
| VirtualSMC (+SMCProcessor/SMCSuperIO) | SMC emulation + sensors |
| WhateverGreen | Intel iGPU framebuffer |
| AppleALC | HD Audio (ALC233) |
| IntelMausi | I219-LM Ethernet |
| NVMeFix | NVMe power management |
| RestrictEvents | CPU naming / update hygiene |
| USBPorts | xHCI port map |
| CPUFriend _(disabled)_ | custom CPU power profile |
| USBToolBox _(disabled)_ | alternate USB map injector |

## ACPI tables injected
`SSDT-AWAC`, `SSDT-EC-USBX`, `SSDT-PLUG`, `SSDT-PMC`, `SSDT-SBUS-MCHC`
(+ `SSDT-RHUB`, disabled). Every path verified against the DSDT — see
[FIRMWARE-ANALYSIS](FIRMWARE-ANALYSIS.md).

## What does **not** work (by design)
| Feature | Reason |
|---|---|
| Wi-Fi / Bluetooth / AirDrop / Handoff | no supported card installed (Ethernet-only) |
| Rear **VGA** | analog output, macOS has no driver |
| DRM (Apple TV, Netflix in Safari) | iGPU-only, no supported dGPU |
| USB 3 on `SS10` | trimmed to stay within the 15-port cap (falls back to USB2) |
