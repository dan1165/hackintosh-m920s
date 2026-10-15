# Verification

What was checked, how, and the result. Everything here was run against the **actual machine**
(and the shipped files). Dates are ISO-8601.

## 1. Methodology
| Layer | Tool / method | What it proves |
|---|---|---|
| Config schema | `ocvalidate 1.0.8` | `config.plist` is valid for the bootloader version |
| Bootloader integrity | SHA-256 vs official release | `OpenCore.efi`/drivers are unmodified upstream binaries |
| Firmware | dump `/sys/firmware/acpi/tables/*`, `iasl` disassembly | SSDT paths + rename patches match the real DSDT |
| Hardware | `lspci`, `lsusb`, `dmidecode`, `/sys/class/dmi`, ALSA codec | every device is identified and driven |
| USB map | xHCI *Supported Protocol* regs + live plug test | which controller ports are wired |
| Bootloader runtime | `-v keepsyms=1` boot (post-install) | the chain actually reaches macOS |

## 2. Results log
| Date | Check | Command | Result |
|---|---|---|---|
| 2026-10-15 | Config valid | `ocvalidate 1.0.8 EFI/OC/config.plist` | **No issues found** ✅ |
| 2026-10-15 | Bootloader is upstream | SHA-256 vs `OpenCore-1.0.8-RELEASE.zip` | identical ✅ |
| 2026-10-15 | SSDT paths resolve | DSDT disassembly | `LPCB`, `SBUS`, `PR00`, `XHC.RHUB`, `STAS` all present ✅ |
| 2026-10-15 | HPET renames safe | search raw DSDT for each `Find` | each matches **exactly once** ✅ |
| 2026-10-15 | USB numbering | xHCI `reg-ext-protocol:00|01` | USB2 = ports 1–16, USB3 = 17–26 ✅ |
| 2026-10-15 | Wired USB ports | plug test (sysfs watcher) | `SS01–SS04`, `SS08–SS09`, `HS01–HS04/06–10` ✅ |
| 2026-10-15 | CFG Lock | `rdmsr 0xE2` bit 15 | **locked** → `AppleXcpmCfgLock=true` required ✅ |
| 2026-10-15 | No `PMCR`/`MCHC` in DSDT | grep disassembly | `SSDT-PMC`/`SSDT-SBUS-MCHC` collision-free ✅ |
| 2026-10-15 | CI | GitHub Action on push | `success` ✅ |

## 3. Reproducing the firmware checks
```bash
# dump + disassemble ACPI (root)
sudo cp /sys/firmware/acpi/tables/* /tmp/acpi/
iasl -d -p /tmp/DSDT.dsl /tmp/acpi/DSDT

# verify an ACPI rename patch matches exactly once
python3 - <<'PY'
raw = open('/tmp/acpi/DSDT','rb').read()
pat = bytes.fromhex('0014115f535441')       # HPET _STA -> XSTA (example)
print('matches:', raw.count(pat))
PY

# xHCI protocol / port ranges
sudo cat /sys/kernel/debug/usb/xhci/*/reg-ext-protocol:00
sudo cat /sys/kernel/debug/usb/xhci/*/reg-ext-protocol:01
```

## 4. What is **not** verified here
- A full end-to-end **boot on macOS** is out of scope for CI (no Mac in the pipeline). It is
  verified manually after install (see [`POST-INSTALL.md`](POST-INSTALL.md)).
- `iMessage`/`FaceTime` depend on Apple-side serial validation and cannot be checked offline.
- Third-party closed-source drivers (e.g. a USB Wi-Fi kext) are trusted via their official
  release; their internals are not audited.
