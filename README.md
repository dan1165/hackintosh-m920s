# ThinkCentre M920s — OpenCore Hackintosh (macOS Sonoma)

A complete, machine-tailored OpenCore 1.0.8 EFI for the exact hardware in this
machine. Every file here was generated from your own firmware dump, PCI scan,
and DSDT — not from a generic template.

> **Read [`RELIABILITY-AUDIT.md`](RELIABILITY-AUDIT.md) first** — it documents the
> firmware-level verification (CFG Lock, AWAC/RTC, PMC, EC, MMIO) that this build is
> based on, plus the corrections applied for reliability.

---

## 1. Target machine (as detected)

| Component | Detail | macOS status |
|---|---|---|
| Model | Lenovo ThinkCentre M920s (10SKS5KF00), board 3132 | — |
| BIOS | LENOVO M1UKT79A 1.121 (2026-03-12, AMI) | — |
| CPU | Intel Core i7-9700 (Coffee Lake Refresh), 8C/8T | ✅ native |
| Chipset | Intel Q370 (Cannon Lake PCH) | ✅ |
| iGPU | Intel UHD Graphics 630 `8086:3E98` | ✅ Metal |
| dGPU | none | — |
| RAM | 16 GB (2×8 GB Samsung DDR4-2666, dual channel) | ✅ |
| Storage | WDC PC SN730 512 GB NVMe `15b7:5006` | ✅ native |
| Ethernet | Intel I219-LM `8086:15BB` | ✅ IntelMausi |
| Audio | Realtek ALC233 `10EC:0235` (cAVS `8086:A348`) | ✅ AppleALC |
| USB | Cannon Lake xHCI `8086:A36D` (16×USB2 / 10×USB3) | ⚠️ remap on-device |
| Wi-Fi/BT | **none supported** (tested RTL8851BU USB combo → rejected) | ❌ Ethernet-only |
| Display out | 2× DisplayPort (VGA not usable) | ✅ |

SMBIOS: **iMac19,1** · Serial `C02C80E9JV3Q` · MLB `C020077004NLNV91F` · ROM = onboard MAC `6C:4B:90:CE:BA:90`.

---

## 2. What's in this folder

```
EFI/OC/
├─ config.plist              tailored OpenCore 1.0.8 config (validated clean)
├─ ACPI/                     SSDT-AWAC, SSDT-EC-USBX, SSDT-PLUG, SSDT-PMC,
│                            SSDT-SBUS-MCHC  (+ SSDT-RHUB, disabled)
├─ Kexts/                    Lilu, VirtualSMC(+SMCProcessor/SMCSuperIO),
│                            WhateverGreen, AppleALC, IntelMausi, NVMeFix,
│                            RestrictEvents  (+ CPUFriend, USBToolBox, disabled)
├─ Drivers/                  OpenRuntime, OpenHfsPlus, OpenCanopy, AudioDxe,
│                            ResetNvramEntry, HiiDatabase
└─ Tools/                    OpenShell, ResetSystem, ControlMsrE2, RtcRw
PostInstall/                 macserial, ocvalidate, macrecovery, USBToolBox,
                             CPUFriend tools  (helpers for after install)
```

The ACPI tables used to derive these SSDTs are archived in the session's
`/tmp/opencode/acpi_dump` (DSDT + SSDT1-18 + all others).

---

## 3. BIOS setup (Lenovo M920s) — do this first

Enter BIOS with **F1** (or Enter/F12 for the boot menu).

**Security**
- Secure Boot → **Disabled**
- Device Guard → **Disabled**
- Intel(R) SGX Control → **Disabled**
- Chassis Intrusion Detection → **Disabled**

**Startup**
- **OS Optimized Defaults → Disabled** (critical on Lenovo — otherwise it force-locks
  Windows/secure-boot defaults)
