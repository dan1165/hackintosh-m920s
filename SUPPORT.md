# Support

This is a personal, machine-specific project. Help is best-effort and ad-hoc.

## Before you ask
1. Read the docs. Most questions are answered in:
   - [`docs/QUICKSTART.md`](docs/QUICKSTART.md) — the fast overview
   - [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) — symptom → fix
   - [`docs/FAQ.md`](docs/FAQ.md)
   - [`docs/GLOSSARY.md`](docs/GLOSSARY.md) — plain-language terms
2. Search existing **issues** (open *and* closed).
3. Change **one** thing and re-test — don't apply five fixes at once.

## Where to ask
- **Bugs / build problems** → open an issue using the **Bug report** template.
- **Your machine differs from mine** → use the **Hardware report** template.
- **Security / leaked secrets** → see [`SECURITY.md`](SECURITY.md) (private, do not open a public issue).

## What to include in an issue
The more of this, the faster a real answer:

| Item | How to get it |
|---|---|
| This repo's commit | `git rev-parse --short HEAD` |
| `ocvalidate` output | `./PostInstall/ocvalidate.linux EFI/OC/config.plist` |
| Boot log | boot with `-v keepsyms=1`, photograph the screen or attach `EFI/OC/*.log` |
| Hardware | `lspci -nn; lsusb; dmidecode -t 1,2` |
| macOS version | `sw_vers` |
| What you changed | exact diff / keys touched |
| Expected vs actual | one line each |

## What **not** to expect
- A guarantee it works on *your* machine (this EFI is tuned to one exact M920s).
- Support for Wi-Fi/BT dongles that have no macOS driver (see [`docs/UPGRADES.md`](docs/UPGRADES.md)).
- Help with piracy, or with violating local law.

## Legal
Installing macOS on non-Apple hardware is contrary to Apple's EULA. Everything here is for
personal experimentation and education; you accept the risk. See [`LICENSE`](LICENSE).
