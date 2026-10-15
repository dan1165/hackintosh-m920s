# Pre-install checklist

Print this, tick it off. Everything here is scripted in [`PreInstall/`](../PreInstall/README.md).

## 0. Read first
- [ ] Skim [`QUICKSTART.md`](QUICKSTART.md) and [`GLOSSARY.md`](GLOSSARY.md).
- [ ] **Back up the target disk** — the install erases it (see [`HARDWARE.md`](HARDWARE.md) §disks).
- [ ] Keep a **known-good rescue USB** (see [`RECOVERY.md`](RECOVERY.md)).

## 1. Machine
- [ ] `./PreInstall/check-hardware.sh` → PASS (or only warnings you understand).
- [ ] It's a ThinkCentre **M920s** (board `3132`), i7-9700, UHD 630, Q370.
- [ ] `./PreInstall/check-msr.sh` (as root) → CFG Lock **locked** ⇒ `AppleXcpmCfgLock=true`.

## 2. EFI
- [ ] `./PreInstall/check-efi.sh` → PASS.
- [ ] `./PostInstall/ocvalidate.linux EFI/OC/config.plist` → *No issues found*.
- [ ] [`VERSIONS.md`](VERSIONS.md) matches what's on the USB.
- [ ] Optional: `./PreInstall/verify-upstream.sh` → bundled binaries match upstream. ✅

## 3. BIOS (see [`BIOS.md`](BIOS.md))
- [ ] Secure Boot **Disabled**.
- [ ] CSM / Legacy **Disabled** (pure UEFI).
- [ ] Primary display = **iGPU** (IGD).
- [ ] SATA = **AHCI** (not RAID).
- [ ] VT-d: either leave on (`DisableIoMapper=true` handles it) or Disable.
- [ ] Above-4G decoding: leave as the board default (no `npci=` needed here).

## 4. Installer USB
- [ ] `./PreInstall/stage-installer.sh` produced `installer-usb/`.
- [ ] USB is **GUID/FAT32**; `EFI/` and `com.apple.recovery.boot/` are at the **root**.
- [ ] Recovery is **Sonoma 14.x** for board-id `Mac-AA95B1DDAB278B95` (iMac19,1).
- [ ] Boots to the OpenCore picker.

## 5. Boot test (before wiping anything)
- [ ] Picker shows the macOS installer entry.
- [ ] Verbose (`-v`) reaches the installer UI without panic.
- [ ] Keyboard/mouse work (USB 2 rear port is the safe bet).

## 6. Ready
- [ ] All above ticked → proceed with [`INSTALL.md`](INSTALL.md).
- [ ] After install, run [`POST-INSTALL.md`](POST-INSTALL.md).
