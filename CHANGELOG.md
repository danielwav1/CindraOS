# Changelog

## 0.4.0 (experimental, unreleased)

CindraOS rebrand of the Debian 13 "trixie" live system.

- CindraOS system identity, CLI, services, documentation and build outputs
- New red and graphite Cindra mark, generated PNG artwork and wallpaper
- Custom Cindra-Icons theme for core desktop applications
- Cindra-Dark and Cindra-Light GTK and XFWM themes
- Explicit 100% XFWM opacity defaults for inactive, moving and resizing windows
- One hybrid amd64 ISO for physical PCs and virtual machines, supporting BIOS and UEFI
- GitHub Actions tests and ISO build pipeline

The ISO build and verification have completed successfully in GitHub Actions. The release and version tag are intentionally left to the repository owner.

## 0.3 (experimental)

First version with a reproducible build system.

- live-build based ISO build for Debian 13 "trixie", amd64
- XFCE desktop with custom themes, red accent, wallpaper and panel layout
- generated xfwm4 window decorations
- cindra command line tool with 14 commands
- shell prompt, banner and aliases
- identity files: /usr/lib/os-release, /etc/cindra-release, /etc/issue
- automated tests, ISO verification script and VM boot test
- No installer. Live session only.
