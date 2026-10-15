# Recovery & rollback

When a change bricks the boot, **don't panic and don't reinstall**. Almost everything here is
recoverable from a USB.

## Golden rule: keep a rescue USB
Always keep a FAT32 USB with a **known-good `EFI/`** that boots this machine. It is your seatbelt
for every future change. Label it and don't reformat it.

## Symptom → action

### 1. No boot picker / firmware doesn't find the USB
- BIOS: **Secure Boot = Disabled**, **CSM = Disabled**, boot from the USB's EFI partition.
- Try a different USB port (rear USB 2 port is safest during bring-up).

### 2. Picker appears, but panic / instant reboot
1. Boot with verbose (`-v keepsyms=1`) and read the last lines.
2. Boot the **rescue USB** (your working EFI), then fix the broken `EFI/` on the internal disk.
3. If a recent `config.plist`/SSDT/kext change caused it: **revert that one thing**.
   ```
   git log --oneline            # find the last good commit
   git checkout <good-sha> -- EFI/
   ```
4. Re-run `./PostInstall/ocvalidate.linux EFI/OC/config.plist`, then reboot.

### 3. macOS boots, but a feature died (GPU/audio/net)
- Boot macOS, then `kextstat | grep -i <name>` — is the kext loaded?
- If not, the `Kernel → Add` entry or the `.kext` folder is wrong. Fix on the EFI partition from
  macOS or from the rescue USB.

### 4. NVRAM is polluted (boot-args stuck, services broken)
- Reset from the picker: select the **Reset NVRAM** entry (enabled via `ResetNvramEntry.efi`).
- Or hold the reset in `Misc → Security` as needed; then re-apply your `boot-args`.

### 5. Forgot the OpenCore password / need to unlock MSR
- Use the **OpenShell** tool from the picker (`EFI/OC/Tools/OpenShell.efi`).
- `ControlMsrE2` (also in `Tools/`) can unlock CFG Lock if you want native XCPM.

## Rolling back the whole EFI
```bash
# on the machine with the repo cloned (Linux or macOS)
git log --oneline                 # choose a known-good commit
git checkout <sha> -- EFI/        # restore just the EFI tree
./PostInstall/ocvalidate.linux EFI/OC/config.plist
# then copy EFI/ to the internal disk's EFI partition
```

## Recovering the macOS install itself
- The installer USB this build was made from can also **reinstall** over the top (keeps data) —
  boot it, choose *Reinstall macOS*.
- Worst case: boot the installer, erase, and reinstall (this is why you back up first).

## If you ever see "This copy of the install macOS … is damaged"
- Usually a clock/date issue in the recovery environment, or an unsupported board-id.
  Set the date correctly (`date -u MMDDhhmmYY`) and make sure the SMBIOS matches a supported model.

## Order of operations after any incident
1. Get back to a **bootable** state (rescue USB / revert one change).
2. `ocvalidate`.
3. Confirm a normal reboot works.
4. Only then continue changing things.
