# Quick Start

**Goal:** install macOS Sonoma on a Lenovo ThinkCentre M920s using the EFI in this repo.

> If you read only one page, read this one. ~10 minutes of prep, then a normal macOS install.

---

## What you need
- The ThinkCentre M920s (i7-9700 / Q370 / UHD 630).
- A **16 GB+ USB stick** (it will be erased).
- **Wired Ethernet** (the installer downloads ~12 GB).
- A **DisplayPort** monitor (VGA will not work).
- This repo (or the `ThinkCentre-M920s-Sonoma-OC1.0.8.zip` release).

## The 4 steps

### 1. Flash the USB (from any Linux machine)
```bash
lsblk                       # find your USB → /dev/sdX
sudo umount /dev/sdX* 2>/dev/null
sudo sgdisk --zap-all /dev/sdX
sudo sgdisk -n 1:0:0 -t 1:EF00 -c 1:OPENCORE /dev/sdX
sudo partprobe /dev/sdX
sudo mkfs.vfat -F32 -n OPENCORE /dev/sdX1
sudo mkdir -p /mnt/oc && sudo mount /dev/sdX1 /mnt/oc
cd /mnt/oc
python3 /path/to/PostInstall/macrecovery/macrecovery.py -b Mac-827FAC58A8FDFA22 -m 00000000000000000 download
sudo cp -r /path/to/EFI /mnt/oc/EFI
sudo sync && sudo umount /mnt/oc
```
Detailed version: [`INSTALL.md`](INSTALL.md).

### 2. Set the BIOS (press **F1**)
- `OS Optimized Defaults` → **Disabled**
- `Secure Boot` → **Disabled**
- `CSM` → **Disabled**, `Boot Mode` → **UEFI Only**
- `Select Active Video` → **IGD**, `Pre-Allocated Memory` → **64 MB**
- `SATA` → **AHCI**

Full list with reasons: [`BIOS.md`](BIOS.md).

### 3. Install
1. Insert the USB, press **F12**, pick **UEFI: your USB**.
2. OpenCore picker → **macOS Base System**.
3. Disk Utility → **Show All Devices** → select the **SN730 disk** → **Erase** as **APFS / GUID**.
4. Quit → **Install macOS Sonoma** → pick the disk → let it reboot a few times.

### 4. Move the EFI to the internal disk
In macOS Terminal:
```bash
diskutil list                 # internal EFI = small ~200MB, usually disk0s1
sudo diskutil mount disk0s1
sudo cp -r /Volumes/OPENCORE/EFI /Volumes/EFI/
sudo bless --mount /Volumes/EFI --setBoot --file /Volumes/EFI/EFI/BOOT/BOOTx64.efi
```

Done. Reboot without the USB.

---

## After it boots
| Task | Page |
|---|---|
| Fix audio (ALC233 layout trial) | [`POST-INSTALL.md`](POST-INSTALL.md) |
| Get USB 3 speeds (port map) | [`POST-INSTALL.md`](POST-INSTALL.md) |
| iMessage / FaceTime | [`POST-INSTALL.md`](POST-INSTALL.md) |
| Something broke | [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) |

## New to hackintosh terms?
Read [`GLOSSARY.md`](GLOSSARY.md) — it explains OpenCore, kexts, SSDTs, SMBIOS, etc. in plain language.

---

⚠️ **This install erases the internal disk.** Back up first. See [`FAQ.md`](FAQ.md).
