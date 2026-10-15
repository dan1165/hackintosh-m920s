# Contributing

Thanks for wanting to help. This is a **machine-specific** Hackintosh project, so the rules are a
little different from normal software.

## What this repo is (and isn't)
- **Is:** a reference EFI + documentation for **one exact machine** — a Lenovo ThinkCentre M920s
  (Q370, i7-9700).
- **Isn't:** a generic "works on everything" EFI. Changes that help other machines are welcome
  **only if they don't regress this one**.

## Golden rules
1. **Never commit secrets or large blobs.**
   - No tokens, passwords, or licence keys.
   - SMBIOS serials/MLB/UUID and the MAC address in this repo are **public by design** (they ship
     with the build). Do **not** add *your own* personal serials.
   - No recovery images (`*.dmg`), no `*.zip` dumps, no raw ACPI dumps — see `.gitignore`.
2. **Every EFI change must pass validation.** CI runs it for you; run it locally too:
   ```bash
   ./PostInstall/ocvalidate.linux EFI/OC/config.plist
   ```
   A red CI check blocks merge.
3. **Change one thing at a time.** A config change + a kext bump + a doc rewrite in one PR is
   impossible to review. Split them.
4. **Document the "why".** A change without a reason is rejected. Link the source (a DSDT fact, an
   upstream release note, a forum thread).

## Adding/changing documentation
- Plain Markdown, GitHub-flavoured. Use tables for anything tabular.
- Keep the existing voice: direct, factual, "here's the evidence".
- Cross-link with **relative** paths (e.g. `docs/USB-MAP.md` from the root, `USB-MAP.md` from
  inside `docs/`) so they work on GitHub and in the rendered docs.
- If you cite a fact about the hardware, say **how** it was determined (command + result).
- Add new pages to the index in [`docs/README.md`](docs/README.md) and to the table in
  [`README.md`](README.md).

## Adding/changing the EFI
| Change | Requirements |
|---|---|
| ACPI (`EFI/OC/ACPI/*.aml`) | Ship the `.dsl` source too; state the DSDT device it targets |
| `config.plist` | Explain each key changed; re-run `ocvalidate`; note the OpenCore version it targets |
| Kexts | Update [`docs/VERSIONS.md`](docs/VERSIONS.md) and [`docs/KEXTS.md`](docs/KEXTS.md) |
| Drivers/Tools | Note where the binary came from (upstream release + version) |

## Commit messages
Conventional-ish, imperative mood, e.g.:
```
USB: ship hardware-verified USBPorts.kext map

Derived from xHCI Supported-Protocol registers (USB2=1-16, USB3=17-26) and a
live plug test. Replaces the manual USBToolBox step. ocvalidate 1.0.8: clean.
```

## Pull request checklist
- [ ] `ocvalidate` passes locally (CI will confirm).
- [ ] Docs updated (index + affected pages).
- [ ] No secrets / no large binaries.
- [ ] One logical change.
- [ ] Explained the *why*, with a source.

## Reporting a hardware difference
If your M920s differs (BIOS revision, WLAN option, RAM), open an issue with the
**Hardware report** template and paste the output of:
```bash
lspci -nn; lsusb; dmidecode -t 1,2; cat /sys/class/dmi/id/bios_version
```

By contributing you agree your contributions are licensed under this repo's **MIT** licence
(see [`LICENSE`](LICENSE)).
