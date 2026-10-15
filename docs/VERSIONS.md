# Versions (Bill of Materials)

Everything bundled in this repo, with versions. Config was validated with OpenCore **1.0.8**.

## Bootloader
| Component | Version |
|---|---|
| OpenCorePkg (RELEASE) | **1.0.8** |

## Kexts
| Kext | Version | Status |
|---|---|---|
| Lilu | 1.7.2 | enabled |
| VirtualSMC | 1.3.8 | enabled |
| SMCProcessor | 1.3.8 | enabled |
| SMCSuperIO | 1.3.8 | enabled |
| WhateverGreen | 1.7.1 | enabled |
| AppleALC | 1.9.8 | enabled |
| IntelMausi | 1.0.8 | enabled |
| NVMeFix | 1.1.3 | enabled |
| RestrictEvents | 1.1.6 | enabled |
| USBPorts | 1.0 (this repo) | enabled |
| CPUFriend | 1.3.0 | disabled |
| USBToolBox | 1.2.0 | disabled |

## Drivers
| Driver | Purpose |
|---|---|
| OpenRuntime.efi | Booter runtime (required) |
| OpenHfsPlus.efi | HFS+ reading |
| OpenCanopy.efi | GUI boot picker |
| AudioDxe.efi | Boot chime |
| ResetNvramEntry.efi | Picker NVRAM reset entry |
| HiiDatabase.efi | Firmware settings UI |
| ToggleSipEntry.efi | Picker SIP on/off entry |
| CrScreenshotDxe.efi | Picker screenshots (F10) |
| OpenPartitionDxe.efi | Partition services for arbitrary layouts |

## OpenCore tools (`EFI/OC/Tools/`, registered in `Misc → Tools`)
| Tool | Purpose |
|---|---|
| OpenShell.efi | UEFI shell |
| ResetSystem.efi | Reboot / shutdown |
| ControlMsrE2.efi | Read/clear CFG Lock (MSR 0xE2) |
| RtcRw.efi | Read/write CMOS RTC |
| CleanNvram.efi | Delete all NVRAM variables |
| CsrUtil.efi | Toggle SIP from the picker |
| ListPartitions.efi | List disks/partitions (diagnostic) |
| MmapDump.efi | Dump UEFI memory map (DevirtualiseMmio debug) |
| KeyTester.efi | Show key scancodes |

_Included but not registered (add to `Misc → Tools` if wanted): `BootKicker`, `ChipTune`,
`FontTester`, `GopStop`, `TpmInfo`, `OpenControl`._

## Tools (in `PostInstall/`)
| Tool | Version | Purpose |
|---|---|---|
| macserial (linux) | 1.0.8 | Generate SMBIOS serials |
| ocvalidate (linux) | 1.0.8 | Validate `config.plist` |
| macrecovery | 1.0.8 | Download macOS recovery |
| USBToolBox | 1.2.0 | Build USB port map |
| usb-port-report.sh | 1.0 (this repo) | Probe which USB ports are wired |
| ResourceConverter.sh | 1.3.0 | Build CPUFriend DataProvider |

## Target OS
| | |
|---|---|
| macOS | **Sonoma 14.x** |
| SMBIOS | iMac19,1 (fallback Macmini8,1) |

## Updating
1. Download the newer release from the upstream GitHub.
2. Replace files in `EFI/OC/` (kexts/drivers) and/or `OpenCore.efi` + `BOOTx64.efi`.
3. Keep `config.plist` compatible (check the OpenCore **Configuration.pdf** for changed keys).
4. Re-run `ocvalidate`.
