# BIOS Settings (Lenovo M920s)

Enter BIOS with **F1** at power-on. One-time boot menu is **F12**.
Lenovo's menus vary slightly by firmware revision — this machine is `M1UKT79A 1.121`.

> Rule of thumb: we need a **pure UEFI, non-secure-boot, iGPU-primary, AHCI** system.

## Required

### Startup
| Setting | Value | Why |
|---|---|---|
| **OS Optimized Defaults** | **Disabled** | Otherwise Lenovo force-enables Windows/Secure-Boot defaults and hides options. |
| Boot Mode | **UEFI Only** | OpenCore is UEFI. |
| CSM | **Disabled** | macOS needs pure UEFI. |
| Fast Boot | **Disabled** | Gives you the picker and avoids skipping devices. |
| Boot Up Num-Lock | either | cosmetic |

### Security
| Setting | Value | Why |
|---|---|---|
| **Secure Boot** | **Disabled** | A hackintosh cannot boot with it on. |
| Device Guard | **Disabled** | Windows feature; ignore on macOS. |
| Intel(R) SGX Control | **Disabled** | Unused; avoids surprises. |
| Chassis Intrusion Detection | **Disabled** | Avoids spurious events. |

### Devices → Video Setup
| Setting | Value | Why |
|---|---|---|
| Select Active Video | **IGD** | Use the Intel iGPU (no dGPU installed). |
| Pre-Allocated Memory Size | **64 MB** | Enough DVMT for the framebuffer. |
| Total Graphics Memory | **Maximum** | Extra headroom. |

### Devices → ATA Drive Setup
| Setting | Value | Why |
|---|---|---|
| Configure SATA as | **AHCI** | macOS has no legacy IDE mode. |

## Recommended / optional
| Setting | Value | Notes |
|---|---|---|
| Intel(R) Virtualization Technology | **Enabled** | VT-x (needed if you run VMs). |
| VT-d | **Disabled** | Simpler boot; the EFI also sets `DisableIoMapper=true`. You may leave it Enabled if you need it. |
| Intel(R) Manageability Control / AMT | Disabled | Cleaner boot; not needed. |
| Above 4G Decoding | Enabled if present | Optional; the build works either way. |
| After Power Loss | Last State / Off | personal preference |

## About CFG Lock (MSR 0xE2)
This machine's firmware has **CFG Lock enabled** (verified: `MSR 0xE2 = 0x1E008008`, bit 15 set),
and Lenovo does not expose a toggle for it.

- The EFI already works around it with `Kernel → Quirks → AppleXcpmCfgLock = true`. **Do not
  turn that off.**
- Advanced (optional): boot OpenCore → **Tools → ControlMsrE2** to unlock it, then set
  `AppleXcpmCfgLock = false`.

## TPM
TPM 2.0 is present. You do **not** need to disable it, but some users prefer
`Security → Security Chip → Disabled`. It does not affect macOS functionality either way.

## After first successful boot
1. Reboot into BIOS.
2. Put the internal disk's **UEFI OS / OpenCore** entry at the top of the boot order.
3. Save and exit.
