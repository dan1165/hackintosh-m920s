# ACPI / SSDTs

An **SSDT** is a small ACPI table OpenCore injects to make the firmware's descriptions
macOS-friendly. Every SSDT here was derived from **this machine's own DSDT**.

## Enabled
| SSDT | Purpose | Key detail found in your DSDT |
|---|---|---|
| **SSDT-AWAC** | Force the legacy **RTC** and disable **AWAC** | DSDT has both; `RTC._STA`/`AWAC._STA` are keyed on `STAS`. This sets `STAS=1` under Darwin. |
| **SSDT-EC-USBX** | Provide a fake Embedded Controller + USB power properties | `H_EC._STA` already returns 0; a fake `EC` (`ACID0001`) is added under `\_SB.PCI0.LPCB`. |
| **SSDT-PLUG** | Enable XCPM CPU power management | CPU objects are `\_SB.PR00…PR15`. Injects `plugin-type=1`. |
| **SSDT-PMC** | Restore **NVRAM** on true 300-series PCH | DSDT has no PMC device; adds `APP9876` at MMIO `0xFE000000`. |
| **SSDT-SBUS-MCHC** | Add `MCHC` + SMBus device | DSDT `Device (SBUS)` under `\_SB.PCI0`. |

## Bundled but disabled
| SSDT | Turn it on if… |
|---|---|
| **SSDT-RHUB** | Some USB ports are missing/broken (forces USB re-enumeration). Rarely needed on Cannon Lake. |

## Not shipped (documented only)
- `SSDT-HPET` + DSDT IRQ renames — only if **every** audio layout fails. A wrong HPET patch
  is worse than none, so it's left out on purpose.

## How these were generated
1. Dump tables: `cp /sys/firmware/acpi/tables/* /tmp && iasl -d DSDT`.
2. Inspect device paths (`LPCB`, `SBUS`, `PR00`, `XHC.RHUB`, `RTC`/`AWAC`).
3. Take OpenCore's reference sources from `OpenCorePkg/Docs/AcpiSamples/` and adapt.
4. Compile: `iasl -p SSDT-X.aml SSDT-X.dsl` (acpica-tools).

## Rules
- **Never** rename `H_EC`/`EC0` to `EC` on this desktop.
- Do not use `SSDT-AWAC` **and** an RTC patch at the same time.
- After adding an SSDT, add its `.aml` to `config.plist → ACPI → Add` and re-run `ocvalidate`.
