# Changelog

## 2026-10-15 — Professional documentation set
- **Root project policies:** `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`, `CODE_OF_CONDUCT.md`.
- **New guides:** `docs/README.md` (index), `docs/COMPATIBILITY.md` (full device → driver matrix),
  `docs/VERIFICATION.md` (methodology + results log), `docs/MAINTENANCE.md`, `docs/RECOVERY.md`,
  `docs/BOOT-PROCESS.md`, `docs/KNOWN-ISSUES.md`, `docs/DECISIONS.md` (ADR-style),
  `docs/SECURITY-PRIVACY.md`, `docs/REFERENCES.md`.
- **GitHub:** issue forms (bug / hardware / feature) + `PULL_REQUEST_TEMPLATE.md` + issue config.
- **Indexes:** README doc table and `docs/README.md` updated; `docs/VERSIONS.md` now lists
  `USBPorts.kext` and the `usb-port-report.sh` helper.

## 2026-10-15 — Hardware-verified USB map + firmware audit
- **USB 3 now works out of the box.** Added `EFI/OC/Kexts/USBPorts.kext` (enabled in
  `Kernel → Add`) — a port map built by probing this exact machine (xHCI *Supported Protocol*
  register ranges + a live "plug into every port" test), not guessed. See `docs/USB-MAP.md`.
- **New docs**
  - `docs/FIRMWARE-ANALYSIS.md` — raw facts read from this machine's DSDT (device map with
    offsets, `BDID=0x20`, root-scope GNVS `STAS`, `XHC.RHUB` port `_ADR`s) and proof that
    every shipped SSDT path resolves against it.
  - `docs/USB-MAP.md` — the verified port map, its evidence, and how to regenerate it.
- **Verified the optional HPET fixup** against the raw DSDT: `_STA`→`XSTA`, `_CRS`→`XCRS` and
  the IPIC/RTC/TIMR IRQ patches each match **exactly once** (clustered inside `HPET`) — so it is
  known-safe to enable. Recorded in `docs/ACPI.md` + `docs/FIRMWARE-ANALYSIS.md`.
- **Wi-Fi upgrades expanded**: `docs/UPGRADES.md` now lists the USB dongles that actually have a
  macOS driver (Realtek **RTL8812AU / 8812BU / 8822BU / 8814AU / 8811AU / 8188 / 8192 / 8723BU**,
  via chris1111's V17 package), and reconfirms the installed **RTL8851BU** has none.
- README updated: USB 3 marked working; doc index cross-linked.

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
