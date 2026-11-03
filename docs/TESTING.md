# Testing

```
bash tests/run.sh          # automated tests
bash tests/run.sh --vm     # plus the live boot test (needs qemu-system-x86_64 and xorriso)
```

None of the tests write to real block devices. The report test writes to a temp directory.
The VM test attaches the ISO read-only as a CD-ROM and no disks at all.

## Automated tests

| File | Covers |
|---|---|
| `test_cli.sh` | help, version, info, sys, checkup, desktop, unknown command (exit 2), missing dependency (exit 3), theme listing and errors, report masking, clean/repair without a terminal |
| `test_config.sh` | `bash -n` and `py_compile`, XML validity, os-release and release file, package list rules, no installer, autologin user, terminal palette, theme files, xfwm4 generator |
| `test_assets.sh` | SVG validity, PNG sizes, red logo / monochrome logos, wallpaper, branding files |
| `test_iso.sh` | runs `verify-iso.sh` on an existing ISO, skipped when none exists |
| `vm-boot.sh` | boots the ISO's kernel/initrd with the ISO attached, waits for the login prompt on the serial console |

### Result of the last run

Run on Ubuntu 24.04 (x86_64, no systemd, no network, no live-build):

```
Total: 141 passed, 0 failed, 1 skipped
```

The skipped test is the ISO check: no ISO exists yet. The VM test was not run.

Not covered by these runs: `update`, `repair` (with confirmations), `network` with
connectivity, `theme set` and `desktop` inside a real XFCE session, `logs` against a
real journal. They need a running CindraOS system.

## Manual tests (to do on a built image)

- [ ] ISO boots in a VM (BIOS mode)
- [ ] ISO boots in a VM with OVMF (UEFI mode)
- [ ] ISO boots from a USB stick on at least one real machine
- [ ] Boot menu shows the CindraOS name
- [ ] Auto-login reaches the XFCE desktop, wallpaper with red V is shown
- [ ] Panel: menu button shows the red V, launchers, tray, volume, power, clock, session menu
- [ ] Window decorations match the theme (red edge on the active window, buttons work)
- [ ] `cindra theme set cindra-light` and back to `cindra-dark`
- [ ] Terminal: banner appears once, prompt shows user@host:dir, exit code shows after a failing command
- [ ] `cindra checkup` has no failures; `cindra network` works with a connection
- [ ] `cindra update` refreshes lists; `cindra clean` and `cindra repair` ask before changing anything
- [ ] Wi-Fi works with `network-manager-gnome`; sound plays; screenshot tool works
- [ ] Firefox starts and loads a page
- [ ] `ss -tulpn` shows no listening services besides the DHCP client
- [ ] Internal disk is not mounted after boot; mounting it asks for authentication
- [ ] `cat /etc/os-release` shows CindraOS; `cindra info` shows the right base version
- [ ] After reboot all changes are gone

Record the result of each box with the hardware or VM used. Nothing in this project
claims that every hardware configuration has been tested.
