# Graphics (Intel UHD 630)

**Target:** Intel UHD Graphics 630 (`8086:3E98`), iGPU-only (no discrete GPU). Native **Metal**
acceleration.

## How it's enabled here
| Piece | Value | Why |
|---|---|---|
| `DeviceProperties → PciRoot(0x0)/Pci(0x2,0x0)` | `AAPL,ig-platform-id = 07009B3E` (`0x3E9B0007`) | the Coffee Lake desktop framebuffer (iMac19,1 class) |
| …same | `framebuffer-patch-enable = 01000000` | enables the framebuffer patch |
| …same | `framebuffer-stolenmem = 00003001` (19 MB) | DVMT workaround so macOS allocates its own stolen memory |
| `WhateverGreen.kext` | enabled | framebuffer patches, backlight/DP fixes, IGPU naming |

`ig-platform-id 0x3E9B0007` is the value matched to the **iMac19,1** SMBIOS and a display-attached
iGPU. `framebuffer-stolenmem` avoids relying on the BIOS DVMT-prealloc size.

## Verify (macOS)
```bash
ioreg -l | grep -i "AAPL,ig-platform-id"          # -> appears on the IGPU node
system_profiler SPDisplaysDataType | head -30     # shows "Intel UHD Graphics 630", Metal family
# Optional: Metal / HW accel
system_profiler SPDisplaysDataType | grep -i metal
```

## Headless iGPU (only if you add a dGPU)
Switch the platform-id to `0300913E` (`0x3E910003`) so the iGPU keeps doing **video encode/decode**
while the dGPU drives the display. Then add `-radcodec`/GPU device-properties for the dGPU. See
[`UPGRADES.md`](UPGRADES.md).

## Known limitation
**DRM** (Apple TV, Netflix in Safari) requires a supported dGPU with HW DRM; the iGPU alone cannot
play protected content in those apps.

## Symptoms → cause
| Symptom | Cause |
|---|---|
| Black screen / no signal after boot | wrong `ig-platform-id` for the port; try `0x3E9B0007` (DP) or a `-igfxfw`/`-igfxvesa` diagnostic boot |
| No Metal / "no acceleration" | `WhateverGreen` not loaded, or platform-id malformed |
| Display works, no audio over DP | DP audio needs the right layout + `AppleALC`; check [`AUDIO.md`](AUDIO.md) |
