#!/usr/bin/env bash
set -uo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
iso=${1:-$(ls "$ROOT"/out/CindraOS-*-live-amd64.iso 2>/dev/null | head -n 1)}
timeout_s=${CINDRA_BOOT_TIMEOUT:-420}

if [[ -z $iso || ! -f $iso ]]; then
    echo "skip: no ISO found, run ./build.sh first" >&2
    exit 77
fi
for tool in qemu-system-x86_64 xorriso; do
    command -v "$tool" >/dev/null 2>&1 || { echo "skip: $tool not installed" >&2; exit 77; }
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

xorriso -osirrox on -indev "$iso" -extract /live/vmlinuz "$tmp/vmlinuz" >/dev/null 2>&1 \
    || { echo "FAIL: cannot extract /live/vmlinuz from the image" >&2; exit 1; }
xorriso -osirrox on -indev "$iso" -extract /live/initrd.img "$tmp/initrd.img" >/dev/null 2>&1 \
    || { echo "FAIL: cannot extract /live/initrd.img from the image" >&2; exit 1; }

echo "booting $iso (timeout ${timeout_s}s, read-only CD-ROM, no disks attached)"
timeout "$timeout_s" qemu-system-x86_64 \
    -machine accel=kvm:tcg -m 2048 -smp 2 \
    -cdrom "$iso" -boot d \
    -kernel "$tmp/vmlinuz" -initrd "$tmp/initrd.img" \
    -append "boot=live components console=ttyS0,115200 live-config.hostname=cindraos" \
    -display none -serial "file:$tmp/serial.log" -no-reboot -net none &
qemu=$!

reached=0
for (( i = 0; i < timeout_s; i += 5 )); do
    sleep 5
    if grep -q 'cindraos login:' "$tmp/serial.log" 2>/dev/null; then reached=1; break; fi
    kill -0 "$qemu" 2>/dev/null || break
done
kill "$qemu" 2>/dev/null
wait "$qemu" 2>/dev/null

if (( reached )); then
    echo "PASS: live system reached the login prompt"
    grep -m1 'CindraOS' "$tmp/serial.log" >/dev/null && echo "PASS: CindraOS banner seen on the console" || echo "WARN: no CindraOS banner on the serial console"
    exit 0
fi
echo "FAIL: no login prompt within ${timeout_s}s. Last console lines:" >&2
tail -n 25 "$tmp/serial.log" >&2
exit 1
