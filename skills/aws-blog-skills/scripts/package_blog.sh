#!/usr/bin/env bash
# Usage: package_blog.sh <workdir> <slug>
# Expects <workdir>/drafts/<slug>.md and <workdir>/images/*.png|*.svg
# Produces /mnt/user-data/outputs/<slug>/ and <slug>.zip, then prints the present_files list.
set -euo pipefail
W="$1"; S="$2"; OUT=/mnt/user-data/outputs
python3 "$(dirname "$0")/check_structure.py" "$W/drafts/$S.md" || { echo "structure check failed"; exit 1; }
python3 "$(dirname "$0")/lint_prose.py" "$W/drafts/$S.md" || { echo "prose lint found hard findings"; exit 1; }
rm -rf "$W/out"; mkdir -p "$W/out/$S/images"
cp "$W/drafts/$S.md" "$W/out/$S/"
cp "$W"/images/*.png "$W"/images/*.svg "$W/out/$S/images/"
( cd "$W/out" && rm -f "$S.zip" && zip -qr "$S.zip" "$S" )
rm -rf "$OUT/$S" "$OUT/$S.zip"; cp -r "$W/out/$S" "$W/out/$S.zip" "$OUT/"
echo "present_files:"; echo "  $OUT/$S/$S.md"; ls "$OUT/$S/images/"*.png "$OUT/$S/images/"*.svg | sed 's/^/  /'; echo "  $OUT/$S.zip"
