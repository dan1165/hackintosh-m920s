# Known issues & limitations

Honest list of what doesn't work, what's untested, and the workaround for each.

## Hardware
| Issue | Severity | Workaround |
|---|---|---|
| **No Wi-Fi/Bluetooth** (Ethernet-only) | High if you need wireless | Onboard I219-LM works; add a Broadcom card (native) or a supported USB dongle — see [`UPGRADES.md`](UPGRADES.md) |
| **Rear VGA unusable** | Low | Use the two DisplayPort outputs |
| **No DRM in Safari** (Apple TV/Netflix) | Medium | iGPU-only; needs a supported dGPU (see UPGRADES) for hardware DRM |
| **USB 3 on `SS10`** runs at USB 2 speed | Low | Trimmed to keep within macOS's 15-port cap; accept it, or re-map with USBToolBox |
| **USB 3 ports at full speed depend on the shipped map** | Low | `USBPorts.kext` is included and enabled; regenerate if your board wiring differs |

## Firmware / platform
| Issue | Severity | Notes |
|---|---|---|
| **CFG Lock is locked** | Low | Handled by `AppleXcpmCfgLock=true`. Optionally unlock with OpenCore's `ControlMsrE2` tool, then set the quirk `false` |
| **`STAS`/AWAC** | Low | Handled by `SSDT-AWAC`; do **not** combine with an RTC patch |
| **Original disk is erased on install** | High | Back up first — the install replaces the Proxmox GPT. Install macOS to a second disk if you want to keep it |

## Software
| Issue | Severity | Notes |
|---|---|---|
| **Audio layout is a trial** (`alcid=3`) | Low | If no sound, try ALC233's other layouts `4, 5, 13, 21, 27, 28, 29, 32, 33` by changing `alcid=` |
| **iMessage/FaceTime** depend on Apple serial validation | Medium | The shipped serial is valid; if services fail, do the SMBIOS regen in [`MAINTENANCE.md`](MAINTENANCE.md) |
| **Closed-source USB Wi-Fi kexts** | — | No source, need SIP disabled, no AirDrop/Continuity — a project-level caveat, not a bug |

## Untested / out of scope
- **Discrete GPU** variant (would need a headless iGPU platform-id).
- **Major macOS upgrades** beyond the target version.
- **Other M920s revisions** (different BIOS or WLAN option) — hardware differences may apply.
- **Multiple monitors / hot-plug behaviour** beyond a basic 2× DisplayPort test.

## Reporting a new issue
Open a **Bug report** issue with the log and `ocvalidate` output — see [`SUPPORT.md`](../SUPPORT.md).
