# FAQ

**Will this work on my non-M920s PC?**
No. This EFI is tailored to the **exact** hardware (Q370, UHD 630, ALC233, I219-LM, SN730).
SMBIOS, SSDTs and quirks are machine-specific. Use it as a reference, not a universal EFI.

**Will installing erase my Proxmox install?**
Yes — following the guide erases the whole WD SN730. To keep Proxmox, install macOS to a
**second disk** instead (see `UPGRADES.md`).

**Which macOS version?**
Sonoma 14.x — best stability with full iGPU support. Sequoia works but is less tested here;
Tahoe (26) is riskier and likely needs patches.

**Does Wi-Fi/Bluetooth work?**
No wireless card is supported on this machine. **Ethernet-only** by decision. A tested
Realtek RTL8851BU USB dongle was **rejected**. Add a **BCM94360NG** if you need wireless.

**Is this safe / legitimate?**
Running macOS on non-Apple hardware is against Apple's EULA. This is for personal
experimentation. You are responsible for how you use it.

**Why iMac19,1 and not Macmini8,1?**
iMac19,1 matches the **8-core** CPU and is supported through the latest Intel macOS.
Macmini8,1 is provided as a fallback for the iGPU-only case. See `POST-INSTALL.md`.

**Do I need to install anything into macOS?**
No. Kexts are injected from the EFI. Optional tools (USBToolBox, sensor apps) are installed
like normal apps.

**Will Apple know / can I get banned?**
iMessage/FaceTime use a valid serial; this typically works. No guarantees — Apple can
deactivate accounts that look abusive. Use your own iCloud.

**Can I update macOS?**
Minor updates usually work. Update OpenCore/kexts to the latest first, keep your USB rescue
disk, and back up.

**Why is CFG Lock mentioned so much?**
Because this firmware locks `MSR 0xE2` (verified) and has no toggle, so the EFI compensates
with `AppleXcpmCfgLock`. Turning that off will cause instant reboots.

**Why no AirDrop even if I use a USB Wi-Fi dongle?**
AirDrop/Handoff/Continuity require a real Apple-supported (Broadcom) card. USB dongles only
give basic Wi-Fi.

**How do I ask for help?**
Open an issue with: your hardware change (if any), the exact symptom, and an OpenCore log
(`TROUBLESHOOTING.md` → "Capturing logs").

**Is this legal to share?**
The docs and EFI are MIT-licensed. The bundled kexts/bootloader belong to their authors
(see `CREDITS.md`) and keep their own licenses — do not relicense them.
