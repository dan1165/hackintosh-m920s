## Summary
<!-- One or two lines: what and why. -->

## Type
- [ ] EFI change (ACPI / config / kexts / drivers)
- [ ] Documentation
- [ ] CI / tooling
- [ ] Other

## Checklist
- [ ] `./PostInstall/ocvalidate.linux EFI/OC/config.plist` passes locally (CI will confirm)
- [ ] Docs updated (index + affected pages)
- [ ] No secrets, no large binaries (`*.dmg`, `*.zip`, raw ACPI dumps)
- [ ] One logical change only
- [ ] The *why* is explained, with a source (DSDT fact / upstream release / issue link)

## Evidence
<!-- Commands run + key output; screenshots of boot only if relevant. -->

## Affected files
<!-- e.g. docs/USB-MAP.md, EFI/OC/config.plist -->
