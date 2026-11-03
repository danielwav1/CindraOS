# CindraOS

A Debian-based live Linux with a red C-mark, a dark XFCE desktop and its own command line tool, `cindra`. Boot it from a USB stick, use it, shut down, and your disks are untouched.

> **Experimental version 0.4.0 (Live Edition).** Not every hardware configuration has been tested. Expect rough edges and please report problems.

[Download](https://github.com/danielwav1/CindraOS/releases/latest) · [Website](https://danielwav1.github.io/CindraOS) · [Issues](https://github.com/danielwav1/CindraOS/issues)

## Screenshots

> *Placeholders. Add real screenshots to `docs/screenshots/`.*

| | |
|---|---|
| `desktop.png` | Desktop with panel and wallpaper (placeholder) |
| `terminal.png` | Terminal with the V banner (placeholder) |
| `cindra-info.png` | `cindra info` (placeholder) |

## Features

- Live system for USB sticks and virtual machines, BIOS and UEFI
- No installer, nothing is written to your disks
- XFCE desktop with Cindra-Dark and Cindra-Light themes, red accent, own wallpaper and panel
- File manager, text editor, screenshot tool, task manager, Firefox ESR
- NetworkManager, PipeWire audio, power management
- Terminal with a red C-mark banner, clear prompt and handy aliases
- The `cindra` tool for system info, checks, updates, logs and network diagnosis
- No telemetry and no hidden network services

CindraOS is based on Debian 13 "trixie". The kernel, package manager and nearly all software come from Debian. See [docs/DEBIAN-COMPONENTS.md](docs/DEBIAN-COMPONENTS.md).

## Requirements

| | |
|---|---|
| CPU | 64-bit x86 (amd64). ARM and 32-bit are not supported |
| RAM | 2 GB minimum, 4 GB or more recommended |
| USB stick | 8 GB or larger |
| Firmware | BIOS/legacy or UEFI. **Turn Secure Boot off** |
| Network | Wi-Fi firmware for common Intel, Realtek and Atheros chips is included |

## Install on a USB stick

1. Download `CindraOS-0.4.0-live-amd64.iso` from the [Releases page](https://github.com/danielwav1/CindraOS/releases/latest). Optionally check it against the `.sha256` file:
   ```
   sha256sum -c CindraOS-0.4.0-live-amd64.iso.sha256
   ```
2. Flash it. **This erases the whole stick.**

   | From | Tool | How |
   |---|---|---|
   | Android | [EtchDroid](https://etchdroid.app) | **Flash raw image**, select the `.iso`, needs a USB-OTG adapter |
   | Windows | Rufus or balenaEtcher | In Rufus choose **DD Image mode** |
   | Linux / macOS | `dd` | see below |

   ```
   lsblk
   sudo dd if=CindraOS-0.4.0-live-amd64.iso of=/dev/sdX bs=4M status=progress conv=fsync
   ```
   Replace `/dev/sdX` with your stick and double-check it with `lsblk`.

## Boot

1. Plug the stick into the PC and open the boot menu (usually F12, F10, Esc or F2 right after power-on).
2. Choose the USB entry. If it doesn't appear, disable Secure Boot.
3. CindraOS starts the desktop and logs in as `cindra` (password `cindra1`, needed for admin dialogs).

Black screen? On the boot entry press `e`, add `nomodeset` to the kernel line and boot.

To try it in a VM first:

```
qemu-system-x86_64 -m 3072 -smp 2 -enable-kvm -cdrom CindraOS-0.4.0-live-amd64.iso -boot d
```

### Good to know

- It is a live session. **Everything you change is lost when you shut down.** Save files to another drive.
- Internal disks are not touched; mounting one asks for authentication.
- `sudo` works without a password.
- Login: user `cindra`, password `cindra1` (public, never reuse it elsewhere). The desktop logs in automatically.
- The system runs from RAM, so large downloads or upgrades can fill it.

More in [docs/LIVE-SESSION.md](docs/LIVE-SESSION.md).

## The `cindra` command

Run `cindra help` for the overview. Options before the command: `-y/--yes` (answers yes in `update` and `clean`, never in `repair`) and `--no-color`.

| Command | What it does |
|---|---|
| `cindra help` | command overview |
| `cindra version [--short]` | version and edition |
| `cindra info` | system overview |
| `cindra sys` | kernel, CPU, memory, swap, uptime, disk |
| `cindra checkup` | checks the important system components |
| `cindra desktop` | desktop session, components, active themes |
| `cindra update` | refresh package lists, upgrade after confirmation |
| `cindra clean` | show and remove the package cache and unused packages after confirmation |
| `cindra repair` | read-only diagnostics, fixes only after confirmation |
| `cindra logs [errors\|boot\|kernel\|unit NAME] [-n N]` | system logs |
| `cindra network [--offline]` | interfaces, gateway, DNS and HTTPS check |
| `cindra theme [list\|current\|set NAME]` | switch between `cindra-dark` and `cindra-light` |
| `cindra about` | project information |
| `cindra report [-o FILE]` | local diagnostic report with personal data masked; nothing is sent anywhere |
| `cindra banner` | startup banner |

Exit codes: `0` ok, `1` failure, `2` usage error, `3` missing dependency. `cindra network` contacts `deb.debian.org` unless you pass `--offline`.

## Known limitations

- Secure Boot, ARM, an installer and persistent storage are not available in 0.3
- The boot menu uses the default live-build look, no custom boot splash yet
- The GTK themes are a thin layer over Arc; GTK4/libadwaita apps keep their own look
- Only amd64 images are built
- Hardware compatibility has not been tested broadly

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md). When reporting a bug, attach the output of `cindra report` after reading it.

## Build it yourself

You need Debian 13 (or Debian 12 with a newer `debootstrap`, or a Debian container), about 20 GB free space and `sudo`.

```
sudo apt install live-build debootstrap squashfs-tools xorriso python3 python3-pil python3-numpy file mtools dosfstools git
git clone https://github.com/danielwav1/CindraOS.git
cd CindraOS
chmod +x build.sh verify-iso.sh scripts/*.sh scripts/cindra tests/*.sh
./build.sh
```

The ISO and its checksum end up in `out/`. No Debian machine? Run the **build-iso** workflow under the Actions tab. Details: [docs/BUILD.md](docs/BUILD.md). Tests: `bash tests/run.sh`, see [docs/TESTING.md](docs/TESTING.md).

## Project layout

```
build.sh  verify-iso.sh  VERSION
assets/       logo, wallpaper, branding files
desktop/      XFCE defaults, themes, shell setup, LightDM
live/config/  live-build package list
scripts/      cindra and build helpers
docs/         build, testing, troubleshooting, live session
tests/        test suite
```

## Contributing

Pull requests are welcome, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT for the CindraOS files, see [LICENSE](LICENSE). Debian packages in the image keep their own licenses.

## Credits

Created by **Daniel.cindra**. Built on Debian, the Linux kernel, XFCE, the Arc theme and Papirus icons.
