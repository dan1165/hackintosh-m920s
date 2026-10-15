# Network

**Target:** Intel **I219-LM** Gigabit Ethernet (`8086:15BB`) — natively supported via `IntelMausi`.

## Wired (works out of the box)
| Piece | Value |
|---|---|
| `IntelMausi.kext` | enabled |
| SMBIOS `ROM` | set to this NIC's MAC (`6C:4B:90:CE:BA:90`) for iMessage/App Store identity |

```bash
kextstat | grep -i mausi
networksetup -listallhardwareports | grep -A2 Ethernet
ifconfig en0 | grep ether
```

## Wireless (optional)
This build is **Ethernet-only** because no supported Wi-Fi card is fitted. Options and the full USB
dongle list (chips that *do* have a macOS kext) are in [`UPGRADES.md`](UPGRADES.md) and
[`OPTIONAL-COMPONENTS.md`](OPTIONAL-COMPONENTS.md).

| Route | Effort | AirDrop/Handoff |
|---|---|---|
| Onboard Ethernet (I219-LM) | none | — |
| BCM94360 card (M.2/PCIe) | hardware only | ✅ |
| Intel AX200/AX210 + `AirportItlwm` + `IntelBluetoothFirmware` | 2 kexts | ❌ |
| Supported Realtek USB dongle (RTL8812AU/8812BU/…) | 1 closed kext, SIP off | ❌ |
| Phone **USB tethering** | none | — (shares the phone's link) |

> Any **Wi-Fi 6 / 802.11ax** USB stick (RTL8851BU/8852xx) has **no** macOS driver.

## Verify a new Wi-Fi card
```bash
system_profiler SPAirPortDataType | head -40
kextstat | grep -iE "AirportItlwm|IntelBluetooth|Realtek"
```

## iMessage / FaceTime prerequisites
1. Ethernet connected.
2. Valid SMBIOS serial/MLB/UUID + `ROM` = MAC (see [`SECURITY-PRIVACY.md`](SECURITY-PRIVACY.md)).
3. Sign in once; if it fails, reset NVRAM and retry.

## Symptoms → cause
| Symptom | Cause |
|---|---|
| No Ethernet | `IntelMausi` not loaded / wrong kext |
| Ethernet works but no iMessage | SMBIOS serial/ROM mismatch |
| Wi-Fi never appears | the chip has no macOS driver (see above) |
