# Storage (NVMe + SATA)

**Target:** WDC PC SN730 512 GB NVMe (`15B7:5006`, `SDBQNTY-512G-1001`), Intel Q370 SATA (AHCI,
`8086:A352`).

## How it's handled here
| Piece | Value | Why |
|---|---|---|
| NVMe | **native** Apple NVMe stack | macOS supports NVMe natively since 10.13 |
| `NVMeFix.kext` | enabled | power management + quirks for non-Apple NVMe (APST) |
| `Kernel → Quirks → SetApfsTrimTimeout` | `-1` | leave TRIM handling to the default (set `0`/ms only if TRIM is problematic) |
| SATA | native `AppleAHCIPort` / `IOAHCIFamily` | AHCI mode required in BIOS |
| `ThirdPartyDrives` | `false` | only needed for SSD TRIM-on-older setups |

## Verify (macOS)
```bash
diskutil list
system_profiler SPNVMeDataType | head -40
kextstat | grep -i nvmefix
# TRIM state
system_profiler SPStorageDataType | grep -i trim
```

## Installing to the NVMe
- The macOS installer **erases the target disk** (see [`HARDWARE.md`](HARDWARE.md) §disks).
- Erase as **APFS** / GUID Partition Map in Disk Utility.
- Do **not** enable a RAID/Intel RST mode in BIOS — AHCI only.

## Multi-disk
- To keep the existing OS, install macOS to a **second** NVMe/SATA disk instead.
- For dual-boot details see [`MULTIBOOT.md`](MULTIBOOT.md).

## Symptoms → cause
| Symptom | Cause |
|---|---|
| Disk not seen by the installer | firmware NVMe driver missing (add `NvmExpressDxe.efi`) or SATA in RAID mode |
| Random disconnects / high idle power | `NVMeFix` not loaded |
| TRIM warnings | `SetApfsTrimTimeout` tuning (see `docs/OPTIONAL-COMPONENTS.md`) |
