#!/usr/bin/env bash
set -uo pipefail

iso=${1:-}
timeout_s=${CINDRA_SECURE_BOOT_TIMEOUT:-60}
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

echo "Launching the ISO through OVMF with Secure Boot enabled"
timeout "$timeout_s" qemu-system-x86_64 \
    -machine q35,smm=on,accel=tcg \
    -global driver=cfi.pflash01,property=secure,value=on \
    -drive if=pflash,format=raw,unit=0,readonly=on,file="$code" \
    -drive if=pflash,format=raw,unit=1,file="$tmp/vars.fd" \
    -m 3072 -smp 2 -cdrom "$iso" -boot d \
    -display none -serial "file:$tmp/serial.log" -no-reboot -net none &
qemu=$!

launched=0
for (( i = 0; i < timeout_s; i++ )); do
    sleep 1
    if grep -qiE 'Security Violation|Access Denied|Image failed to load' "$tmp/serial.log" 2>/dev/null; then
        break
    fi
    if grep -q 'BdsDxe: starting Boot0001' "$tmp/serial.log" 2>/dev/null; then
        launched=1
        break
    fi
    kill -0 "$qemu" 2>/dev/null || break
done

kill "$qemu" 2>/dev/null
wait "$qemu" 2>/dev/null

if (( launched )); then
    echo "PASS: OVMF Secure Boot accepted and launched the ISO UEFI boot entry"
    echo "The separate standard QEMU boot test verifies the live system login prompt."
    exit 0
fi

echo "FAIL: OVMF did not confirm launch of the ISO UEFI boot entry under Secure Boot. Last console lines:" >&2
tail -n 40 "$tmp/serial.log" >&2
exit 1
