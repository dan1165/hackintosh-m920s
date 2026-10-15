# Performance & tuning

Expected performance for this platform and where the knobs are.

## What the hardware gives you
| Subsystem | Expected |
|---|---|
| CPU | i7-9700, 8C/8T, up to 4.7 GHz turbo (XCPM-managed) |
| GPU | UHD 630 — fine for desktop/4K UI, weak for 3D |
| RAM | Dual-channel DDR4-2666 matters more than capacity for iGPU |
| NVMe | SN730 ~3 GB/s class (PCIe 3.0 ×4) |
| Ethernet | 1 Gb/s (I219-LM) |

## Where performance is lost (and how to check)
| Area | Check | Fix |
|---|---|---|
| GPU bandwidth | `system_profiler SPDisplaysDataType` | ensure **dual-channel RAM** (single-channel cripples the iGPU) |
| CPU states | `sysctl machdep.xcpm.mode` | must be `1`; see [`CPU-POWER.md`](CPU-POWER.md) |
| Storage | `diskutil info disk0 \| grep -i trim` | confirm APFS + TRIM; [`STORAGE.md`](STORAGE.md) |
| Thermal | `powermetrics` / sensors | clean the SFF heatsink; airflow matters in 1 L chassis |

## Benchmarks (optional, for a baseline)
- **CPU:** Geekbench 6, Cinebench R23.
- **GPU:** Metal (Geekbench Compute).
- **Disk:** `AmorphousDiskMark`, `diskutil` / Blackmagic.
- **Network:** `networkquality` (built into macOS since Monterey).

## Tuning that's safe vs not
| Safe | Risky / usually pointless |
|---|---|
| Dual-channel RAM | overclocking (BIOS is locked down; gains ≈ 0 for macOS) |
| Enable BIOS turbo/HT settings as available | `CPUFriend` profiles (native XCPM is already good) |
| Keep NVMe + APFS/TRIM | patching kernel for "faster" scheduling |
| Update OpenCore/kexts | disabling SIP/secure boot "for speed" (no effect) |

## iGPU-specific
- The UHD 630 shares system RAM; **dual-channel** can be a **large** graphics uplift.
- A supported dGPU (see [`UPGRADES.md`](UPGRADES.md)) is the real GPU upgrade, and enables DRM.
