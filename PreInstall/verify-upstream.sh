#!/usr/bin/env bash
# verify-upstream.sh — supply-chain check: download the official RELEASE artefacts this repo
# was built from and confirm the bundled binaries are byte-identical (SHA-256) to upstream.
# Skips gracefully with no network.
#
#   ./PreInstall/verify-upstream.sh
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$DIR/lib.sh"
ROOT="$(repo_root)"
TMP="$(mktemp -d 2>/dev/null || echo /tmp/vu.$$)"; mkdir -p "$TMP"; trap 'rm -rf "$TMP"' EXIT

have python3 || { fail "python3 required"; summary; exit 1; }

fetch_zip() { # url destdir
  local url="$1" d="$2"; mkdir -p "$d"
  if ! curl -fsSL "$url" -o "$d/pkg.zip" 2>/dev/null; then return 1; fi
  python3 - "$d/pkg.zip" "$d" <<'PY' 2>/dev/null || return 1
import zipfile,sys
zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])
PY
}

cmp_file() { # label  ours  theirs
  if [ ! -e "$2" ]; then skip "$1: not in repo"; return; fi
  if [ ! -e "$3" ]; then warn "$1: not found in upstream zip"; return; fi
  if cmp -s "$2" "$3"; then pass "$1 identical to upstream"; else fail "$1 DIFFERS from upstream"; fi
}

# ---------------------------------------------------------------- OpenCore ----
hdr "OpenCore 1.0.8"
OCD="$TMP/oc"
if fetch_zip "https://github.com/acidanthera/OpenCorePkg/releases/download/1.0.8/OpenCore-1.0.8-RELEASE.zip" "$OCD"; then
  cmp_file "BOOTx64.efi"     "$ROOT/EFI/BOOT/BOOTx64.efi"          "$OCD/X64/EFI/BOOT/BOOTx64.efi"
  cmp_file "OpenCore.efi"    "$ROOT/EFI/OC/OpenCore.efi"           "$OCD/X64/EFI/OC/OpenCore.efi"
  for f in "$ROOT"/EFI/OC/Drivers/*; do
    b="$(basename "$f")"; cmp_file "Drivers/$b" "$f" "$OCD/X64/EFI/OC/Drivers/$b"
  done
  for f in "$ROOT"/EFI/OC/Tools/*; do
    b="$(basename "$f")"; cmp_file "Tools/$b" "$f" "$OCD/X64/EFI/OC/Tools/$b"
  done
else
  warn "could not download OpenCore (offline?) — skipped"
fi

# -------------------------------------------------------------------- Kexts ---
verify_kext() { # name version url
  local name="$1" ver="$2" url="$3" d="$TMP/k_$1"
  hdr "$name $ver"
  if ! fetch_zip "$url" "$d"; then warn "could not download $name — skipped"; return; fi
  local theirs
  theirs="$(find "$d" -maxdepth 2 -type d -name "${name}.kext" | head -1)"
  if [ -z "$theirs" ]; then warn "$name.kext not found in upstream zip"; return; fi
  # compare every file in our copy against theirs
  local ok=1
  while IFS= read -r rel; do
    if ! cmp -s "$ROOT/EFI/OC/Kexts/$name.kext/$rel" "$theirs/$rel"; then ok=0; echo "        differs: $rel"; fi
  done < <(cd "$ROOT/EFI/OC/Kexts/$name.kext" && find . -type f | sed 's|^\./||')
  [ "$ok" = 1 ] && pass "$name.kext matches upstream $ver" || fail "$name.kext differs from upstream"
}

verify_kext "Lilu"          "1.7.2" "https://github.com/acidanthera/Lilu/releases/download/1.7.2/Lilu-1.7.2-RELEASE.zip"
verify_kext "VirtualSMC"    "1.3.8" "https://github.com/acidanthera/VirtualSMC/releases/download/1.3.8/VirtualSMC-1.3.8-RELEASE.zip"
verify_kext "SMCProcessor"  "1.3.8" "https://github.com/acidanthera/VirtualSMC/releases/download/1.3.8/VirtualSMC-1.3.8-RELEASE.zip"
verify_kext "SMCSuperIO"    "1.3.8" "https://github.com/acidanthera/VirtualSMC/releases/download/1.3.8/VirtualSMC-1.3.8-RELEASE.zip"
verify_kext "WhateverGreen" "1.7.1" "https://github.com/acidanthera/WhateverGreen/releases/download/1.7.1/WhateverGreen-1.7.1-RELEASE.zip"
verify_kext "AppleALC"      "1.9.8" "https://github.com/acidanthera/AppleALC/releases/download/1.9.8/AppleALC-1.9.8-RELEASE.zip"
verify_kext "IntelMausi"    "1.0.8" "https://github.com/acidanthera/IntelMausi/releases/download/1.0.8/IntelMausi-1.0.8-RELEASE.zip"
verify_kext "NVMeFix"       "1.1.3" "https://github.com/acidanthera/NVMeFix/releases/download/1.1.3/NVMeFix-1.1.3-RELEASE.zip"
verify_kext "RestrictEvents" "1.1.6" "https://github.com/acidanthera/RestrictEvents/releases/download/1.1.6/RestrictEvents-1.1.6-RELEASE.zip"

hdr "Notes"
info "USBPorts.kext and all SSDTs are authored by this project (not upstream)."

summary
