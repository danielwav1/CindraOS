# CindraOS 1.0.0 Stable

CindraOS 1.0.0 is a Debian 13 (Trixie) amd64 live Linux system with a customized XFCE desktop and the `cindra` command-line utility.

## Highlights

- CindraOS red-and-graphite Plymouth boot splash
- UEFI Secure Boot boot chain using Microsoft-signed shim and Debian-signed GRUB
- Hybrid ISO supporting legacy BIOS and UEFI boot
- XFCE desktop with Cindra-Dark and Cindra-Light themes
- Temporary live session; no installer or persistent storage is configured

## Secure Boot

The ISO includes the signed shim, signed GRUB and signed Debian kernel. Secure Boot is checked by signature inspection and an OVMF virtual-firmware boot test. Firmware revocation databases and vendor-specific implementations can still affect compatibility.

## Verify the download

Run `sha256sum -c CindraOS-1.0.0-live-amd64.iso.sha256` from the directory containing the ISO and checksum file.

## Important limitations

- amd64 PCs only
- No installer; this is a live system
- Session changes are not retained after reboot
- Physical hardware compatibility varies; QEMU testing does not replace testing on every PC
