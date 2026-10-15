# Secure Boot, Vault & SIP

Three different "security" settings that are easy to confuse. Current values are in
`config.plist`; change one at a time and `ocvalidate`.

## 1. `Misc → Security → SecureBootModel` (Apple Secure Boot)
| Value | Meaning |
|---|---|
| `Default` | **this build** — matches the SMBIOS's model; enables Apple Secure Boot checks |
| `Disabled` | turn Apple Secure Boot off (some third-party drivers need this, e.g. a USB-Wi-Fi kext) |
| `x86legacy` | for older/pre-2020 models without T2/Secure Enclave |

> If a closed-source USB Wi-Fi driver won't load, `Disabled` is the common fix.

## 2. `Misc → Security → Vault` (EFI tamper protection)
| Value | Meaning |
|---|---|
| `Optional` | **this build** — no signature required; easiest for editing |
| `Basic`/`Secure` | the EFI is signed; `config.plist` and files are verified against a vault |

To sign: `.github`/OpenCore's `CreateVault` tool + `Vault.plist`/`Vault.sig`. Only worth it for a
fleet/deployment, not personal use.

## 3. SIP (`NVRAM → csr-active-config`)
| Value | SIP state |
|---|---|
| `00000000` | **this build** — SIP fully **on** (most secure) |
| `FF0F0000` / `03000000` | SIP partially/fully off (needed by some third-party kexts) |

Toggle it from the picker with the **`CsrUtil`** tool, or in Recovery (`csrutil disable`).
**Keep SIP on** unless a specific driver demands otherwise.

## 4. `Misc → Security → ScanPolicy`
`0` (this build) scans everything — convenient, shows all boot entries. Tighten it to hide
non-macOS volumes if you prefer a clean picker.

## Firmware side (BIOS)
- **Secure Boot = Disabled** (required to boot OpenCore on this machine).
- **CSM = Disabled** (pure UEFI).

## Quick matrix
| Goal | SecureBootModel | SIP | Vault |
|---|---|---|---|
| Max security, stock | `Default` | on | Optional |
| Third-party (USB Wi-Fi) driver | `Disabled` | off | Optional |
| Locked-down deployment | `Default` | on | Basic/Secure |
