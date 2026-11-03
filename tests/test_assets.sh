#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
echo "Assets"

png_size() {
    python3 - "$1" <<'PY'
import struct, sys
with open(sys.argv[1], "rb") as f:
    head = f.read(24)
if head[:8] != b"\x89PNG\r\n\x1a\n":
    print("notpng")
else:
    print("%dx%d" % struct.unpack(">II", head[16:24]))
PY
}

for f in cindra-logo cindra-logo-dark cindra-logo-mono-black cindra-logo-mono-white; do
    expect_file "$f.svg exists" "$ROOT/assets/logo/$f.svg"
    if python3 -c "import sys, xml.dom.minidom as m; m.parse(sys.argv[1])" "$ROOT/assets/logo/$f.svg" 2>/dev/null; then pass "$f.svg is valid XML"; else fail "$f.svg is invalid"; fi
done
expect_contains "main logo is red" "$(cat "$ROOT/assets/logo/cindra-logo.svg")" "#e0242b"
expect_not_contains "monochrome black logo has no red" "$(cat "$ROOT/assets/logo/cindra-logo-mono-black.svg")" "#e0242b"
expect_not_contains "monochrome white logo has no red" "$(cat "$ROOT/assets/logo/cindra-logo-mono-white.svg")" "#e0242b"

for f in cindra-logo-512 cindra-logo-256 cindra-logo-48 cindra-logo-dark-512 cindra-logo-mono-black-512 cindra-logo-mono-white-512; do
    expect_file "$f.png exists" "$ROOT/assets/logo/$f.png"
done
expect_eq "logo PNG 512" "512x512" "$(png_size "$ROOT/assets/logo/cindra-logo-512.png")"
expect_eq "logo PNG 256" "256x256" "$(png_size "$ROOT/assets/logo/cindra-logo-256.png")"
expect_eq "logo PNG 48" "48x48" "$(png_size "$ROOT/assets/logo/cindra-logo-48.png")"
expect_file "wallpaper svg" "$ROOT/assets/wallpaper/cindra-default.svg"
expect_eq "wallpaper PNG is 1920x1080" "1920x1080" "$(png_size "$ROOT/assets/wallpaper/cindra-default.png")"

for f in os-release cindra-release issue issue.net; do
    expect_file "branding/$f" "$ROOT/assets/branding/$f"
done

finish
