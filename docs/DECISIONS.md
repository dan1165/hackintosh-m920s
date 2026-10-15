# Design decisions (ADR)

Short records of the *why* behind non-obvious choices. Format:
**decision → context → consequence**.

## D1 — SMBIOS `iMac19,1`
**Context:** i7-9700 (Coffee Lake Refresh) + UHD 630, no dGPU. 2019 27" iMac = same CPU family and
iGPU.
**Decision:** `iMac19,1`, with `Macmini8,1` documented as a fallback.
**Consequence:** GPU/power matching is correct; iMessage depends on Apple serial validation.
*Do not* use an Apple-Silicon or dGPU-only model.

## D2 — `AppleXcpmCfgLock = true`
**Context:** `rdmsr 0xE2` showed bit 15 **set** → CFG Lock is physically locked.
**Decision:** set the quirk (and keep it unless the MSR is unlocked).
**Consequence:** native XCPM works. If you unlock via `ControlMsrE2`, switch it to `false`.

## D3 — `SSDT-PMC` for NVRAM; no PMC in DSDT
**Context:** Q370 is a true 300-series PCH and the DSDT has **no** `APP9876`/PMC device.
**Decision:** inject `SSDT-PMC`.
**Consequence:** native NVRAM works. Verified there is no existing `PMCR`/`MCHC` to collide with.

## D4 — `SSDT-AWAC` instead of an RTC patch
**Context:** DSDT has both `RTC` and `AWAC`, switched by `STAS`.
**Decision:** set `STAS=1` under Darwin (disable AWAC, use RTC).
**Consequence:** correct clock behaviour. **Never** combine with a separate RTC patch.

## D5 — HPET fixup **omitted** by default
**Context:** the HPET IRQ fix (`SSDT-HPET` + 5 DSDT renames) only matters if audio fails, and a
wrong rename can break boot.
**Decision:** leave it out; document it as verified-safe to add.
**Consequence:** smaller, safer default. Each rename was confirmed to match the DSDT exactly once.

## D6 — Ethernet-only (no Wi-Fi/BT)
**Context:** the installed RTL8851BU USB Wi-Fi 6 + BT combo has **no macOS driver**.
**Decision:** ship Ethernet-only; recommend a Broadcom card for wireless.
**Consequence:** no AirDrop/Handoff out of the box; supported USB dongles listed in `UPGRADES.md`.

## D7 — Ship a USB port map (`USBPorts.kext`)
**Context:** 26 xHCI ports vs macOS's 15-port cap; the usual answer is "run USBToolBox yourself".
**Decision:** probe the machine and ship the map.
**Consequence:** USB 3 works with no user step. The map is evidence-based (see `USB-MAP.md`).

## D8 — Keep the EFI minimal
**Context:** more kexts = more failure points on a Hackintosh.
**Decision:** omit `CPUFriend`, `USBWakeFixup`, `FeatureUnlock`, etc.; ship `CPUFriend`/`USBToolBox`
**disabled**.
**Consequence:** fewer things to break; add them only when a concrete need appears.

## D9 — CI validates every push
**Context:** a bad `config.plist` can stop the machine booting.
**Decision:** GitHub Action runs `ocvalidate` on any `EFI/OC/**` change.
**Consequence:** schema regressions are caught before they reach a USB.

## D10 — Public SMBIOS/MAC, no personal secrets
**Context:** the build must be self-contained, but contributors must not leak identities.
**Decision:** commit the *build's* serial/MLB/UUID/ROM; forbid personal serials/tokens.
**Consequence:** reproducible, and SECURITY.md sets the rules (see `SECURITY-PRIVACY.md`).
