# Power, sleep & wake

Desktop power behaviour: sleep/wake, restart/shutdown, and the ACPI bits behind them.

## What's configured here
| Piece | Value | Why |
|---|---|---|
| `SSDT-AWAC` | forces legacy **RTC** (disables AWAC) | Windows/macOS clock + wake behaviour |
| `SSDT-PMC` | adds the 300-series **PMC** device | native NVRAM |
| `Misc → Boot → HibernateMode` | `None` | disables S4 hibernate (matches most desktop setups) |
| `ACPI → Quirks → FadtEnableReset` | `false` | ACPI reset register is present, so not needed |
| `SSDT-PLUG` + `AppleXcpmCfgLock` | see [`CPU-POWER.md`](CPU-POWER.md) | idle/hot states |

## Verify (macOS)
```bash
pmset -g
pmset -g log | grep -iE "wake|sleep" | tail
sudo pmset -g assertions
```

## Common tweaks
| Goal | Change |
|---|---|
| Disable sleep entirely | `sudo pmset -a sleep 0 disablesleep 1` (or System Settings → Lock Screen) |
| Wake for network access | `sudo pmset -a womp 1` |
| Fix instant-wake | check what woke it: `pmset -g log`; USB devices are the usual cause → `USBWakeFixup` (see [`OPTIONAL-COMPONENTS.md`](OPTIONAL-COMPONENTS.md)) |
| Reboot hangs on shutdown | ensure `FadtEnableReset` is `false` here; try the `ResetSystem` picker tool to confirm the platform can reset |

## Restart / shutdown from the picker
The `ResetSystem.efi` tool (registered in `Misc → Tools`) can reboot or power off even if macOS
misbehaves.

## Symptoms → cause
| Symptom | Cause |
|---|---|
| Clock wrong after sleep | `SSDT-AWAC` not applied (AWAC still active) |
| Won't stay asleep | a USB device is waking it (see `pmset -g log`) |
| Slow wake / black screen on wake | GPU framebuffer — see [`GRAPHICS.md`](GRAPHICS.md) |
