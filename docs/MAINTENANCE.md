# Maintenance

How to keep this build healthy over time. **Rule zero: change one thing, validate, reboot, then
change the next.**

## Validate after *any* edit
```bash
./PostInstall/ocvalidate.linux EFI/OC/config.plist
```
Also enforced by CI on every push. A config that fails `ocvalidate` may not boot.

## Updating OpenCore
1. Download the new **RELEASE** zip from `acidanthera/OpenCorePkg` (see [`VERSIONS.md`](VERSIONS.md)).
2. Replace `EFI/BOOT/BOOTx64.efi`, `EFI/OC/OpenCore.efi`, `EFI/OC/Drivers/*`, `EFI/OC/Tools/*`.
3. Read the release's **Configuration.pdf** / *Differences* for changed/renamed keys and update
   `config.plist` accordingly (don't blind-copy an old config onto a new schema).
4. Update `EFI/OC/Resources/` if you use OpenCanopy and the theme changed.
5. `ocvalidate`, then test with the USB (keep the old EFI as a fallback).
6. Bump [`VERSIONS.md`](VERSIONS.md) + [`CHANGELOG.md`](../CHANGELOG.md).

## Updating kexts (Lilu family)
Always keep the family **in step** or you get silent failures:
- **Lilu must be ≥ every plugin's build** (it's the root patcher).
- Update together: Lilu → WhateverGreen, AppleALC, VirtualSMC(+plugins), NVMeFix, RestrictEvents.
- Replace the `.kext` folders, keep the `Kernel → Add` order (Lilu **first**, VirtualSMC **then** its
  plugins), and update [`VERSIONS.md`](VERSIONS.md).

## Updating macOS (minor/patch within the same major)
1. Keep a **bootable USB** of the current working EFI (rescue).
2. Update OpenCore + kexts **first**, re-validate, reboot once to confirm it's stable.
3. Then run the macOS update.
4. If it fails: boot the rescue USB, revert the EFI.

> **Major** upgrades (e.g. Sonoma → Sequoia) are a different project — re-check kext GPU/audio
> support and the SMBIOS support list before attempting. Sonoma 14 is the target of record here.

## Regenerating the SMBIOS (only if iMessage/App Store fail)
```bash
./PostInstall/macserial.linux -g -m iMac19,1     # prints Serial(1), MLB(2), UUID(3)
```
- Paste **all three** back into `PlatformInfo → Generic`. The `ROM` is the onboard MAC
  `6C:4B:90:CE:BA:90`.
- **Don't** change them again once services work.
- See [`SECURITY-PRIVACY.md`](SECURITY-PRIVACY.md) for the privacy view.

## Rebuilding the USB map (if a port misbehaves)
See [`USB-MAP.md`](USB-MAP.md). Short version: re-run the plug test
(`PostInstall/usb-port-report.sh`), or use USBToolBox, then enable the generated map and
disable `USBPorts.kext`.

## Routine health checks (after macOS boots)
```bash
kextstat | grep -E "Lilu|VirtualSMC|WhateverGreen|AppleALC|IntelMausi|NVMeFix"
kextstat | grep -E "AppleSMBusController|AppleSMBusPCI"
system_profiler SPUSBDataType | head
pmset -g log | tail          # sleep/wake sanity
```

## Backup discipline
- Keep a copy of a **known-good `EFI/`** on a FAT32 USB that always boots this machine.
- Git is the source of truth: tag a working state (e.g. `git tag v1.0.0 && git push --tags`).
