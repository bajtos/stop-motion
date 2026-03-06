#!/usr/bin/env bash
set -euo pipefail

srcdir="${1:?Usage: $0 <source-dir>}"

# Remove trailing slash
srcdir="${srcdir%/}"

shopt -s nullglob
files=("$srcdir"/*.CR3)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
  echo "No CR3 files found in $srcdir"
  exit 1
fi

echo "Converting ${#files[@]} CR3 files to JPEG in $srcdir..."

for f in "${files[@]}"; do
  out="${f%.CR3}.jpg"
  if [ -f "$out" ]; then
    echo "  skip $(basename "$f") (already converted)"
    continue
  fi
  echo "  $(basename "$f")"
  sips -s format jpeg "$f" --out "$out" > /dev/null
done

echo "Done."
