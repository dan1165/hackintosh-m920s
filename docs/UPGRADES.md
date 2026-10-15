# Upgrades & Optional Hardware

This build is **Ethernet-only** by decision. Here's how to add more later.

## Wi-Fi / Bluetooth
There is no supported wireless card installed. Ranked options:

| Option | Bus | Wi-Fi | Bluetooth | AirDrop/Handoff | Kexts needed |
|---|---|---|---|---|---|
| **BCM94360NG** | M.2 2230 E-key or PCIe adapter | ✅ native | ✅ native | ✅ | none |
| Intel **AX200 / AX210** | M.2 E-key | ✅ `AirportItlwm` | ✅ `IntelBluetoothFirmware` | ❌ | 2 |
| Realtek 802.11**n/ac** USB (see table below) | USB | ✅ | ❌ | ❌ | 1 (closed-source) |

### USB Wi-Fi dongles that *do* have a macOS driver
No USB Wi-Fi dongle works out of the box — Apple only ships drivers for its own Broadcom chips.
The community driver **[chris1111 / Wireless-USB-OC-Big-Sur-Adapter](https://github.com/chris1111/Wireless-USB-OC-Big-Sur-Adapter)**
(V17, macOS 10.14.6 → **Tahoe 26**, **Intel only**) supports these Realtek chips:

| Chip | Class | Example dongles |
|---|---|---|
| **RTL8812AU** | AC1200 | Alfa AWUS036AC / AWUS036ACH, TP-Link Archer T4U, Netgear A6100 / A7000, ASUS USB-AC56, D-Link DWA-182 |
| **RTL8812BU / RTL8822BU** | AC1300 | Cudy WU1300S / WU1400, COMFAST CF-811AC / CF-812AC, Fenvi AC1300, TechKey AC1200, EDUP EP-AC1689 |
| **RTL8814AU** | AC1900 | ASUS USB-AC68, D-Link DWA-192, TP-Link Archer T9UH |
| **RTL8811AU** | AC600 | TP-Link Archer T2U Plus / T2U Nano, many generic "AC600" sticks |
| **RTL8188 / RTL8192 / RTL8723BU** | N150 / N300 | cheap 2.4 GHz sticks |

- Installed as a **`.pkg` inside macOS** (not an EFI kext); needs **SIP disabled**
  (`csrutil disable`), sometimes **`SecureBootModel = Disabled`**, then a reboot.
- Some sticks ship as a fake CD-ROM and need a **usb_modeswitch** step first.
- Give it a full-speed port with `docs/USB-MAP.md`.

❌ **No Wi-Fi 6 / 802.11ax USB dongle has a macOS driver** — RTL8851BU / 8852AU / 8852BU class
chips are Linux-only (`rtw89`).

**Rejected (tested):** the installed TP-Link Realtek **RTL8851BU** USB Wi-Fi 6 + BT combo
(`3625:010B`) — no macOS driver for either half, and macOS can't do its ZeroCD switch.

⚠️ Even a working USB dongle gives **no AirDrop/Handoff/Continuity**. For those, use a Broadcom card.

## Discrete GPU
The M920s has a full **PCIe x16** slot. A supported AMD card enables **DRM** (Apple TV,
Netflix in Safari) and more GPU power:

| Card | Notes |
|---|---|
| Radeon **RX 570 / 580** (8 GB) | Best value; natively supported; needs a low-profile/bracket check in SFF |
| Radeon **RX 6600 / 6800** (Navi 23/21) | Newer, supported on Sonoma; more power |
| Avoid | NVIDIA (no modern drivers), Intel Arc |

With a dGPU you'd switch the iGPU to **headless** (`AAPL,ig-platform-id = 0300913E`) so it
keeps doing video encode/decode. Ask in the repo/issues and this can be added as a variant.

## Storage
- The SN730 NVMe is fine and fast. A second M.2/SATA SSD can be added for dual-boot.
- To **keep Proxmox** and install macOS alongside, install macOS to a *second* disk — do
  not erase the SN730.

## Memory
- 2 free DIMM slots; up to **64 GB** DDR4-2667. Adding a matching pair keeps dual-channel.

## CPU
- Socket is LGA1151 (300-series). The i7-9700 is near the top for this platform; an i9-9900
  is the ceiling (with a suitable BIOS). Not required.

## Display
- Use the two **DisplayPort** outputs. The rear **VGA** port is analog and macOS has no driver.
