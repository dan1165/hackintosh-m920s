# Multiboot (macOS + Windows + Linux)

This machine originally ran Proxmox (Linux). You can keep it and add macOS.

## Safest: separate disks
Install macOS to its **own** NVMe/SATA disk. OpenCore's picker can then chain-load the others.
Nothing else is touched, and each OS keeps its own bootloader.

## One disk, multiple OSes
- Partition in **GUID/APFS**; give each OS its space up front.
- macOS wants a `EFI` (ESP) — OpenCore lives there.

## Letting OpenCore find the other OSes
Add these official drivers in `UEFI → Drivers` (see [`OPTIONAL-COMPONENTS.md`](OPTIONAL-COMPONENTS.md)):
| Driver | Lets OpenCore see |
|---|---|
| `OpenLinuxBoot.efi` | Linux kernels (auto-discovers `\EFI\*`) |
| `Ext4Dxe.efi` | ext2/3/4 volumes (for the above) |
| `OpenNtfsDxe.efi` | NTFS volumes (Windows) |
| `OpenPartitionDxe.efi` | arbitrary partition layouts (already shipped) |

Set `UEFI → Quirks → RequestBootVarRouting = true` (already) so OpenCore becomes the boot manager.

## Boot order
- `Misc → Boot → ShowPicker = true` (this build) → pick the OS each boot.
- Or `AllowSetDefault` (already true) + **Ctrl+Enter** on an entry to set the default.

## Keeping Windows happy (Boot Camp model)
- Use SMBIOS `iMac19,1` and keep `PlatformInfo → UpdateSMBIOSMode = Create`.
- Keep the OpenCore `EFI` first in the firmware boot order.
- Don't rename `H_EC`/`EC` (would break Windows ACPI on this board).

## Linux side
- Linux can boot the OpenCore EFI via `efibootmgr`, or OpenCore can boot Linux directly with
  `OpenLinuxBoot.efi` + `Ext4Dxe.efi`.

## Notes
- The macOS **installer erases the target disk** — never point it at the disk you want to keep
  (see [`HARDWARE.md`](HARDWARE.md) §disks).
- Keep a rescue USB ([`RECOVERY.md`](RECOVERY.md)) before touching boot order.
