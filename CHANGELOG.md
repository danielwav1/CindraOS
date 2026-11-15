# Changelog

## 1.0.0 — Stable Live Edition

- Adds a branded CindraOS Plymouth boot splash.
- Enables UEFI Secure Boot using Debian-signed GRUB and Microsoft-signed shim.
- Adds ISO-level signature verification and an OVMF Secure Boot boot test.
- Keeps the BIOS/UEFI hybrid live image, XFCE desktop and existing `cindra` utility.

## 0.4.0 — Experimental

CindraOS rebrand of the Debian 13 Trixie live system.

- CindraOS system identity, CLI, services, documentation and build outputs
- Red and graphite Cindra mark, generated PNG artwork and wallpaper
- Custom Cindra-Icons theme for core desktop applications
- Cindra-Dark and Cindra-Light GTK and XFWM themes
- Hybrid amd64 ISO for physical PCs and virtual machines, supporting BIOS and UEFI
- GitHub Actions tests and ISO build pipeline

## 0.3 — Experimental

First version with a reproducible build system.

- live-build based ISO build for Debian 13 Trixie, amd64
- XFCE desktop with custom themes, red accent, wallpaper and panel layout
- generated XFWM4 window decorations
- cindra command-line utility
- shell prompt, banner and aliases
- identity files: /usr/lib/os-release, /etc/cindra-release and /etc/issue
- automated tests, ISO verification script and VM boot test
- Live session only; no installer