- CSM → **Disabled** (already)
- Boot Mode → **UEFI Only**
- Fast Boot → **Disabled**
- (leave Boot Order; we'll add the USB/OC entry)

**Devices → Video Setup**
- Select Active Video → **IGD** (iGPU)
- Pre-Allocated Memory Size → **64 MB**
- Total Graphics Memory → **Maximum**

**Devices → ATA Drive Setup**
- Configure SATA as → **AHCI** (already)

**Advanced → CPU Setup**
- Intel(R) Virtualization Technology → **Enabled**
- Intel(R) Hyper-Threading → n/a (i7-9700 has none)

**Advanced (if present)**
- VT-d → **Disabled** (the EFI also sets `DisableIoMapper=true`)
- Intel(R) Manageability Control / AMT → Disabled (optional, cleaner boot)

> **CFG Lock is confirmed LOCKED on this machine** (`MSR 0xE2 = 0x1E008008`, bit 15 set —
> verified by reading the MSR from the running host). This EFI therefore sets
> `AppleXcpmCfgLock=true`, which is **required**. If you want to unlock it properly, boot
> OpenCore → Tools → `ControlMsrE2` and follow its prompts, then set
> `AppleXcpmCfgLock=false`.

---

## 4. Making the installer USB (from Linux)

You do **not** need a Mac.

1. Get a 16 GB+ USB stick; it will be erased.
2. Create a single **FAT32** partition:
   ```bash
   sudo parted -s /dev/sdX mklabel gpt
   sudo parted -s /dev/sdX mkpart ESP fat32 1MiB 100%
   sudo mkfs.vfat -F32 -n OPENCORE /dev/sdX1
   ```
3. Download the Sonoma recovery into `com.apple.recovery.boot`:
   ```bash
   cd /mnt/usb
   python3 /root/hackintosh/PostInstall/macrecovery/macrecovery.py \
       -b 00000000-0000-0000-0000-000000000000 -m mac-AA95B1DDAB278B95 \
       download
   # (if the board-id fails, run:  python3 macrecovery.py -b -m  download  --help)
   ```
   This creates `com.apple.recovery.boot/BaseSystem.dmg` + `.chunklist`.
4. Copy the whole `EFI/` folder from this project to the **root** of the same USB
   partition, so you end up with:
   ```
   USB/
   ├─ EFI/BOOT/BOOTx64.efi
   ├─ EFI/OC/...
   └─ com.apple.recovery.boot/{BaseSystem.dmg,BaseSystem.chunklist}
   ```
5. Eject and boot the machine from the USB (F12 → your USB device).
6. In OpenCore picker choose **macOS Base System** → Disk Utility → erase the
   target disk/partition as **APFS GUID** → install Sonoma.

> Alternative if you have access to any Mac: create a normal
> `createinstallmedia` Sonoma USB and just drop this `EFI/` onto its EFI
> partition (replacing any existing one).

---

## 5. Installation notes

- First boot is verbose (`-v keepsyms=1`). Once stable, edit `config.plist` →
  `NVRAM → Add → 7C436110… → boot-args` and remove `-v`.
- `alcid=11` is set as a boot-arg for the ALC233. If audio doesn't work, see
  §6.
- Wireless is intentionally absent — use Ethernet. Wi-Fi/BT kexts are **not**
  included.
- After install, mount the EFI partition of the macOS disk and copy this `EFI/`
  there so it boots on its own; then add it to the BIOS boot order.

---

## 6. Post-install tuning

### 6a. Audio (ALC233, layout-id)
Layout `3` is the default. AppleALC's supported layouts for the **ALC233** are
`3, 4, 5, 13, 21, 27, 28, 29, 32, 33` (layout 11 is **not** valid for this codec).
If audio is silent or wrong, try these in order by editing **either** `boot-args`
(`alcid=N`) **or** `DeviceProperties → PciRoot(0x0)/Pci(0x1F,0x3) → layout-id`
(hex, e.g. `03000000` = 3):

`3 → 13 → 21 → 4 → 5 → 27 → 28 → 29 → 32 → 33`

Always run **Tools → ResetNvramEntry** (or reboot) after each change, since a
previously-set layout is cached.

Use the built-in `Tools → ResetNvramEntry` or just reboot after each change.
An optional HPET IRQ fix (`SSDT-HPET` + DSDT renames) may be needed on a few
desktops; it is documented in the Dortania post-install audio guide if none of
the layouts above work.

### 6b. USB port mapping (recommended)
By default macOS exposes only the first 15 controller ports, so your **USB 3
ports fall back to USB 2 speeds**. To fix this properly:

1. Boot macOS with the current EFI (USB 2 works everywhere).
2. Run **USBToolBox** (`PostInstall/USBToolBox-1.2.0-RELEASE.zip`) from Windows
   or macOS, plug a device into every port, and **K → Build UTBMap.kext**.
3. Copy the generated `UTBMap.kext` into `EFI/OC/Kexts`.
4. In `config.plist → Kernel → Add`, enable **both** `USBToolBox.kext` and
   `UTBMap.kext` (in that order).
5. Keep `UEFI → Quirks → XhciPortLimit = false` (do **not** enable it).

### 6c. CPU power management (optional)
Native XCPM works out of the box via `SSDT-PLUG` + iMac19,1. To pin a custom
frequency profile, use `PostInstall/CPUFriend-Tools/ResourceConverter.sh` to
build `CPUFriendDataProvider.kext` from an iMac19,1 `FrequencyVectors` file,
add it to `Kexts/`, and enable `CPUFriend.kext` in the config.

### 6d. Wi-Fi / Bluetooth — **DECISION: Ethernet-only**

No wireless kexts are included in this EFI. **Use the Intel I219-LM Ethernet**
(fully supported). Only add wireless if you install a *supported* card.

**Tested and REJECTED (do not use):** a TP-Link Realtek **RTL8851BU** USB
Wi-Fi 6 + BT combo dongle was plugged in and probed. It is **incompatible with
macOS on both halves**:

| Half | Chip | macOS result | Why |
|---|---|---|---|
| Wi-Fi | Realtek **RTL8851BU** (`3625:010B`, rtw89 / 802.11ax) | ❌ no driver | chris1111's driver covers only 802.11n/ac (8188/8192/8811/8812/8821); no rtw89 support exists |
| Bluetooth | Realtek **RTL8851BU** BT | ❌ no driver | the only Realtek USB-BT kext (`RTLBluetoothFirmware`) matches RTL8761B/U only |

Additional blockers: macOS never performs the dongle's ZeroCD→WLAN mode switch
(it stays a fake "CD"), and USB dongles give no AirDrop/Handoff anyway.

**If you want wireless later, in order of preference:**
1. **BCM94360NG** (M.2 2230 E-key or PCIe adapter) → native Wi-Fi **and** BT,
   AirDrop/Handoff/Continuity, no extra kexts. **Recommended.**
2. **Intel AX200/AX210** → Wi-Fi via `AirportItlwm`, BT via `IntelBluetoothFirmware`
   (no native AirDrop).
3. Any Realtek 802.11**n/ac** USB dongle on chris1111's list (Wi-Fi only, no AirDrop).

Verify the board has a free M.2 E-key slot before buying.

### 6e. Fallback SMBIOS (iGPU-only)
The config uses **iMac19,1** (matches the 8-core CPU and is supported through Tahoe).
Because this machine is **iGPU-only**, **Macmini8,1** (which natively ships the UHD 630)
is a valid alternative if you hit graphics/power weirdness. A ready-to-use pair was
generated for you:

```
SystemProductName: Macmini8,1
SystemSerialNumber: C07LPYZ4JYVX
MLB: C07346902GUKXPGJA
```

To switch: `PlatformInfo → Generic → SystemProductName`, set the serial/MLB above, keep
the same `SystemUUID` and `ROM`. Re-validate the config afterwards.

---

## 7. Known limitations

- **VGA output** on the rear panel is analog and not supported by macOS — use
  the two DisplayPort outputs.
- **USB 3 SuperSpeed** requires the on-device map in §6b; until then USB 3
  devices run at USB 2 speed.
- **No Wi-Fi/Bluetooth/AirDrop.** Confirmed decision: **Ethernet-only.** A
  Realtek RTL8851BU USB Wi-Fi6+BT dongle was physically tested and is
  incompatible on both halves (see §6d). Add a **BCM94360NG** later if needed.
- **Secure Boot must stay disabled.**
- The SN730 logs harmless correctable PCIe `RxErr` messages; `NVMeFix` is
  included and mitigates power-management issues.

---

## 8. Troubleshooting quick map

| Symptom | Fix |
|---|---|
| Black screen after verbose, iGPU | Try `AAPL,ig-platform-id = 00009B3E` (hex `00009B3E`) |
| Stuck at “EXITBS:START” | Keep `ProtectUefiServices=true`; toggle `Booter → Quirks → DevirtualiseMmio` |
| No NVRAM persistence | Ensure `SSDT-PMC.aml` is enabled |
| Instant reboot at start | Verify `AppleXcpmCfgLock=true` (CFG Lock) |
| USB ports missing/odd | Enable `SSDT-RHUB.aml`, then remap (§6b) |
| Audio silent, all layouts fail | Add SSDT-HPET + DSDT IRQ renames |
| Boots but “Unsupported CPU” banner | `RestrictEvents` already handles this |

Validate any edit to the config with:
```bash
./PostInstall/ocvalidate.linux EFI/OC/config.plist
```

---

## 9. Reproducing the SMBIOS

New valid iMac19,1 serial/MLB pairs can be generated with the bundled tool:
```bash
./PostInstall/macserial.linux -m iMac19,1 -n 1
```
Keep the **same** serial, MLB, UUID and ROM once iMessage/FaceTime are working.

---

*Generated for user `PC1B10YM` / ThinkCentre M920s · OpenCore 1.0.8 ·
Lilu 1.7.2 · VirtualSMC 1.3.8 · WhateverGreen 1.7.1 · AppleALC 1.9.8 ·
IntelMausi 1.0.8 · NVMeFix 1.1.3 · RestrictEvents 1.1.6 · CPUFriend 1.3.0 ·
USBToolBox 1.2.0.*
