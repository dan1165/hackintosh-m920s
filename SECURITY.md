# Security Policy

This project ships **configuration and documentation**, not running services — so the usual
"vulnerability" model is different. The main risks are **secret leakage** and **supply-chain**
issues, and both are taken seriously here.

## Supported versions
Only the latest `main` is supported. There is no back-port branch.

## Secrets — what may and may not be committed
| Item | Committed? | Why |
|---|---|---|
| `USBPorts.kext`, SSDTs, `config.plist` | ✅ yes | no secrets; the build *is* the point |
| SMBIOS serial / MLB / UUID | ✅ yes (as shipped) | required to make the EFI self-contained; these are the build's, not a personal identity |
| Onboard MAC (`ROM`) | ✅ yes | it's the machine's own published address |
| **Your own** Apple serials, tokens, passwords, keys | ❌ **never** | leak = account compromise |
| Wi-Fi/Apple-ID credentials | ❌ never | — |
| Personal data / photos / logs with PII | ❌ never | — |

> **Nothing in this repo should ever contain a secret.** If you find one, treat it as a security
> issue (below), don't just delete it in a commit — it stays in history.

## Supply chain — verify what you download
This repo bundles third-party binaries (OpenCore, kexts, tools). When updating them:
1. Download **only** from the official upstream release pages (see [`docs/CREDITS.md`](docs/CREDITS.md)).
2. Prefer **RELEASE** builds over DEBUG.
3. Check the upstream-published **SHA-256** where provided.
4. Never run a "bootloader builder" or "EFI generator" script from an unknown source — such scripts
   are a common malware vector in this community.
5. Commit only the artefacts you actually loaded, so the repo stays reproducible.

## Token / credential hygiene (contributors)
- Use **fine-grained** GitHub tokens scoped to a single repo, with the minimum permission
  (`Contents: Read and write` is enough to push).
- **Delete the token the moment you're done.** Never paste tokens into issues, PRs, commit
  messages, or chat.
- If a token leaks: **revoke it first**, *then* clean up.

## Reporting a vulnerability or a leaked secret
Please **do not** open a public issue for these. Instead:
1. Use GitHub's **private vulnerability reporting** (repo → *Security* → *Report a vulnerability*), or
2. Open a minimal public issue that says "security — need a private channel" with **no details**.

We'll acknowledge, and for a leaked secret we'll rotate/revoke and scrub history as needed.

## Scope
In scope: leaked secrets, malicious/backdoored artefacts, unsafe instructions that could brick a
machine or erase data without warning. Out of scope: the inherent legality of running macOS on
non-Apple hardware (see the note in [`README.md`](README.md)).
