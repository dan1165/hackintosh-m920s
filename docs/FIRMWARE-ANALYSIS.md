# Firmware analysis (verified against this machine's DSDT)

Everything in this repo was checked against the machine's **real** ACPI tables, dumped from
`/sys/firmware/acpi/tables/` (root) and disassembled with **ACPI Component Architecture
20260930** (`iasl`). This file records the raw facts those checks produced.

- **Machine:** Lenovo ThinkCentre M920s, BIOS **M1UKT79A**, Intel **Q370**
- **DSDT:** 313,215 bytes, OEM IDs = Lenovo/AMI
- **Firmware variables:** `BDID = 0x20`, `CABL = 0`, `PCHH = 1`, `PCHL = 2`

---

## 1. Device map (DSDT)
| Device | `_ADR` / location | Notes |
|---|---|---|
| `LPCB` | `_SB.PCI0` @1F.0 | contains `H_EC`, `LPTE`, `SIO1` |
| `SBUS` | `_SB.PCI0` @1F.4 | SMBus |
| `HPET` | `_SB.PCI0.LPCB` | has `_STA` + `_CRS` methods |
| `AWAC` | — | `ACPI000E`; `_STA` returns `0x0F` only when `STAS == 0` |
| `H_EC` | `_SB.PCI0.LPCB` | `PNP0C09`, `_UID 1`, `_STA` **always returns 0** (disabled) |
| `XHC` → `RHUB` | `_SB.PCI0` @14.0 | defines the USB ports (`HS01`…`SS10`) |
| `HDAS` | `_SB.PCI0` @1F.3 | audio (Realtek ALC233) |
| `GLAN` | `_SB.PCI0` @1F.6 | Intel I219-LM |
| `STAS` | field of `OperationRegion (GNVS, SystemMemory, 0x9B1E6000, 0x867)` declared at **root scope** | AWAC/RTC select |

## 2. Every SSDT path matches the DSDT
| SSDT in this repo | Path it touches | DSDT result |
|---|---|---|
| `SSDT-AWAC` | `STAS` | exists at `\STAS` (root-scope GNVS field) → resolves ✅ |
| `SSDT-EC-USBX` | `\_SB.PCI0.LPCB` | `Device (LPCB)` present; `H_EC` disabled, no `EC` name clash ✅ |
| `SSDT-PLUG` | `\_SB.PR00` | `Processor (PR00 …)` present ✅ |
| `SSDT-PMC` | adds `PMCR` under LPCB | **no existing `PMCR`/`MCHC` anywhere** → collision-free ✅ |
| `SSDT-SBUS-MCHC` | `\_SB.PCI0.SBUS` | `Device (SBUS)` present; **no existing `BUS0`** ✅ |
| `SSDT-RHUB` (disabled) | `XHC.RHUB` | `RHUB` present |

## 3. ACPI rename patches — every one matches exactly once
The classic HPET fixup (not shipped by default, see `docs/ACPI.md`) was verified against the raw
DSDT so it is **known-safe to enable** if ever needed:

| Patch | Find (hex) | Matches | Offset |
|---|---|---|---|
| HPET `_STA`→`XSTA` | `00 14 11 5F 53 54 41` | 1 | 87007 (inside HPET) |
| HPET `_CRS`→`XCRS` | `25 5F 43 52 53` | 1 | 87027 (inside HPET) |
| IPIC IRQ 2 | `22 04 00 79 00` | 1 | 87226 (HPET `_CRS`) |
| RTC IRQ 8 | `22 00 01 79 00` | 1 | 87462 (HPET `_CRS`) |
| TIMR IRQ 0 | `22 01 00 79 00` | 1 | 87531 (HPET `_CRS`) |

All five hits are clustered inside the HPET device, confirming the fixup targets the right place.

## 4. USB topology (see `docs/USB-MAP.md`)
`XHC.RHUB` defines `HS01`–`HS14` (`_ADR` 1–14), `USR1`/`USR2` (`_ADR` 15/16) and
`SS01`–`SS10` (`_ADR` 17–26). `_UPC` returns `GUPC(One)` (connectable) for `HS01`–`HS13` and
`SS01`–`SS10` at `BDID=0x20`; `HS14`/`USR1`/`USR2` return `GUPC(Zero)`. The xHCI registers
confirm the same split (USB2 = ports 1–16, USB3 = 17–26).

## 5. Other confirmed facts
- **NVRAM:** no `APP9876`/PMC device in the DSDT → `SSDT-PMC` needed (Q370 is a true 300-series PCH).
- **EC:** `H_EC` is `_STA`-disabled → no rename needed; fake `EC` (`ACID0001`) is safe.
- **DMAR:** present → `Kernel → Quirks → DisableIoMapper = true`.
- **FACP:** ACPI reset register supported (no `FadtEnableReset` needed).
- **SMBus:** `SBUS` at 1F.4 → `SSDT-SBUS-MCHC` valid.
- **CFG Lock:** verified locked (`rdmsr 0xE2` bit 15 set) → `AppleXcpmCfgLock = true` (mandatory).
