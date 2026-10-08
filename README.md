# ThinkCentre M920s — Hackintosh

![OpenCore](https://img.shields.io/badge/OpenCore-1.0.8-blue)
![macOS](https://img.shields.io/badge/macOS-Sonoma%2014-green)
![Platform](https://img.shields.io/badge/platform-ThinkCentre%20M920s-informational)
![License](https://img.shields.io/badge/license-MIT-brightgreen)
![ocvalidate](https://img.shields.io/badge/ocvalidate-passing-success)

A complete, **machine-specific** OpenCore EFI + documentation for running **macOS Sonoma**
on a **Lenovo ThinkCentre M920s** (Core i7-9700 / Q370 / UHD 630 / ALC233 / I219-LM).

Built by reading this exact machine's **firmware, PCI, USB and ACPI** — not from a generic
template. New here? Start with **[`docs/QUICKSTART.md`](docs/QUICKSTART.md)** and
**[`docs/GLOSSARY.md`](docs/GLOSSARY.md)**.

---

## At a glance

| | |
|---|---|
| **Target machine** | Lenovo ThinkCentre M920s (10SKS5KF00), Q370, i7-9700, UHD 630 |
| **macOS** | Sonoma 14.x |
| **Bootloader** | OpenCore **1.0.8** (`ocvalidate` clean) |
| **SMBIOS** | `iMac19,1` (fallback: `Macmini8,1`) |
| **Config validated** | ✅ no issues |

### What works
✅ Graphics (UHD 630, Metal + video encode) · ✅ Audio (ALC233) · ✅ Ethernet (I219-LM)
✅ NVMe (WD SN730) · ✅ USB 2 · ✅ Sleep/wake · ✅ CPU power management · ✅ iMessage/FaceTime*

### What needs a step (documented)
⚠️ USB 3 speeds (on-device port map) · ⚠️ Audio layout-id trial

### What won't work
❌ Wi-Fi/Bluetooth/AirDrop (no supported card — **Ethernet-only**; a tested USB dongle was
rejected) · ❌ Rear VGA (analog) · ❌ DRM/Apple TV (iGPU-only)

<sub>*iMessage depends on Apple-side serial validation; a valid serial is provided.</sub>

---

## Quick start

```text
1. Flash a USB with the Sonoma recovery + this EFI   (docs/INSTALL.md §1)
2. BIOS: Secure Boot OFF, CSM OFF, iGPU primary, AHCI (docs/BIOS.md)
3. Boot the USB, erase the disk, install Sonoma       (docs/INSTALL.md)
4. Copy the EFI to the internal disk                  (docs/INSTALL.md §6)
```

Full step-by-step: **[`docs/QUICKSTART.md`](docs/QUICKSTART.md)** (short) ·
**[`docs/INSTALL.md`](docs/INSTALL.md)** (detailed).

> ⚠️ The install **erases the internal disk** (Proxmox included). Back up first.

---

## Documentation

| Guide | What's inside |
|---|---|
| [QUICKSTART](docs/QUICKSTART.md) | 10-minute overview / TL;DR |
| [INSTALL](docs/INSTALL.md) | Detailed install, USB creation, post-boot setup |
| [BIOS](docs/BIOS.md) | Every BIOS setting, with the reason |
| [HARDWARE](docs/HARDWARE.md) | Full detected specs + how they were detected |
| [POST-INSTALL](docs/POST-INSTALL.md) | Audio, USB map, iMessage, power, updates |
| [KEXTS](docs/KEXTS.md) | Every kext: what it does, why, source |
| [ACPI](docs/ACPI.md) | Every SSDT and the DSDT facts behind it |
| [TOOLS](docs/TOOLS.md) | Every tool used to build/validate this |
| [TROUBLESHOOTING](docs/TROUBLESHOOTING.md) | Symptom → fix table |
| [FAQ](docs/FAQ.md) | Common questions |
| [GLOSSARY](docs/GLOSSARY.md) | Hackintosh terms in plain language |
| [UPGRADES](docs/UPGRADES.md) | Wi-Fi, dGPU, RAM, storage |
| [VERSIONS](docs/VERSIONS.md) | Bill of materials (all versions) |
| [CREDITS](docs/CREDITS.md) | Upstream projects & licenses |
| [RELIABILITY-AUDIT](RELIABILITY-AUDIT.md) | Firmware-level pre-flight verification |
| [CHANGELOG](CHANGELOG.md) | History |

---

## Repository layout

```
EFI/
  BOOT/BOOTx64.efi            OpenCore bootstrap
  OC/
    config.plist             tailored OpenCore 1.0.8 config
    ACPI/                    SSDT-AWAC, EC-USBX, PLUG, PMC, SBUS-MCHC (+RHUB)
    Kexts/                   Lilu, VirtualSMC(+plugins), WhateverGreen, AppleALC,
                             IntelMausi, NVMeFix, RestrictEvents (+CPUFriend, USBToolBox)
    Drivers/                 OpenRuntime, OpenHfsPlus, OpenCanopy, AudioDxe, ResetNvramEntry
    Tools/                   OpenShell, ResetSystem, ControlMsrE2, RtcRw
PostInstall/                 macserial, ocvalidate, macrecovery, USBToolBox, CPUFriend tools
docs/                        all guides
.github/workflows/           CI: runs ocvalidate on every push
ThinkCentre-M920s-Sonoma-OC1.0.8.zip   packaged release
```

## Validation
```bash
./PostInstall/ocvalidate.linux EFI/OC/config.plist
```
Also enforced automatically in CI on every push.

---

## Safety & legal
- Installing macOS on non-Apple hardware violates Apple's EULA — personal experimentation only.
- Back up your data; the install erases the target disk.
- Bundled third-party software keeps its own license (see [CREDITS](docs/CREDITS.md)); this
  repo's original content is **MIT** ([LICENSE](LICENSE)).
