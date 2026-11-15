#!/usr/bin/env bash
set -uo pipefail

usage() {
    echo "Usage: verify-iso.sh [--deep] IMAGE.iso"
    echo "  --deep   also unpack the root filesystem and inspect its contents (needs ~2 GB temp space)"
}

deep=0
iso=""
while (( $# )); do
    case $1 in
        --deep)    deep=1 ;;
        -h|--help) usage; exit 0 ;;
        -*)        usage >&2; exit 2 ;;
        *)         iso=$1 ;;
    esac
    shift
done
[[ -n $iso ]] || { usage >&2; exit 2; }

passed=0
failed=0
warned=0

ok()   { passed=$((passed + 1)); printf '  PASS  %s\n' "$1"; }
bad()  { failed=$((failed + 1)); printf '  FAIL  %s\n' "$1"; }
meh()  { warned=$((warned + 1)); printf '  WARN  %s\n' "$1"; }

if [[ ! -s $iso ]]; then
    echo "verify-iso: '$iso' does not exist or is empty" >&2
    exit 1
fi
for tool in file xorriso; do
    command -v "$tool" >/dev/null 2>&1 || { echo "verify-iso: $tool is required" >&2; exit 3; }
done

echo "Verifying $iso"

desc=$(file -b "$iso")
if [[ $desc == *"ISO 9660"* ]]; then ok "file(1) reports an ISO 9660 image"; else bad "file(1) does not report ISO 9660: $desc"; fi
if [[ $desc == *"bootable"* ]]; then ok "file(1) reports it as bootable"; else bad "file(1) does not report a boot record"; fi

size_mb=$(( $(stat -c %s "$iso") / 1048576 ))
if (( size_mb >= 400 )); then ok "image size plausible (${size_mb} MiB)"; else bad "image is only ${size_mb} MiB, a desktop image should be larger"; fi

sumfile="$iso.sha256"
if [[ -f $sumfile ]]; then
    if (cd "$(dirname "$iso")" && sha256sum -c "$(basename "$sumfile")" >/dev/null 2>&1); then ok "sha256 matches $(basename "$sumfile")"
    else bad "sha256 does not match $(basename "$sumfile")"; fi
else
    meh "no $(basename "$sumfile") next to the image"
fi

pvd=$(xorriso -indev "$iso" -pvd_info 2>&1 || true)
if grep -qi 'CINDRAOS' <<< "$pvd"; then ok "ISO volume id contains CINDRAOS"; else bad "ISO volume id does not mention CINDRAOS"; fi

boot=$(xorriso -indev "$iso" -report_el_torito plain 2>&1 || true)
if grep -qiE 'BIOS|pltf *= *0x00|El Torito' <<< "$boot"; then ok "El Torito boot catalog present"; else bad "no El Torito boot catalog found"; fi
if grep -qiE 'UEFI|0xef|efi' <<< "$boot"; then ok "UEFI boot entry present"; else bad "no UEFI boot entry found"; fi

sysarea=$(xorriso -indev "$iso" -report_system_area plain 2>&1 || true)
if grep -qiE 'MBR|GPT' <<< "$sysarea"; then ok "hybrid system area (MBR/GPT) present, USB-bootable"; else bad "no MBR/GPT system area, image may not boot from USB"; fi

listing=$(xorriso -indev "$iso" -find /live -name '*' 2>&1 || true)
if grep -q 'filesystem.squashfs' <<< "$listing"; then ok "/live/filesystem.squashfs present"; else bad "/live/filesystem.squashfs missing"; fi
if grep -q 'vmlinuz' <<< "$listing"; then ok "kernel present in /live"; else bad "no kernel in /live"; fi
if grep -q 'initrd' <<< "$listing"; then ok "initrd present in /live"; else bad "no initrd in /live"; fi

if (( deep )); then
    command -v unsquashfs >/dev/null 2>&1 || { echo "verify-iso: --deep needs unsquashfs (squashfs-tools)" >&2; exit 3; }
    for tool in mcopy sbverify; do
        command -v "$tool" >/dev/null 2>&1 || { echo "verify-iso: --deep needs $tool" >&2; exit 3; }
    done
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    if xorriso -osirrox on -indev "$iso" -extract /live/filesystem.squashfs "$tmp/fs.squashfs" >/dev/null 2>&1; then
        osr=$(unsquashfs -cat "$tmp/fs.squashfs" usr/lib/os-release 2>/dev/null || true)
        if grep -q '^ID=cindra' <<< "$osr"; then ok "root fs: os-release identifies CindraOS"; else bad "root fs: os-release is not CindraOS"; fi
        files=$(unsquashfs -l "$tmp/fs.squashfs" 2>/dev/null || true)
        for f in usr/local/bin/cindra etc/cindra-release usr/share/backgrounds/cindra/cindra-default.png usr/share/themes/Cindra-Dark/gtk-3.0/gtk.css etc/lightdm/lightdm.conf.d/50-cindra.conf usr/share/plymouth/themes/cindra/cindra.plymouth usr/share/plymouth/themes/cindra/cindra.script usr/share/plymouth/themes/cindra/cindra-logo.png etc/plymouth/plymouthd.conf; do
            if grep -q "squashfs-root/$f\$" <<< "$files"; then ok "root fs: /$f"; else bad "root fs: /$f missing"; fi
        done
        if xorriso -osirrox on -indev "$iso" -extract /boot/grub/efi.img "$tmp/efi.img" >/dev/null 2>&1; then
            if mcopy -i "$tmp/efi.img" ::/EFI/BOOT/BOOTX64.EFI "$tmp/bootx64.efi" >/dev/null 2>&1 && sbverify --list "$tmp/bootx64.efi" >/dev/null 2>&1; then ok "Secure Boot: Microsoft-signed shim is present"; else bad "Secure Boot: signed shim is missing or invalid"; fi
            if mcopy -i "$tmp/efi.img" ::/EFI/BOOT/GRUBX64.EFI "$tmp/grubx64.efi" >/dev/null 2>&1 && sbverify --list "$tmp/grubx64.efi" >/dev/null 2>&1; then ok "Secure Boot: Debian-signed GRUB is present"; else bad "Secure Boot: signed GRUB is missing or invalid"; fi
        else
            bad "Secure Boot: EFI boot image /boot/grub/efi.img is missing"
        fi
        if xorriso -osirrox on -indev "$iso" -extract /live/vmlinuz "$tmp/vmlinuz" >/dev/null 2>&1 && sbverify --list "$tmp/vmlinuz" >/dev/null 2>&1; then ok "Secure Boot: signed Linux kernel is present"; else bad "Secure Boot: signed Linux kernel is missing or invalid"; fi
        for forbidden in calamares debian-installer; do
            if grep -q "usr/bin/$forbidden\$\|usr/share/$forbidden\$" <<< "$files"; then bad "root fs: installer component '$forbidden' present"; else ok "root fs: no $forbidden"; fi
        done
    else
        bad "could not extract /live/filesystem.squashfs"
    fi
fi

echo
echo "Result: $passed passed, $failed failed, $warned warnings"
(( failed == 0 ))
