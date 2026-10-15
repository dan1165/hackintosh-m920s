# PreInstall — pre-install checks & installer staging

Scripts to run **on the target machine (Linux)** *before* installing macOS. They verify the
hardware matches, the EFI is internally consistent, and (optionally) that the bundled binaries
really are the official upstream releases.

```bash
./PreInstall/preflight.sh            # hardware + EFI checks (fast, offline)
./PreInstall/preflight.sh --all      # also MSR (needs root) + upstream SHA-256 check (network)
```

| Script | What it does | Needs |
|---|---|---|
| [`preflight.sh`](preflight.sh) | runs the checks below and prints one verdict | — |
| [`check-hardware.sh`](check-hardware.sh) | compares `lspci`/DMI/ALSA against the documented M920s | `lspci` |
| [`check-efi.sh`](check-efi.sh) | config parses, referenced files exist, `ocvalidate`, `USBPorts` sanity | `python3` |
| [`check-msr.sh`](check-msr.sh) | CFG Lock (MSR `0xE2`) + DMAR/VT-d vs the config quirks | root, `msr-tools` |
| [`verify-upstream.sh`](verify-upstream.sh) | downloads official releases, confirms SHA-256 of bundled files | network |
| [`check-usb-map.sh`](check-usb-map.sh) | validates `USBPorts.kext` against the live xHCI | root (for protocols) |
| [`stage-installer.sh`](stage-installer.sh) | downloads the iMac19,1 recovery + copies `EFI/` into a staging folder | network |

## Typical flow
```bash
./PreInstall/preflight.sh --all        # confirm the machine + EFI + supply chain
./PreInstall/stage-installer.sh        # -> ./installer-usb/{EFI,com.apple.recovery.boot}
# then copy both folders to the ROOT of a FAT32 (GUID) USB's EFI partition
```

## Exit codes
| Code | Meaning |
|---|---|
| `0` | pass (warnings allowed) |
| `1` | a FAIL — do **not** install until it's fixed |

## Notes
- These scripts are **read-only** on the machine; `stage-installer.sh` only writes to the output
  folder you give it (default `./installer-usb`) and never formats a USB.
- `lib.sh` is sourced by the others (colours + `PASS/WARN/FAIL` helpers).
