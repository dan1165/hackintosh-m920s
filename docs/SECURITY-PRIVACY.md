# Security & privacy

This build contains **identifiers**. This page explains what they are, why they're here, and how to
handle secrets. Project-level security policy: [`SECURITY.md`](../SECURITY.md).

## The identifiers in this repo
| Item | Value (as shipped) | Sensitivity | Why committed |
|---|---|---|---|
| `SystemProductName` | `iMac19,1` | none | SMBIOS model |
| `SystemSerialNumber` | `C02…` | **low–medium** | needed for iMessage/App Store; a valid serial |
| `MLB` (board serial) | `C02…` | **low–medium** | pairs with the serial |
| `SystemUUID` | `5A9F…` | low | stable hardware identity |
| `ROM` | `6C:4B:90:CE:BA:90` | low | this machine's own onboard MAC |

**Apple treats these three (serial + MLB + UUID) as a device identity.** Sharing the *same* trio
between two machines can cause Apple-ID/Messages de-sync, and a widely-shared serial can get
flagged. That's why:

> ### ⚠️ If you clone this repo onto a *different* machine, regenerate the SMBIOS.
> ```bash
> ./PostInstall/macserial.linux -g -m iMac19,1
> # then paste Serial / MLB / UUID into config.plist → PlatformInfo → Generic
> ```
> See [`MAINTENANCE.md`](MAINTENANCE.md). Keep `ROM` = the target machine's real MAC.

## Secrets — never commit these
- GitHub/Apple/any **tokens, passwords, private keys**.
- **Your** personal serials if you'd rather not publish them (this repo's are shared on purpose).
- Wi-Fi passphrases, Apple-ID credentials, personal data or logs with PII.

If a secret is ever committed, remember it stays in **git history** — the fix is **revoke first**,
then rewrite history. See [`SECURITY.md`](../SECURITY.md).

## Token hygiene (contributors)
- Use **fine-grained** GitHub tokens, scoped to one repo, permission `Contents: Read and write`.
- Delete the token **immediately** after use.
- Never paste a token into a commit, issue, PR, or chat — assume anything pasted is compromised.

## What this project does **not** do
- No telemetry, no phone-home, no post-install scripts you didn't review.
- No bundled closed-source binary other than the upstream kexts/drivers listed in
  [`VERSIONS.md`](VERSIONS.md) and [`CREDITS.md`](CREDITS.md).
- It does **not** touch an existing disk until *you* run the installer (which erases the target).

## Runtime hardening knobs (optional)
| Knob | Location | Effect |
|---|---|---|
| `csr-active-config` | NVRAM | `00000000` = SIP fully on. A closed USB-Wi-Fi kext needs SIP off |
| `SecureBootModel` | `Misc → Security` | `Default` keeps Apple Secure Boot checks; some drivers need `Disabled` |
| `Vault` | `Misc → Security` | `Optional` (default); set `Basic`/`Secure` to sign the EFI |
| `ScanPolicy` | `Misc → Security` | `0` scans everything (convenient); tighten to hide foreign OSes |

Keep SIP **on** (`00000000`) unless a specific driver demands otherwise.
