# Changelog

## 1.0.0 — Stable Live Edition

The first stable CindraOS release, based on Debian 13 Trixie.

- Establishes CindraOS 1.0.0 system identity and stable release metadata
- Documents the supported amd64 live-system scope and its limitations
- Clarifies that CindraOS is a live environment, not an installer
- Adds stricter CI behavior: package-name validation is mandatory
- Extends CI to inspect the built ISO filesystem and boot the image in QEMU
- Makes the test runner fail if a test script exits unexpectedly or omits its summary
- Reworks the README and build/testing documentation around the stable release

The stable release artifact is published only after the required automated checks and ISO build complete successfully. Real-hardware coverage remains limited and is not implied by the stable label.

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
