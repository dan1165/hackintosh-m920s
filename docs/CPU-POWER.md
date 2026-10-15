# CPU & power management

**Target:** Intel Core i7-9700 (Coffee Lake Refresh, 8C/8T) — handled natively by macOS via **XCPM**
(no spoof, no kernel patch).

## How it's enabled here
| Piece | Value | Why |
|---|---|---|
| `SSDT-PLUG` | injects `plugin-type = 1` into `\_SB.PR00` | tells macOS to use **XCPM** (not legacy AICPM) |
| `Kernel → Quirks → AppleXcpmCfgLock` | `true` | CFG Lock is **locked** on this board (`rdmsr 0xE2` bit 15 set) |
| `Kernel → Quirks → AppleCpuPmCfgLock` | `false` | only for legacy AICPM |
| `SSDT-PLUG` target | `\_SB.PR00` | verified: DSDT defines `Processor (PR00…PR15)` |

## Verify (macOS)
```bash
sysctl machdep.xcpm.mode          # -> 1
sysctl machdep.xcpm.vectors_loaded_count
pmset -g                          # sleep/power settings
sudo powermetrics --samplers cpu_power -n1 | head
```
`pmset -g log | grep -i "CPU_Scheduler"` should show normal P-state transitions.

## P-states / frequency
XCPM manages P-states automatically from the CPU's capabilities. macOS reads the turbo tables; no
`SSDT-PLUG`-adjacent patch is needed on CFL-R. If you want to *force* a profile:
```bash
# optional: build a CPUFriend DataProvider (see docs/OPTIONAL-COMPONENTS.md)
./PostInstall/ResourceConverter.sh --kext /path/to/iMac19_1.plist
# then enable CPUFriend.kext + CPUFriendDataProvider.kext in config.plist
```

## Unlocking CFG Lock (optional)
If you want `AppleXcpmCfgLock=false` (less patching):
1. Picker → **ControlMsrE2** tool → clear the lock (or use the BIOS if it exposes it).
2. `rdmsr 0xE2` to confirm bit 15 is clear.
3. Set `AppleXcpmCfgLock=false`, `ocvalidate`, reboot.

## Symptoms → cause
| Symptom | Check |
|---|---|
| High idle / hot | `machdep.xcpm.mode` = 0 → `SSDT-PLUG` missing/mis-scoped |
| Kernel panic mentioning `AppleIntelCPUPowerManagement` | an AICPM path is being used — ensure `AppleCpuPmCfgLock=false` and `plugin-type=1` |
| No turbo | confirm BIOS turbo is enabled; check `powermetrics` |
