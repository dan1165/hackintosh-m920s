# Hardware

Everything here was detected from the **actual machine** (SMBIOS, PCI, USB, ACPI, EDID)
rather than copied from a spec sheet.

## Summary
| Part | Details | macOS |
|---|---|---|
| Model | Lenovo **ThinkCentre M920s**, board `3132` | — |
| BIOS | LENOVO `M1UKT79A` v1.121 (2026-03-12, AMI, 12 MB ROM) | — |
| Embedded controller | `M1UCT18A-1.18`, boot block `1.79` | — |
| CPU | Intel **Core i7-9700** "Coffee Lake Refresh", 8C/8T, 3.0→4.7 GHz, 12 MB L3 | ✅ native |
| Chipset | Intel **Q370** (Cannon Lake PCH, 300-series) | ✅ |
| iGPU | Intel **UHD Graphics 630** (`8086:3E98`) | ✅ Metal |
| dGPU | none | — |
| RAM | 16 GB = 2× 8 GB Samsung `M378A1K43CB2-CTD` DDR4-2666, dual-channel | ✅ |
| Storage | **WDC PC SN730** `SDBQNTY-512G-1001` 512 GB NVMe PCIe 3.0 ×4 (`15B7:5006`) | ✅ native |
| SATA | Cannon Lake PCH AHCI (`8086:A352`) | ✅ |
| Ethernet | Intel **I219-LM** (`8086:15BB`) | ✅ IntelMausi |
| Audio | Realtek **ALC233** (`10EC:0235`) on cAVS HDA (`8086:A348`) | ✅ AppleALC |
| USB | Cannon Lake PCH xHCI (`8086:A36D`), 16×USB2 / 10×USB3 | ✅ (map for USB3) |
| Wi-Fi/BT | none supported (RTL8851BU has no macOS driver) | ❌ Ethernet-only |
| Display out | 2× DisplayPort (rear VGA unusable by macOS) | ✅ |
| TPM | 2.0 present | (disable Secure Boot) |
| Boot mode | UEFI, CSM disabled | ✅ |

## CPU
```
Intel Core i7-9700 (Coffee Lake Refresh)
Family 6, Model 158 (0x9E), Stepping 13 (0x0D)
CPUID 0x906ED, microcode 0x104
8 cores / 8 threads (no HT), AVX2, AES, VT-x, VT-d
```
- Supported natively by macOS — **no CPUID spoof, no kernel patch needed.**
- Power management via XCPM (`plugin-type=1` injected by `SSDT-PLUG`).

## Graphics
```
Intel UHD Graphics 630   PCI 00:02.0   8086:3E98 (rev 02)
Subsystem 17AA:3132
Framebuffer used: AAPL,ig-platform-id = 07009B3E (0x3E9B0007)
```
- Native Metal acceleration. iGPU drives the display (no dGPU).

## Memory
- Slots: `ChannelA-DIMM1` and `ChannelB-DIMM1` populated → **dual-channel**.
- Free: `ChannelA-DIMM0`, `ChannelB-DIMM0`. Max 64 GB (4 DIMMs).

## Storage / disks (reference unit, before install)
GPT on `/dev/nvme0n1`:
| # | Size | Type | Use |
|---|---|---|---|
| 1 | 1 MB | BIOS boot | (legacy) |
| 2 | 1 GB | EFI System | existing OS bootloader |
| 3 | 475 GB | Linux LVM | existing Linux (root/swap/data) |

The macOS install **replaces all of this**.

## Firmware / ACPI
- ACPI OEM id: `LENOVO` / `TC-M1U`; DSDT 313 KB, compiled by INTL `0x20160930`.
- Tables present: `APIC ASF! BGRT DBG2 DBGP DMAR FACP FACS FIDT FPDT HPET LPIT LUFT MCFG MSDM NHLT SLIC SSDT1-9 TPM2 UEFI WSMT` + CPU SSDTs 10-18.
- Notable: DSDT contains **both `RTC` (PNP0B00) and `AWAC` (ACPI000E)** keyed on `STAS`, and a disabled `H_EC` (`PNP0C09`, `_STA` returns 0).

## How this was detected (for reproducibility)
```bash
lscpu; lspci -nn; lsusb; lsblk; dmidecode -t 0,1,2,16,17
cat /proc/asound/card*/codec#*      # audio codec
cp /sys/firmware/acpi/tables/* /tmp && iasl -d DSDT
modprobe msr && rdmsr -a 0xE2       # CFG Lock bit
```
The raw ACPI dump and DSDT disassembly are **not** committed (large/session-specific) but are
easy to regenerate with the commands above.
