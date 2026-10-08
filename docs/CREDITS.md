# Credits & Attributions

This project is only possible because of the open-source hackintosh community. All bundled
software belongs to its authors and keeps its own license.

## Bootloader & core
- **OpenCore** / **OpenCorePkg** — acidanthera — https://github.com/acidanthera/OpenCorePkg
- **Lilu** — acidanthera — https://github.com/acidanthera/Lilu
- **VirtualSMC** — acidanthera — https://github.com/acidanthera/VirtualSMC
- **WhateverGreen** — acidanthera — https://github.com/acidanthera/WhateverGreen
- **AppleALC** — acidanthera — https://github.com/acidanthera/AppleALC
- **IntelMausi** — acidanthera — https://github.com/acidanthera/IntelMausi
- **NVMeFix** — acidanthera — https://github.com/acidanthera/NVMeFix
- **RestrictEvents** — acidanthera — https://github.com/acidanthera/RestrictEvents
- **CPUFriend** — acidanthera — https://github.com/acidanthera/CPUFriend
- **USBToolBox** — USBToolBox project — https://github.com/USBToolBox

## Documentation & guidance
- **Dortania OpenCore Install Guide** — https://dortania.github.io/OpenCore-Install-Guide/
- **Dortania Getting Started With ACPI** — https://dortania.github.io/Getting-Started-With-ACPI/
- **Dortania OpenCore Post-Install** — https://dortania.github.io/OpenCore-Post-Install/
- **Acidanthera AppleALC supported codecs** — https://github.com/acidanthera/AppleALC/wiki/Supported-codecs

## Other tools
- **acpica-tools (`iasl`)** — Intel ACPI Component Architecture
- **usb_modeswitch** — Josua Dietze / draisberghof.de
- **msr-tools / rdmsr** — kernel.org

## What this repo adds
The machine-specific work: the detected hardware report, the tailored `config.plist`, the
selected SSDTs verified against this DSDT, the reliability audit, and these guides.

## License
- **This repo's original content** (docs, config selection, scripts): **MIT** — see [`LICENSE`](../LICENSE).
- **Bundled third-party binaries** (OpenCore, kexts, drivers, tools): remain under their
  respective upstream licenses. MIT here does **not** override them.

> Running macOS on non-Apple hardware violates Apple's EULA. This is provided for personal
> experimentation and education only.
