# Optional components catalog

Everything you might add beyond the shipped build, **when to add it, and the risk**. The shipped
EFI stays intentionally lean (see [`DECISIONS.md`](DECISIONS.md) D8) so the default is reliable;
this page is the menu for the cases that need more.

> Rule: add one thing, `ocvalidate`, reboot. Keep the old USB.

## Kexts
| Kext | Add when… | Risk | Notes |
|---|---|---|---|
| `CPUFriend` + `CPUFriendDataProvider` | you want a custom CPU power profile | Low | Provider is generated with `PostInstall/ResourceConverter.sh` |
| `USBWakeFixup` | USB devices prevent sleep / cause wake loops | Low | Pairs with a device property |
| `RTCMemoryFixup` | clock drift or RTC-related panics | Low | Only if `SSDT-AWAC` alone isn't enough |
| `DebugEnhancer` | debugging a stubborn issue | Low | Verbose logging; remove after |
| `FeatureUnlock` | you need Sidecar/AirPlay on an older OS | Medium | Not needed on the target OS |
| `AppleMCEReporterDisabler` | you switch SMBIOS to `MacPro7,1` | Low | Prevents MCE panic on that model |
| `SMCBatteryManager` / `SMCLightSensor` | **laptops** | Low | N/A for this desktop |
| `IntelBluetoothFirmware` + `IntelBTPatcher` | you add an Intel Wi-Fi/BT card | Medium | Pair with `AirportItlwm` |
| `AirportItlwm` / `itlwm` | Intel Wi-Fi card installed | Medium | `AirportItlwm` = native UI; `itlwm` = own UI |
| `RealtekRTL8111` / `AtherosE2200Ethernet` | a different NIC is fitted | Low | Not needed — onboard is Intel |

## SSDTs / ACPI fixes
| Item | Add when… | Risk | Notes |
|---|---|---|---|
| `SSDT-HPET` + 5 renames | **every** audio layout fails | Medium | **Verified safe here**: each rename matches the DSDT exactly once — see [`FIRMWARE-ANALYSIS.md`](FIRMWARE-ANALYSIS.md) §3 |
| `SSDT-RHUB` | USB ports are missing at boot | Low | Shipped, **disabled** |
| `SSDT-UNC` | Skylake-X/HEDT only | — | N/A |
| `SSDT-DMAR` / `DMAR` patch | you must keep VT-d on **and** fix a bad DMAR | High | Usually unnecessary; `DisableIoMapper=true` is used instead |
| `SSDT-UIAC` | a hand-built USB map instead of `USBPorts.kext` | Low | See [`USB-MAP.md`](USB-MAP.md) |
| `AppleCpuPmCfgLock` | very old platforms | — | Not used; `AppleXcpmCfgLock` is correct here |

## OpenCore drivers (add to `UEFI → Drivers`)
| Driver | Add when… | Risk |
|---|---|---|
| `NvmExpressDxe.efi` | firmware lacks an NVMe driver (not here — Lenovo provides one) | Low |
| `OpenUsbKbDxe.efi` / `UsbMouseDxe.efi` | picker input broken on odd firmware | Low |
| `OpenNtfsDxe.efi` / `Ext4Dxe.efi` / `OpenLinuxBoot.efi` | you multi-boot Windows/Linux | Low |
| `FirmwareSettingsEntry.efi` | want a picker entry to enter BIOS | Low |
| `OpenVariableRuntimeDxe.efi` | firmware NVRAM is broken | Medium |
| `Ps2KeyboardDxe.efi` / `Ps2MouseDxe.efi` | PS/2-only input | Low |
| `HfsPlus.efi` (legacy) | HFS+ without OpenHfsPlus | Low |

## OpenCore tools (add to `Misc → Tools`)
**Shipped & enabled:** `OpenShell`, `ResetSystem`, `ControlMsrE2`, `RtcRw`, `CleanNvram`,
`CsrUtil`, `ListPartitions`, `MmapDump`, `KeyTester`.
**Included in `EFI/OC/Tools/` but not registered:** add if you want them on the picker:
`BootKicker`, `ChipTune`, `FontTester`, `GopStop`, `TpmInfo`, `OpenControl`.

## Boot-args (add to `NVRAM → boot-args`)
| Arg | Use |
|---|---|
| `-v keepsyms=1` | verbose + symbols (first boots, current default) |
| `-x` | safe mode |
| `npci=0x2000` | only if boot hangs at PCI (not needed here) |
| `alcid=N` | AppleALC layout override (current `3`) |
| `igfxfw=2` | force GuC firmware (rarely needed on CFL) |
| `-igfxvesa` | disable iGPU accel (diagnosis only) |
| `debug=0x100` | disable watchdog on panic (diagnosis) |

## Hardware upgrades
See [`UPGRADES.md`](UPGRADES.md) — Broadcom Wi-Fi (native), supported AMD dGPU (DRM), RAM, storage.
