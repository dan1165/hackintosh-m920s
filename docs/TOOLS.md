# Tools Used

Every tool that was used to detect the hardware, build the EFI, validate it, and (optionally)
push this repo. All are free/open-source or standard.

## Building the EFI (what I ran on the Proxmox host)
| Tool | Version | Used for | Link |
|---|---|---|---|
| **OpenCorePkg** | 1.0.8 | The bootloader itself + sample ACPI/config + utilities below | github.com/acidanthera/OpenCorePkg |
| **ocvalidate** | 1.0.8 (`.linux`) | Validate `config.plist` (no issues) | bundled in OpenCorePkg |
| **macserial** | 1.0.8 (`.linux`) | Generate valid `iMac19,1` serial + MLB | bundled in OpenCorePkg |
| **macrecovery** | 1.0.8 | Download the Sonoma recovery image | bundled in OpenCorePkg |
| **acpica-tools (`iasl`)** | 2025-04-04 | Disassemble DSDT and compile SSDTs | acpica.org |
| `lscpu`, `lspci`, `lsusb`, `lsblk`, `dmidecode` | — | Hardware detection | util-linux/pciutils/usbutils/dmidecode |
| **`msr-tools` (`rdmsr`)** | 1.3 | Read `MSR 0xE2` to detect **CFG Lock** | kernel.org |
| `usb_modeswitch` | 2.x | Flip the test Wi-Fi dongle out of ZeroCD mode to identify it | draisberghof.de |

## Kexts / drivers (from their GitHub releases)
Lilu, VirtualSMC, WhateverGreen, AppleALC, IntelMausi, NVMeFix, RestrictEvents, CPUFriend
(all **acidanthera**) and **USBToolBox** (USBToolBox project). Versions in
[`VERSIONS.md`](VERSIONS.md).

## You use these on the target machine
| Tool | Platform | Purpose |
|---|---|---|
| **USBToolBox** | Windows/macOS | Build `UTBMap.kext` (USB port map) — see `POST-INSTALL.md` §4 |
| **ResourceConverter.sh** | macOS | Build `CPUFriendDataProvider.kext` (optional) |
| **ProperTree** or **OCAuxiliaryTools** | macOS/Windows | Friendly `config.plist` editor |
| **gibMacOS** | Windows/Linux/macOS | Alternative way to download macOS installers |
| **Disk Utility** | macOS (installer) | Erase the target disk to APFS |
| **Hackintool / Stats / HWMonitorSMC2** | macOS | Inspect USB, sensors, audio |

## Development / repo
| Tool | Used for |
|---|---|
| `git` | Version control + push to GitHub |
| `python3` (`plistlib`) | Generate the tailored `config.plist` |
| `zip` | Package the `…-OC1.0.8.zip` release |
| GitHub Actions | CI that runs `ocvalidate` on every push (`.github/workflows/validate.yml`) |

## Credits
All third-party projects are the work of their authors — see [`CREDITS.md`](CREDITS.md).
