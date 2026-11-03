#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
echo "ISO image"

iso=${1:-$(ls "$ROOT"/out/CindraOS-*-live-amd64.iso 2>/dev/null | head -n 1)}
if [[ -z $iso || ! -f $iso ]]; then
    skip "ISO checks" "no image found, run ./build.sh first"
    finish
    exit
fi

if out=$(bash "$ROOT/verify-iso.sh" "$iso" 2>&1); then pass "verify-iso.sh passed for $(basename "$iso")"
else fail "verify-iso.sh failed" "$out"; fi
echo "$out" | sed 's/^/    /'

finish
