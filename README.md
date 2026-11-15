# CindraOS

**Your system. Your way.**

CindraOS 1.0.0 is a Debian 13 (Trixie)-based live Linux distribution with a customized XFCE desktop, a red-and-graphite visual identity, and the `cindra` command-line utility.

CindraOS is a **live system**, not an installer. Boot it from a USB drive or in a virtual machine, try the desktop, and shut down. Changes made during the session are not saved unless you copy them to another drive.

[Releases and downloads](https://github.com/danielwav1/CindraOS/releases) · [Project website](https://danielwav1.github.io/CindraOS) · [Issues](https://github.com/danielwav1/CindraOS/issues) · [Discussions](https://github.com/danielwav1/CindraOS/discussions)

## CindraOS 1.0.0 Stable

This is the first stable release of the CindraOS-branded live system. Stable describes the published project build and tested configuration; it does not mean every PC or peripheral has been tested. Please report hardware-specific problems with the diagnostic report from `cindra report`, after reviewing it for private information.

## Features

- Debian 13 Trixie base and Linux kernel from Debian
- Hybrid amd64 live ISO for legacy BIOS and UEFI systems
- Debian-signed GRUB and Microsoft-signed shim for UEFI Secure Boot
- CindraOS red-and-graphite Plymouth boot splash
- XFCE desktop with Cindra-Dark and Cindra-Light themes
- Cindra wallpaper, logo, application icons, panel and terminal styling
- LightDM desktop login
- Thunar file manager, Mousepad editor, screenshot utility and task manager
- Firefox ESR, NetworkManager and PipeWire audio
- `cindra` utility for system information, checks, updates, logs, themes and diagnostics
- No CindraOS telemetry or background reporting

Most operating-system components are Debian packages. CindraOS provides the branding, desktop configuration, build system, documentation and `cindra` utility. See [the component overview](docs/DEBIAN-COMPONENTS.md).

## System requirements

| Component | Requirement |
|---|---|
| CPU | 64-bit x86 (amd64) |
| RAM | 2 GB minimum; 4 GB or more recommended |
| USB drive | 8 GB or larger |
| Firmware | Legacy BIOS or UEFI |
| Secure Boot | Supported on UEFI systems with standard Microsoft/Debian Secure Boot trust databases |
| Architecture | amd64 only |

Wi-Fi support depends on the hardware and available firmware. The included firmware covers a selection of common Intel, Realtek and Atheros devices, not every adapter.

## Download and verify

Download the ISO and its SHA-256 checksum from the [GitHub Releases page](https://github.com/danielwav1/CindraOS/releases). Verify the image before writing it to a USB drive:

```bash
sha256sum -c CindraOS-1.0.0-live-amd64.iso.sha256
```

The checksum file must be in the same directory as the ISO.

## Create a bootable USB drive

**Writing the image erases the selected USB drive. Double-check the target device before continuing.**

- **Windows:** use Rufus and select DD Image mode, or use balenaEtcher.
- **Android:** use EtchDroid with a USB-OTG adapter and choose raw image mode.
- **Linux:** identify the USB device with `lsblk`, then write the image:

```bash
lsblk
sudo dd if=CindraOS-1.0.0-live-amd64.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with the whole USB device, not a partition. Never copy the example device name without checking it.

## Boot CindraOS

1. Connect the USB drive and open the computer's boot menu.
2. Select the USB device in BIOS or UEFI mode.
3. Select the UEFI USB entry. Secure Boot can remain enabled on supported firmware.
4. The live desktop logs in automatically as `cindra`.

The live account uses the public password `cindra1` for local administrative prompts. This is a shared live-session credential, not a secure personal account. Do not use the live environment for sensitive work or store private credentials in it.

### Important live-session behavior

- CindraOS does not install itself to an internal drive.
- The live session is temporary. Changes are lost after shutdown or reboot.
- Save anything you need to a separate drive.
- The live environment runs from memory; large downloads and package upgrades can exhaust available RAM.
- Mounting internal disks is a user action and may expose their contents.

For virtual-machine testing, attach the ISO as a CD/DVD drive and allocate at least 2 GB RAM. A basic QEMU example:

```bash
qemu-system-x86_64 -m 3072 -smp 2 -cdrom CindraOS-1.0.0-live-amd64.iso -boot d
```

## The `cindra` command

Run `cindra help` for the complete usage information.

| Command | Purpose |
|---|---|
| `cindra version` | Show version and edition |
| `cindra info` | System overview |
| `cindra sys` | Kernel, CPU, memory, swap, uptime and disk |
| `cindra checkup` | Check important system components |
| `cindra desktop` | Desktop session and appearance details |
| `cindra update` | Refresh package lists and offer package upgrades |
| `cindra clean` | Review and clean package caches |
| `cindra repair` | Diagnose issues and offer confirmed fixes |
| `cindra logs` | View system logs |
| `cindra network` | Diagnose interfaces, gateway, DNS and HTTPS |
| `cindra theme` | List or change CindraOS theme profiles |
| `cindra report` | Write a local diagnostic report with common identifiers masked |
| `cindra about` | Project and license information |

The report is saved locally and is not uploaded. Read it before sharing it; masking reduces exposure but cannot guarantee that every private detail has been removed.

## Known limitations

- The official image is amd64 only.
- There is no graphical or command-line installer.
- Persistent live storage is not configured.
- Secure Boot is supported through Debian-signed GRUB and Microsoft-signed shim; firmware revocation databases and vendor implementations can still affect compatibility.
- Hardware compatibility varies, especially for Wi-Fi, graphics and audio devices.
- GTK4 and libadwaita applications may not follow every GTK3 theme setting.
- The live environment is temporary and is not intended as a replacement for an installed, maintained operating system.

These are documented product boundaries, not features that are implied to be available.

## Build from source

Builds are intended for Debian 13 on an x86_64 host with internet access, root access through `sudo`, and approximately 20 GB free disk space.

```bash
sudo apt install live-build debootstrap squashfs-tools xorriso python3 python3-pil python3-numpy file mtools dosfstools git
git clone https://github.com/danielwav1/CindraOS.git
cd CindraOS
chmod +x build.sh verify-iso.sh scripts/*.sh scripts/cindra tests/*.sh
bash tests/run.sh
./build.sh --check
./build.sh
```

The ISO and checksum are written to `out/`. See [docs/BUILD.md](docs/BUILD.md) for the build process and [docs/TESTING.md](docs/TESTING.md) for automated and manual testing.

GitHub Actions runs the test suite, validates package names, builds the ISO, inspects its contents, boots it in QEMU and uploads the verified image as a workflow artifact.

## Project structure

```
assets/       branding, logos, icons and wallpaper
desktop/      XFCE defaults, themes, shell setup and LightDM
live/config/  live-build configuration and package list
scripts/      cindra utility and build helpers
docs/         build, testing, component and troubleshooting docs
tests/        automated tests and virtual-machine boot test
.github/      GitHub Actions workflows
```

## Contributing

Issues and pull requests are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting changes. Please describe exactly what you tested; untested changes must be identified as such.

## License and credits

CindraOS project files are licensed under the MIT License. Debian packages and other bundled software retain their own licenses. CindraOS is built on Debian, the Linux kernel, XFCE, Arc and Papirus.

Created by **Daniel.cindra**.
