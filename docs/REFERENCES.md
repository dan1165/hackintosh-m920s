# References

Authoritative sources used to build and verify this EFI.

## Specs / standards
| Topic | Source |
|---|---|
| OpenCore configuration keys | OpenCorePkg **Configuration.pdf** / **Differences.pdf** (shipped in each release) |
| ACPI (ASL, `_DSM`, `_STA`, `_UPC`, `_PLD`, GNVS) | *ACPI Specification* (UEFI Forum) |
| xHCI (USB 3) registers, Supported-Protocol ext-cap | *eXtensible Host Controller Interface* spec (Intel) |
| SMBIOS (serial/MLB/UUID semantics) | *DMTF SMBIOS* spec + `macserial` docs |
| Apple `IO80211` / `IOBluetoothFamily` (why USB Wi-Fi is hard) | Apple kernel headers (private) — no public docs |

## Upstream projects (build inputs)
- **OpenCorePkg** — bootloader, `ocvalidate`, `macserial`, `macrecovery` — `github.com/acidanthera/OpenCorePkg`
- **Lilu** — `github.com/acidanthera/Lilu`
- **VirtualSMC** (+SMCProcessor/SMCSuperIO) — `github.com/acidanthera/VirtualSMC`
- **WhateverGreen** — `github.com/acidanthera/WhateverGreen`
- **AppleALC** — `github.com/acidanthera/AppleALC`
- **IntelMausi** — `github.com/acidanthera/IntelMausi`
- **NVMeFix** — `github.com/acidanthera/NVMeFix`
- **RestrictEvents** — `github.com/acidanthera/RestrictEvents`
- **CPUFriend** — `github.com/acidanthera/CPUFriend`
- **USBToolBox** — `github.com/USBToolBox/tool`, `github.com/USBToolBox/kext`

## Community guides (for concepts, not copy-paste)
- Dortania **OpenCore Install Guide** — `dortania.github.io/OpenCore-Install-Guide`
- Dortania **OpenCore Post-Install** (audio, USB map, iMessage) — `dortania.github.io/OpenCore-Post-Install`
- Dortania **Getting Started With ACPI** (SSDT methods) — `dortania.github.io/Getting-Started-With-ACPI`
- **chris1111** USB Wi-Fi drivers — `github.com/chris1111/Wireless-USB-OC-Big-Sur-Adapter`

## Machine documentation
- Lenovo **ThinkCentre M920s User Guide & Hardware Maintenance Manual** (`download.lenovo.com`)
- Lenovo **PSREF** spec sheet for ThinkCentre M920 SFF (`psref.lenovo.com`)

## How this project used them
The **first three rows** are treated as ground truth (specs/schemas). Community guides are used to
explain *concepts*; every value in this repo is then re-derived from **this machine's own data**
(`lspci`, `lsusb`, DSDT, xHCI registers) — see [`VERIFICATION.md`](VERIFICATION.md) and
[`FIRMWARE-ANALYSIS.md`](FIRMWARE-ANALYSIS.md).
