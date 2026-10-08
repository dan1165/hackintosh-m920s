# Changelog

## 2026-10-08 — v1.0.0 (initial release)
- **EFI**: OpenCore 1.0.8 for ThinkCentre M920s; `ocvalidate` clean.
- **Config tailored from real firmware**:
  - SMBIOS `iMac19,1` with generated serial/MLB; ROM = onboard MAC; fallback `Macmini8,1`.
  - iGPU `AAPL,ig-platform-id 07009B3E` + `framebuffer-stolenmem`.
  - Audio ALC233 (`layout-id 3`).
  - `AppleXcpmCfgLock=true` (CFG Lock verified locked), `DisableIoMapper=true`,
    `ProtectUefiServices=true`, `DevirtualiseMmio=true`.
- **ACPI** (derived from the machine's DSDT): SSDT-AWAC, SSDT-EC-USBX, SSDT-PLUG,
  SSDT-PMC, SSDT-SBUS-MCHC; SSDT-RHUB (disabled).
- **Kexts**: Lilu 1.7.2, VirtualSMC 1.3.8 (+SMCProcessor/SMCSuperIO), WhateverGreen 1.7.1,
  AppleALC 1.9.8, IntelMausi 1.0.8, NVMeFix 1.1.3, RestrictEvents 1.1.6;
  CPUFriend 1.3.0 + USBToolBox 1.2.0 (disabled).
- **Docs**: README hub, QUICKSTART, INSTALL, BIOS, HARDWARE, POST-INSTALL, KEXTS, ACPI,
  TOOLS, TROUBLESHOOTING, FAQ, GLOSSARY, UPGRADES, VERSIONS, CREDITS, RELIABILITY-AUDIT.
- **CI**: GitHub Action runs `ocvalidate` on every push/PR.
- **Wireless decision**: Ethernet-only. A tested Realtek RTL8851BU USB Wi-Fi 6 + BT combo
  was rejected (no macOS driver for either half).

## Corrections during pre-install audit
- Audio layout fixed `11 → 3` (11 is not a valid ALC233 layout).
- `ProtectUefiServices` set to `true` (300-series requirement with `DevirtualiseMmio`).
- Confirmed CFG Lock is locked via `rdmsr 0xE2` → kept `AppleXcpmCfgLock=true`.
