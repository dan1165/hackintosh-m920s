# Pre-install Reliability Audit — ThinkCentre M920s

Everything below was verified against your **actual hardware and firmware**, not assumed.
This is the "research deeply before install" pass.

---

## 1. Firmware-level checks

| Check | Method | Result | Action taken |
|---|---|---|---|
| **CFG Lock (MSR 0xE2 bit 15)** | `rdmsr -a 0xE2` on the running host | `0x1E008008` → **bit 15 SET = LOCKED** | `Kernel → Quirks → AppleXcpmCfgLock = true` (mandatory). Optional: unlock with `Tools → ControlMsrE2`, then set it `false`. |
| RTC vs AWAC | DSDT `AWAC._STA` / `RTC._STA` both keyed on `STAS` | `STAS=0` → AWAC on, RTC off (macOS can't use AWAC) | `SSDT-AWAC.aml` sets `STAS=1` under Darwin → legacy RTC enabled. ✅ |
| PMC / NVRAM | DSDT has no `APP9876`/PMC device | Q370 is a "true" 300-series PCH | `SSDT-PMC.aml` required for native NVRAM. ✅ |
| Embedded Controller | DSDT `H_EC` (`PNP0C09`) `_STA` | Returns **0 always** → already hidden | No rename/disable needed; fake `EC` (`ACID0001`) via `SSDT-EC-USBX`. ✅ |
| SMBus | DSDT `Device (SBUS)` under `\_SB.PCI0` | present | `SSDT-SBUS-MCHC.aml` adds `MCHC` + `smbus`. ✅ |
| CPU XCPM scope | DSDT `Processor (PR00…)` under `\_SB` | present | `SSDT-PLUG.aml` attaches `plugin-type=1`. ✅ |
| PCI MMIO (for DevirtualiseMmio) | `/proc/iomem` reserved regions | 5 high reserved regions | `DevirtualiseMmio=true` (+ `ProtectUefiServices=true`, 300-series rule). MmioWhitelist not required. ✅ |
| Above 4G decoding | PCI BARs all below 4 GB | likely **disabled** | No `npci=` boot-arg needed; if boot hangs at PCI, try `npci=0x2000`. |
| VT-d / DMAR | `DMAR` table present, IOMMU off in host | VT-d firmware-side | `DisableIoMapper=true` (and/or disable VT-d in BIOS). ✅ |

## 2. Component compatibility (Sonoma 14.x)

| Part | ID | Driver | Verdict |
|---|---|---|---|
| i7-9700 (CFL-R, 8C/8T) | `0x906ED` | native XCPM | ✅ no spoof |
| UHD 630 | `8086:3E98` | WhateverGreen, `ig-platform-id 07009B3E` | ✅ |
| I219-LM | `8086:15BB` | IntelMausi 1.0.8 | ✅ |
| ALC233 | `10EC:0235` | AppleALC 1.9.8 | ✅ (layout trial) |
| SN730 NVMe | `15B7:5006` | native + NVMeFix 1.1.3 | ✅ |
| Cannon Lake xHCI | `8086:A36D` | native | ✅ (map for USB3) |
| Wi-Fi/BT | Realtek **RTL8851BU** USB combo (`3625:010B`) | none exists | ❌ **rejected** — Ethernet-only |

## 3. Corrections made in this pass
1. **Audio layout default changed `11 → 3`.** AppleALC's supported-codec list for
   **ALC233** is `3, 4, 5, 13, 21, 27, 28, 29, 32, 33`. Layout **11 is not valid for
   ALC233** and would likely have produced no audio.
2. **`Booter → Quirks → ProtectUefiServices` set to `true`** (required on 300-series /
   Z390-class boards using `DevirtualiseMmio`; Q370 is in that family).
3. Confirmed **`AppleXcpmCfgLock=true`** is required (CFG Lock is physically locked).
4. Verified **every SSDT scope path matches your DSDT** (`LPCB`, `SBUS`, `PR00`, `XHC.RHUB`).
5. Added a **Macmini8,1 fallback SMBIOS** (iGPU-native) in case the iMac19,1 iGPU config
   misbehaves — see README §6e.
6. **Shipped a hardware-verified USB port map** (`EFI/OC/Kexts/USBPorts.kext`) so USB 3 runs at
   full speed with **no manual USBToolBox step** — derived from the xHCI *Supported Protocol*
   registers (USB2 = ports 1–16, USB3 = 17–26) plus a live plug test on this machine.
   See **[docs/USB-MAP.md](docs/USB-MAP.md)**.
7. **Recorded the raw firmware facts** (device map with offsets, `BDID=0x20`, root-scope GNVS
   `STAS`, `XHC.RHUB` port `_ADR`s) and re-verified the optional HPET rename patches
   (`_STA`→`XSTA`, `_CRS`→`XCRS`, IPIC/RTC/TIMR IRQ) each match this DSDT **exactly once** —
   see **[docs/FIRMWARE-ANALYSIS.md](docs/FIRMWARE-ANALYSIS.md)**.

## 4. Deliberately NOT included (keeps the build reliable and minimal)
| Item | Why omitted |
|---|---|
| `SSDT-HPET` + IRQ renames | Only needed if **all** audio layouts fail. A wrong HPET patch is worse than none. |
| `SSDT-RHUB` | Present but **disabled**; only for missing USB ports. |
| `CPUFriend` + DataProvider | Native XCPM is already correct; disabled. |
| `RTCMemoryFixup`, `USBWakeFixup`, `FeatureUnlock` | No evidence of need; fewer kexts = fewer failure points. |
| Wi-Fi/BT kexts | Ethernet-only decision; onboard I219-LM is already supported. |

## 5. Final pre-flight gate (do these in order)
1. Apply the BIOS checklist (README §3) — especially **Secure Boot = Disabled** and
   **Secure Boot / CSM**.
2. Build the USB installer (README §4).
3. Boot with `-v`; confirm you reach the picker and the installer.
4. After install: audio layout trial (§6a), USB map (§6b), then copy EFI to the internal disk.
5. Re-run `./PostInstall/ocvalidate.linux EFI/OC/config.plist` after **any** config edit.

## 6. Wireless decision (tested, not assumed)
A TP-Link Realtek **RTL8851BU** USB Wi-Fi 6 + BT combo was physically connected and
probed. It first appears as a fake mass-storage "CD" (`0bda:1a2b`); after mode-switching
it becomes `3625:010B` and Linux bound `rtw89_8851bu` (Wi-Fi) + `btusb` (BT). Conclusion:

- **Wi-Fi (RTL8851BU, rtw89/802.11ax)** → ❌ no macOS driver exists.
- **Bluetooth (RTL8851BU)** → ❌ the only Realtek USB-BT kext matches RTL8761B/U only.
- macOS cannot perform the ZeroCD→WLAN switch, so the stick stays a "CD" anyway.

**DECISION: stay on Ethernet.** Recommended wireless upgrade if ever needed:
**BCM94360NG** (native Wi-Fi + BT + AirDrop/Handoff).

If a **USB** dongle is preferred instead, buy one with a **supported Realtek chip** —
RTL8812AU, RTL8812BU / RTL8822BU, RTL8814AU, RTL8811AU, or RTL8188 / 8192 / 8723BU — which *does*
have a macOS driver (chris1111's V17 package). Full table in
**[docs/UPGRADES.md](docs/UPGRADES.md)**. Any **Wi-Fi 6 / 802.11ax** stick (RTL8851BU/8852xx) has
no macOS driver at all.
