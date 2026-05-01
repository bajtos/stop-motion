#!/usr/bin/env bash
set -euo pipefail

srcdir="${1:?Usage: $0 <source-dir> [fps]}"
fps="${2:-5}"

# Strip trailing slash from directory name for clean output naming
basename="$(basename "$srcdir")"
output="${basename}-${fps}fps.mp4"

shopt -s nullglob
files=("$srcdir"/*.{png,jpg,jpeg})
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
  echo "No image files (png/jpg/jpeg) found in $srcdir" >&2
  exit 1
fi

echo "Found ${#files[@]} image files in $srcdir, creating video at ${fps} fps..."

# Build a concat demuxer file with sorted images
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

for f in "${files[@]}"; do
  echo "file '$(cd "$(dirname "$f")" && pwd)/$(basename "$f")'" >> "$tmp"
done

ffmpeg -y -r "$fps" -f concat -safe 0 -i "$tmp" \
  -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
  -c:v libx264 -profile:v high -level 4.1 -pix_fmt yuv420p \
  -movflags +faststart \
  "$output"

echo "Created $output"
