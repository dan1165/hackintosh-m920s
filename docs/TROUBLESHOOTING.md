# Troubleshooting

General method: **boot verbose** (`-v` is already on), watch the **last line** on screen,
then match it below. For hard cases, capture a log (see "Capturing logs" at the bottom).

## Boot / picker
| Symptom | Likely cause | Fix |
|---|---|---|
| USB not in boot menu | Wrong partition type | Partition must be **EF00 (EFI System)** and contain `EFI/BOOT/BOOTx64.efi` |
| Picker shows no macOS entry | Recovery folder missing | `com.apple.recovery.boot/BaseSystem.dmg` + `.chunklist` must be at USB root |
| Stuck at `OCB: StartImage failed` | Bad/corrupt OpenCore files | Re-copy `EFI/` from this repo; re-run `ocvalidate` |
| Black screen right after picker | iGPU framebuffer | Try `AAPL,ig-platform-id = 00009B3E`; verify Pre-Allocated Memory = 64 MB |

## Early kernel boot
| Symptom | Likely cause | Fix |
|---|---|---|
| `EXITBS:START` hang | Memory map / MMIO | Keep `ProtectUefiServices=true`; toggle `Booter → Quirks → DevirtualiseMmio`; try `npci=0x2000` |
| Instant reboot | CPU CFG Lock | `AppleXcpmCfgLock=true` (already set — don't disable) |
| `Still waiting for root device` | Storage/USB | Confirm **AHCI**, reseat the USB, try another port (USB 2) |
| `ACPI Error … _STA` / duplicate | Conflicting SSDT | Only one of `SSDT-AWAC` / RTC patch; validate with `ocvalidate` |
| `nvme` timeout | NVMe ASPM | `NVMeFix` is included; disable ASPM in BIOS if needed |

## Graphics
| Symptom | Fix |
|---|---|
| Black screen after `-v` | `AAPL,ig-platform-id` → `00009B3E`; keep `framebuffer-patch-enable` + `framebuffer-stolenmem` |
| Only 7 MB VRAM | Wrong framebuffer / DVMT. Set iGPU memory 64 MB; try `00009B3E` |
| No hardware video encode | Verify `AAPL,ig-platform-id=07009B3E`, WhateverGreen loaded |

## Audio
| Symptom | Fix |
|---|---|
| No output | Walk ALC233 layouts: `3 → 13 → 21 → 4 → 5 → 27 → 28 → 29 → 32 → 33`, resetting NVRAM each time |
| Only some jacks work | Different layout (mic/line-out mapping differs per layout) |
| Nothing works at all | Add `SSDT-HPET` + DSDT IRQ renames (last resort) |
| No HDMI/DP audio | Separate issue; usually HDEF layout-related |

## USB
| Symptom | Fix |
|---|---|
| USB 3 slow (USB 2 speed) | Expected until you build `UTBMap.kext` (`POST-INSTALL §4`) |
| Ports missing | Enable `SSDT-RHUB`; then re-map |
| Devices drop on sleep | Build the port map; map internal ports correctly |

## Sleep / wake
| Symptom | Fix |
|---|---|
| Won't sleep | USB map; check `pmset -g assertions`; disable "Wake for network" |
| Wakes immediately | Unplug the offending USB device / map it as internal |
| Kernel panic on wake | Try `No-hda-gfx` on the audio device (loses HDMI audio) |

## iMessage / FaceTime
| Symptom | Fix |
|---|---|
| "An error occurred during activation" | Reset NVRAM, ensure networked during sign-in, retry |
| Still failing | The serial must be a valid `iMac19,1`; regenerate with `macserial` and keep MLB/UUID/ROM consistent |

## Capturing logs
Set in `config.plist → Misc → Debug`:
```
Target = 67          # console + serial + file
DisplayLevel = 2147483653
```
Boot; the log is written to `EFI/OC/opencore-YYYY-MM-DD-*.txt`. Share that file if asking
for help.

## Golden rules
1. Change **one** thing at a time.
2. Reset NVRAM after changing `DeviceProperties`/`boot-args`.
3. Run `ocvalidate` after every edit.
4. Keep a working USB — it's your rescue disk.
