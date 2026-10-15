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
| **Target machine** | Lenovo ThinkCentre M920s, Q370, i7-9700, UHD 630 |
| **macOS** | Sonoma 14.x |
| **Bootloader** | OpenCore **1.0.8** (`ocvalidate` clean) |
| **SMBIOS** | `iMac19,1` (fallback: `Macmini8,1`) |
| **Config validated** | ✅ no issues |

### What works
✅ Graphics (UHD 630, Metal + video encode) · ✅ Audio (ALC233) · ✅ Ethernet (I219-LM)
✅ NVMe (WD SN730) · ✅ USB 2 **and USB 3** (hardware-verified port map) · ✅ Sleep/wake
✅ CPU power management · ✅ iMessage/FaceTime*

### What needs a step (documented)
⚠️ Audio layout-id trial (some boards prefer a different ALC233 layout)

### What won't work
❌ Wi-Fi/Bluetooth/AirDrop (no supported card — **Ethernet-only**; no USB Wi-Fi 6 dongle has a macOS driver) · ❌ Rear VGA (analog) · ❌ DRM/Apple TV (iGPU-only)

<sub>*The SMBIOS identity shipped in this repo (serial/MLB/UUID/ROM) is a **reference example**
for the target model — **regenerate your own** before signing in to Apple services; see
[MAINTENANCE](docs/MAINTENANCE.md) and [SECURITY-PRIVACY](docs/SECURITY-PRIVACY.md).</sub>

---

## Quick start

```text
0. Verify the machine + EFI:  ./PreInstall/preflight.sh --all
1. Build the USB:  ./PreInstall/stage-installer.sh
2. BIOS: Secure Boot OFF, CSM OFF, iGPU primary, AHCI (docs/BIOS.md)
3. Boot the USB, erase the disk, install                  (docs/INSTALL.md)
4. Copy the EFI to the internal disk                      (docs/INSTALL.md §6)
```

Full step-by-step: **[`docs/QUICKSTART.md`](docs/QUICKSTART.md)** (short) ·
**[`docs/INSTALL.md`](docs/INSTALL.md)** (detailed).

> ⚠️ The install **erases the internal disk** (the existing OS included). Back up first.

---

## Documentation

| Guide | What's inside |
|---|---|
| **[docs/README.md](docs/README.md)** | **full documentation index** |
| [QUICKSTART](docs/QUICKSTART.md) | 10-minute overview / TL;DR |
| [PRE-INSTALL-CHECKLIST](docs/PRE-INSTALL-CHECKLIST.md) | Tick-list before you install |
| [INSTALL](docs/INSTALL.md) | Detailed install, USB creation, post-boot setup |
| [BIOS](docs/BIOS.md) | Every BIOS setting, with the reason |
| [HARDWARE](docs/HARDWARE.md) | Full detected specs + how they were detected |
| [COMPATIBILITY](docs/COMPATIBILITY.md) | Device → driver matrix for every PCI/USB device |
| [CPU-POWER](docs/CPU-POWER.md) · [GRAPHICS](docs/GRAPHICS.md) · [AUDIO](docs/AUDIO.md) | Per-subsystem deep-dives |
| [STORAGE](docs/STORAGE.md) · [NETWORK](docs/NETWORK.md) · [POWER-SLEEP](docs/POWER-SLEEP.md) | Storage, networking, power |
| [SECURE-BOOT](docs/SECURE-BOOT.md) · [MULTIBOOT](docs/MULTIBOOT.md) | Security settings · multi-OS |
| [FIRST-BOOT](docs/FIRST-BOOT.md) · [DIAGNOSTICS](docs/DIAGNOSTICS.md) · [PERFORMANCE](docs/PERFORMANCE.md) | After install · debugging · tuning |
| [FIRMWARE-ANALYSIS](docs/FIRMWARE-ANALYSIS.md) | Raw DSDT facts, verified SSDT paths & rename patches |
| [ACPI](docs/ACPI.md) | Every SSDT and the DSDT facts behind it |
| [KEXTS](docs/KEXTS.md) | Every kext: what it does, why, source |
| [USB-MAP](docs/USB-MAP.md) | The hardware-verified USB port map |
| [POST-INSTALL](docs/POST-INSTALL.md) | Audio, USB map, iMessage, power, updates |
| [MAINTENANCE](docs/MAINTENANCE.md) | Updating OpenCore/kexts/macOS safely |
| [RECOVERY](docs/RECOVERY.md) | Roll back a bad boot |
| [BOOT-PROCESS](docs/BOOT-PROCESS.md) | The full boot chain, stage by stage |
| [TROUBLESHOOTING](docs/TROUBLESHOOTING.md) | Symptom → fix table |
| [KNOWN-ISSUES](docs/KNOWN-ISSUES.md) | What won't work + workarounds |
| [FAQ](docs/FAQ.md) | Common questions |
| [GLOSSARY](docs/GLOSSARY.md) | Hackintosh terms in plain language |
| [UPGRADES](docs/UPGRADES.md) | Wi-Fi, dGPU, RAM, storage |
| [OPTIONAL-COMPONENTS](docs/OPTIONAL-COMPONENTS.md) | Extra kexts/drivers/tools/fixes, when to add |
| [VERSIONS](docs/VERSIONS.md) | Bill of materials (all versions) |
| [CREDITS](docs/CREDITS.md) | Upstream projects & licenses |
| [REFERENCES](docs/REFERENCES.md) | Specs & authoritative links |
| [VERIFICATION](docs/VERIFICATION.md) | What was verified, how, with what result |
| [DECISIONS](docs/DECISIONS.md) | Design decisions (ADR-style) |
| [SECURITY-PRIVACY](docs/SECURITY-PRIVACY.md) | SMBIOS/MAC handling + secret hygiene |
| [TOOLS](docs/TOOLS.md) | Every tool used to build/validate this |
| [SCRIPTS](docs/SCRIPTS.md) | Every script, its purpose and usage |
| [RELIABILITY-AUDIT](RELIABILITY-AUDIT.md) | Firmware-level pre-flight verification |
| [CHANGELOG](CHANGELOG.md) | History |

Project policies: [CONTRIBUTING](CONTRIBUTING.md) · [SECURITY](SECURITY.md) ·
[SUPPORT](SUPPORT.md) · [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md).

---

## Repository layout

```
EFI/
  BOOT/BOOTx64.efi            OpenCore bootstrap
  OC/
    config.plist             tailored OpenCore 1.0.8 config
    ACPI/                    SSDT-AWAC, EC-USBX, PLUG, PMC, SBUS-MCHC (+RHUB)
    Kexts/                   Lilu, VirtualSMC(+plugins), WhateverGreen, AppleALC,
                             IntelMausi, NVMeFix, RestrictEvents, USBPorts
                             (+CPUFriend, USBToolBox — disabled)
    Drivers/                 OpenRuntime, OpenHfsPlus, OpenCanopy, AudioDxe, ResetNvramEntry
    Tools/                   OpenShell, ResetSystem, ControlMsrE2, RtcRw
PreInstall/                  pre-install checks + installer staging scripts
PostInstall/                 macserial, ocvalidate, macrecovery, USBToolBox, CPUFriend tools
scripts/                     repo maintenance (markdown link check)
docs/                        all guides
Makefile                     make check / verify / validate / stage / docs / lint / release
.github/                     CI workflows, issue forms, PR template, CODEOWNERS
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
