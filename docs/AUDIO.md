# Audio (Realtek ALC233)

**Target:** Realtek **ALC233** on the Intel cAVS HD Audio controller (`8086:A348`), codec PCI id
`10EC:0235`. Driven by **AppleALC**.

## How it's enabled here
| Piece | Value | Why |
|---|---|---|
| `AppleALC.kext` | enabled | patches AppleHDA for the codec |
| `boot-args` | `alcid=3` | selects the **ALC233 layout 3** |
| (alternative) `DeviceProperties` | `layout-id` on `PciRoot(0x0)/Pci(0x1f,0x3)` | same thing, injected instead of the boot-arg |
| `SSDT-HPET` | **not** shipped | only needed if every layout fails (verified safe to add) |

## ALC233 layouts (AppleALC 1.9.8)
Valid layout-ids for this codec: **`3, 4, 5, 13, 21, 27, 28, 29, 32, 33`**.

> Layout **`3`** is the default here. If you get no sound, silence, or a dead jack, **try the others
> one at a time** — change `alcid=N` in `NVRAM → boot-args`, reboot, and test.

## Verify (macOS)
```bash
kextstat | grep -i applealc
system_profiler SPAudioDataType | head -40
# the codec + connected jacks should be listed as an output device
```

## Troubleshooting order
1. **Wrong layout** — walk the list above with `alcid=N`.
2. Still nothing after **wake from sleep** → add `SSDT-HPET` + the 5 verified DSDT renames
   (see [`FIRMWARE-ANALYSIS.md`](FIRMWARE-ANALYSIS.md) §3 and [`OPTIONAL-COMPONENTS.md`](OPTIONAL-COMPONENTS.md)).
3. Enable the debug build of `AppleALC` and read `log show --predicate 'process == "kernel"' | grep -i applealc`.
4. Confirm the codec is really ALC233: `cat /proc/asound/card0/codec#0 | head -1` on Linux.

## Notes
- macOS matches by PCI, so the DSDT device name (`HDAS`) is irrelevant.
- This is a **desktop**: no laptop-specific `CodecCommander`/jack-sense workarounds are needed.
