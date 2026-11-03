# What comes from Debian

CindraOS 0.3 is a Debian 13 ("trixie") derivative. This is not hidden: `apt`, `dpkg`
and the Debian repositories work normally, and `/etc/os-release` says `ID_LIKE=debian`.

## From Debian, unmodified

- Linux kernel (`linux-image-amd64`) and firmware packages
- live-boot, live-config, live-build (build tool), systemd, GRUB/syslinux
- XFCE, LightDM, Thunar, Mousepad, xfce4-terminal, whisker menu, screenshooter
- NetworkManager, PipeWire, pavucontrol, polkit
- Firefox ESR
- Arc theme (base for the GTK themes), Papirus icon theme
- Fonts: Noto, DejaVu
- All command line tools (coreutils, bash, apt, ...)

Each of these keeps its own license. See `/usr/share/doc/<package>/copyright`.

## Added by CindraOS (MIT)

- `scripts/cindra` installed as `/usr/local/bin/cindra`
- Cindra-Dark and Cindra-Light GTK themes (CSS layer over Arc) and generated xfwm4 themes
- logo, wallpaper, branding files
- XFCE defaults: panel layout, terminal colors, window manager settings
- shell prompt/banner (`/usr/share/cindra/shell/cindra.bashrc`)
- LightDM autologin config for the live user
- the build system

## Not done

- No custom kernel, bootloader or package manager.
- No attempt to hide Debian. The version is visible in `cindra info`.
