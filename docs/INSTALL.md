# Installation Guide — macOS Sonoma on the ThinkCentre M920s

Follow in order. Total time ≈ 45–90 min (mostly downloads).
Everything in **§1–§3** is done *from the running Linux host*.
Everything in **§4 onward** is done *from the macOS installer*.

---

## ⚠️ 0. Before you start — read this

- **This erases the target disk completely.**
  Back up anything you need first.
- Keep the machine on **Ethernet** (the install downloads ~12 GB from Apple).
  **Wireless is Ethernet-only by decision** — the tested RTL8851BU USB dongle is
  incompatible with macOS (see `UPGRADES.md`).
- Use a **DisplayPort** monitor output, **not VGA**.
- Keep the USB stick you build in §1 — it doubles as your recovery disk.
- If you'd rather **keep an existing OS**, skip this and install to a *second* SSD instead
  (same steps, just pick the second disk in §5).

---

## 1. Build the installer USB (from the Linux host)

**1.1** Plug in a 16 GB+ USB stick and identify it (**this is the part that gets erased**):

```bash
lsblk -o NAME,SIZE,TYPE,TRAN,MODEL
```

Assume it is `/dev/sdX` below — replace with the real name.

**1.2** Partition and format it as a single FAT32 EFI volume:

```bash
sudo umount /dev/sdX* 2>/dev/null
sudo sgdisk --zap-all /dev/sdX
sudo sgdisk -n 1:0:0 -t 1:EF00 -c 1:OPENCORE /dev/sdX
sudo partprobe /dev/sdX
sudo mkfs.vfat -F32 -n OPENCORE /dev/sdX1
sudo mkdir -p /mnt/oc
sudo mount /dev/sdX1 /mnt/oc
```

**1.3** Download the **Sonoma** recovery image into it:

```bash
cd /mnt/oc
python3 /root/hackintosh/PostInstall/macrecovery/macrecovery.py \
    -b Mac-827FAC58A8FDFA22 -m 00000000000000000 download
```

This creates `com.apple.recovery.boot/` with `BaseSystem.dmg` + `BaseSystem.chunklist`.

**1.4** Copy the OpenCore EFI to the USB root:

```bash
sudo cp -r /root/hackintosh/EFI /mnt/oc/EFI
```

**1.5** Verify the layout, then unmount:

```bash
find /mnt/oc -maxdepth 2 -type d
# Expected:
#   /mnt/oc/EFI
#   /mnt/oc/EFI/BOOT        (BOOTx64.efi here)
#   /mnt/oc/EFI/OC
#   /mnt/oc/com.apple.recovery.boot
sudo sync
sudo umount /mnt/oc
```

---

## 2. BIOS settings

Enter BIOS with **F1** (or **F12** for the one-time boot menu).
Apply the checklist in `BIOS.md`. The essentials:

- **Startup → OS Optimized Defaults → Disabled**
- **Security → Secure Boot → Disabled**
- **Startup → CSM → Disabled**, **Boot Mode → UEFI Only**
- **Devices → Video Setup → Select Active Video → IGD**, **Pre-Allocated Memory → 64 MB**
- **Devices → ATA Drive Setup → Configure SATA as → AHCI**
- **Security → Device Guard / SGX → Disabled**
- *(optional)* **Advanced → VT-d → Disabled**

Save & exit.

---

## 3. Boot the installer

1. Insert the USB and power on; press **F12** and choose the **UEFI: <your USB>** entry.
2. The **OpenCore picker** (OpenCanopy, with icons) appears.
3. Select **macOS Base System** and press Enter.
4. It boots **verbose** (`-v`) — this is expected. First boot can take 1–3 minutes.
5. When the **macOS Utilities** window appears, you're in.

> If it hangs at the Apple logo with no progress, add `-v` is already on; note the last
> line and see `TROUBLESHOOTING.md`.

---

## 4. Erase the internal disk

1. Open **Disk Utility** → menu **View → Show All Devices**.
2. In the left pane select the **top-level** device
   **"WDC PC SN730 SDBQNTY-512G-1001"** (the *disk*, not a volume under it).
