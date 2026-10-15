# Glossary

Plain-language definitions for the terms used in this repo.

**ACPI** — Firmware tables that describe the hardware (devices, power, interrupts). macOS
reads them; small fixes are sometimes injected.

**SSDT** — A small ACPI table OpenCore adds to fix or extend the firmware's descriptions
(e.g. enable the RTC, add an EC, enable CPU power management).

**DSDT** — The main ACPI table (the big one). It's disassembled to understand the machine.

**OpenCore (OC)** — The bootloader. It runs before macOS, injects kexts/SSDTs/config, and
starts the macOS kernel.

**EFI** — (1) The small FAT32 partition where bootloaders live; (2) the folder (`EFI/`) that
contains `BOOT/` and `OC/`. In this repo "the EFI" means the folder you copy to the USB/disk.

**`config.plist`** — OpenCore's main settings file (XML). All configuration lives here.

**Kext** — A kernel extension = macOS driver. Third-party kexts are injected from the EFI instead of
installing them.

**Lilu** — The base kext ("patch engine") many other kexts depend on. Always load it first.

**WhateverGreen** — The GPU-fix kext (framebuffers, connectors, etc.).

**AppleALC** — The audio kext. Needs a **layout-id** matching your codec.

**layout-id** — A number telling AppleALC which pin configuration to use for your audio
codec (ours is an ALC233).

**VirtualSMC / SMC** — macOS expects an Apple SMC chip; VirtualSMC emulates it. Required.

**SMBIOS** — The "identity" macOS sees (a chosen model — here **iMac19,1**). Includes serial, MLB
(board serial), UUID, and ROM. Needed for iServices.

**MLB** — Main Logic Board serial, part of the SMBIOS identity.

**ROM** — The "MAC address" field of the SMBIOS identity (set to the real Ethernet MAC).

**Quirks** — OpenCore workaround switches for firmware bugs (CFG Lock, MMIO, memory map…).

**CFG Lock / MSR 0xE2** — A firmware bit that blocks macOS CPU power management. Locked on
this machine → handled by `AppleXcpmCfgLock=true`.

**AWAC / RTC** — Two ways firmware provides the real-time clock. macOS only understands the
legacy **RTC**, so AWAC is disabled.

**EC (Embedded Controller)** — A small controller. Desktops have an incompatible one, so we
add a **fake EC** that macOS accepts.

**PMC** — Power Management Controller; on 300-series chips its ACPI description is missing,
so `SSDT-PMC` is added to get working **NVRAM**.

**NVRAM** — Persistent firmware variables (boot entries, settings). Needed for a proper Mac
experience.

**USB port map** — A definition of which USB ports physically exist, so macOS can use all of
them (and USB 3 speeds). Built with USBToolBox.

**DVMT** — Pre-allocated graphics memory in firmware. Set to 64 MB for the iGPU.

**`ig-platform-id`** — The framebuffer profile macOS uses for the iGPU.

**CSM** — Compatibility Support Module (legacy BIOS emulation). Must be **off**.

**Secure Boot** — Firmware signature enforcement. Must be **off** for a hackintosh.

**ZeroCD / CD-ROM mode** — Some USB dongles first appear as a fake CD with drivers, then
switch to their real function. macOS can't do that switch.

**OCLP (OpenCore Legacy Patcher)** — A *different* tool for running newer macOS on real
older Macs. Not used here.
