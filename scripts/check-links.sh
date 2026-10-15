#!/usr/bin/env bash
# check-links.sh — verify every relative Markdown link in the repo resolves.
# Used by `make docs` and CI.  Exit 0 = all good, 1 = broken link(s).
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
python3 - <<'PY'
import os, re, glob, sys
bad = 0
for f in sorted(glob.glob('**/*.md', recursive=True)):
    d = os.path.dirname(f)
    for m in re.finditer(r'\]\(([^)]+)\)', open(f, encoding='utf-8').read()):
        t = m.group(1)
        if t.startswith(('http', '#', 'mailto:')):
            continue
        t = t.split('#')[0]
        if not t:
            continue
        if not os.path.exists(os.path.normpath(os.path.join(d, t))):
            print(f"  broken: {t}  (in {f})")
            bad += 1
print(f"broken links: {bad}")
sys.exit(1 if bad else 0)
PY
