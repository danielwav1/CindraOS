#!/usr/bin/env bash
set -uo pipefail

iso=${1:-}
timeout_s=${CINDRA_SECURE_BOOT_TIMEOUT:-420}
code=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd
vars_template=/usr/share/OVMF/OVMF_VARS_4M.ms.fd

if [[ -z $iso || ! -s $iso ]]; then
    echo "FAIL: pass a built CindraOS ISO" >&2
    exit 2
fi
for tool in qemu-system-x86_64 timeout; do
    command -v "$tool" >/dev/null 2>&1 || { echo "FAIL: required tool $tool is missing" >&2; exit 1; }
done
for file in "$code" "$vars_template"; do
    [[ -r $file ]] || { echo "FAIL: Secure Boot firmware file is missing: $file" >&2; exit 1; }
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp "$vars_template" "$tmp/vars.fd"

echo "Booting the ISO with OVMF Secure Boot enabled"
timeout "$timeout_s" qemu-system-x86_64 \
    -machine q35,smm=on,accel=tcg \
    -global driver=cfi.pflash01,property=secure,value=on \
    -drive if=pflash,format=raw,unit=0,readonly=on,file="$code" \
    -drive if=pflash,format=raw,unit=1,file="$tmp/vars.fd" \
    -m 3072 -smp 2 -cdrom "$iso" -boot d \
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
    echo "PASS: CindraOS reached the login prompt with OVMF Secure Boot enabled"
    exit 0
fi
echo "FAIL: Secure Boot VM did not reach the login prompt. Last console lines:" >&2
tail -n 40 "$tmp/serial.log" >&2
exit 1