3. Click **Erase**:
   - Name: `Macintosh HD`
   - Format: **APFS**
   - Scheme: **GUID Partition Map**
4. **Erase**. (This wipes all existing partitions.)

---

## 5. Install Sonoma

1. Close Disk Utility to return to the Utilities window.
2. Choose **Install macOS Sonoma** (or "Reinstall macOS Sonoma") → **Continue**.
3. Select **Macintosh HD** → **Continue**.
4. The machine reboots several times. **Leave the USB inserted** and let OpenCore pick
   the default entry each time (it will alternate between the installer and the disk).
5. When **Setup Assistant** appears, complete it (region, language, **skip Apple ID**
   for now — add it later for iMessage).

---

## 6. Make the internal disk boot on its own

In macOS, open **Terminal**:

```bash
diskutil list                       # find the internal EFI (small ~200MB, usually disk0s1)
sudo diskutil mount disk0s1
```

Copy the EFI (from the USB, which is mounted as `/Volumes/OPENCORE` or similar):

```bash
ls /Volumes                       # identify OPENCORE and EFI volumes
sudo cp -r /Volumes/OPENCORE/EFI /Volumes/EFI/
```

Set it as the boot target:

```bash
sudo bless --mount /Volumes/EFI --setBoot --file /Volumes/EFI/EFI/BOOT/BOOTx64.efi
```

Eject the USB, reboot, and confirm it boots without the stick. If the BIOS doesn't pick
it automatically, press **F12/Enter** at power-on and choose the internal **"UEFI OS"** /
**OpenCore** entry, then move it to the top of the boot order.

> Tip: for a fully self-registering boot entry, set
> `Misc → Boot → LauncherOption = Full` in `config.plist` before copying it to the
> internal disk. Validate afterwards with `./PostInstall/ocvalidate.linux EFI/OC/config.plist`.

---

## 7. First-boot cleanup (recommended order)

1. **Reset NVRAM once:** OpenCore picker → **Tools / Reset NVRAM** (or space bar → Reset NVRAM).
2. **Remove verbose logging:** edit `config.plist → NVRAM → boot-args` and drop the `-v`
   (keep `keepsyms=1 alcid=3`). Re-validate.
3. **Audio:** if silent, walk the ALC233 layout list (`POST-INSTALL.md §3`): `3 → 13 → 21 → 4 → 5 → …`.
   Reset NVRAM between tries.
4. **USB 3 speeds:** run **USBToolBox** (`PostInstall/USBToolBox-1.2.0-RELEASE.zip`) and
   build `UTBMap.kext`, then enable it in the config (`POST-INSTALL.md §4`).
5. **iMessage/FaceTime:** sign in to your Apple ID. If it fails, do a fresh
   NVRAM reset and retry (the serial/MLB/ROM are already valid and consistent).
6. **Verify sensors/power:** install a tool like HWSensors/Stats; SMCSuperIO/SMCProcessor
   are already loaded.

---

## 8. If something goes wrong

| Stage | Symptom | Do this |
|---|---|---|
| Picker | USB not listed | Ensure you partitioned with an **EF00 EFI** partition and `EFI/BOOT/BOOT64.efi` exists |
| Early boot | Hangs instantly | Try `npci=0x2000` in boot-args; disable VT-d |
| Verbose | Stuck at `EXITBS:START` | Toggle `Booter → Quirks → DevirtualiseMmio`; keep `ProtectUefiServices=true` |
| Graphics | Black screen after `-v` | Switch `AAPL,ig-platform-id` to `00009B3E` |
| Installer | "This copy is damaged" | Re-download the recovery (§1.3); keep Ethernet connected |
| Audio | No output at all | Try every ALC233 layout, then consider SSDT-HPET |

Capture OpenCore logs for diagnosis by setting `Misc → Debug → Target = 67` (writes to
`EFI/OC/opencore-*.txt`).

---

*Everything referenced here lives in the repo (EFI/, PostInstall/, docs/).
Keep a copy of the USB — it is also your rescue disk.*
