# Troubleshooting

## Build

**`host 'ubuntu' is not supported`**
Use Debian 12/13 or a Debian container. Ubuntu's live-build and debootstrap differ.

**`debootstrap on this host has no script for 'trixie'`**
Upgrade debootstrap. On Debian 12: `sudo apt -t bookworm-backports install debootstrap`.

**`this live-build does not know --some-option`**
Your live-build is older or newer than the one this project was written against.
Run `lb config --help`, adjust `LB_ARGS` in `build.sh`, and please open an issue.

**`E: Unable to locate package ...` during `lb build`**
Run `bash scripts/check-packages.sh` on Debian 13 to find the name that does not exist
and fix `live/config/package-lists/cindra.list.chroot`. Firmware packages need the
`non-free-firmware` archive area, which `build.sh` enables.

**`configure-live: expected ... is missing`**
The chroot hook found a file that should have been installed. The message names it.
Usually a package name changed (for example Arc theme) or staging in `build.sh` was edited.

**Not enough space**
`CINDRA_MIN_FREE_GB` can be lowered, but a build needs roughly 10 to 15 GB of work space.

**The build stops halfway**
Read the end of `out/build-*.log`. After a failed build run `./build.sh --clean` and retry.
Mirror problems are common: try `CINDRA_MIRROR=https://deb.debian.org/debian`.

## Live system

**Black screen after boot**
Try booting in a VM first. On some graphics hardware, add `nomodeset` to the kernel
line in the boot menu (press `e` in GRUB or Tab in syslinux).

**No Wi-Fi**
Check `cindra network` and `rfkill list`. Firmware for common Intel/Realtek/Atheros chips
is included; other chips may need packages that CindraOS 0.3 does not ship.

**The theme looks half dark, half default**
The GTK theme imports Arc-Dark. If `/usr/share/themes/Arc-Dark` is missing, only the
red accent rules apply. `cindra checkup` and the build hook both check for it.

**`cindra theme set` fails**
It needs a running desktop session (`DBUS_SESSION_BUS_ADDRESS`). Run it from a terminal
inside XFCE, not from a TTY or via plain `sudo`.

**Out of memory during `cindra update`**
Everything lives in RAM. Upgrade fewer packages, or don't upgrade in a live session.
