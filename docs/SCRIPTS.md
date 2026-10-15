# Scripts reference

Every script in this repo, what it does, and how to run it.

## `PreInstall/` — run before installing
| Script | Purpose | Usage |
|---|---|---|
| `preflight.sh` | master check (hardware + EFI; `--all` adds MSR + upstream) | `./PreInstall/preflight.sh --all` |
| `check-hardware.sh` | machine matches the documented M920s | `./PreInstall/check-hardware.sh` |
| `check-efi.sh` | config valid, files present, USBPorts sane | `./PreInstall/check-efi.sh` |
| `check-msr.sh` | CFG Lock + DMAR vs the config quirks | `sudo ./PreInstall/check-msr.sh` |
| `verify-upstream.sh` | bundled binaries == official releases (SHA-256) | `./PreInstall/verify-upstream.sh` |
| `stage-installer.sh` | download recovery + copy EFI to a staging folder | `./PreInstall/stage-installer.sh [OUTDIR]` |
| `lib.sh` | shared helpers (sourced, not run) | — |

## `PostInstall/` — run after macOS boots
| Script | Purpose | Usage |
|---|---|---|
| `ocvalidate.linux` | validate `config.plist` | `./PostInstall/ocvalidate.linux EFI/OC/config.plist` |
| `macserial.linux` | generate SMBIOS serial/MLB/UUID | `./PostInstall/macserial.linux -g -m iMac19,1` |
| `macrecovery/macrecovery.py` | download a macOS recovery | `python3 .../macrecovery.py -b <board> download -o <dir>` |
| `usb-port-report.sh` | probe which USB ports are wired | `./PostInstall/usb-port-report.sh` |
| `ResourceConverter.sh` | build a CPUFriend `DataProvider` | `./PostInstall/ResourceConverter.sh --kext <plist>` |
| `ocpasswordgen/` | OpenCore picker password generator | see folder |
| `CPUFriend-Tools/` | frequency-vector tooling | see folder |

## Conventions
- **Exit codes:** `0` = OK, `1` = FAIL. `preflight.sh` returns non-zero if any sub-check failed.
- **Colours** are auto-disabled when output isn't a TTY (safe for logs/CI).
- **Read-only** on the machine, except `stage-installer.sh` which writes only to its output dir.
- All scripts are plain **bash**; the checks additionally need `python3` (and `lspci`, `rdmsr`,
  `curl` for their respective checks).

## CI
| Workflow | What it does |
|---|---|
| `.github/workflows/validate.yml` | runs `ocvalidate 1.0.8` on any `EFI/OC/**` change |
| `.github/workflows/docs.yml` | markdown link check + `shellcheck` on `PreInstall/` & `PostInstall/` |

## Adding a script
1. Put it in `PreInstall/` (pre-install) or `PostInstall/` (macOS-side).
2. `#!/usr/bin/env bash`, `set -u`, `DIR=...; . "$DIR/lib.sh"` for the checks.
3. Document it here **and** in that folder's `README.md`.
4. Keep it read-only unless clearly named (e.g. `stage-*`).
