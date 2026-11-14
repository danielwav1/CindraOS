# Testing CindraOS

Run the local automated tests:

```bash
bash tests/run.sh
```

After building an ISO, run the deep image check and QEMU boot test:

```bash
bash verify-iso.sh --deep out/CindraOS-1.0.0-live-amd64.iso
bash tests/vm-boot.sh out/CindraOS-1.0.0-live-amd64.iso
```

The VM test attaches the ISO as a read-only CD-ROM and does not attach a writable virtual disk.

## Automated test coverage

| Test | Coverage |
|---|---|
| `test_assets.sh` | SVG validity, PNG dimensions, logos, wallpaper and branding files |
| `test_config.sh` | Shell syntax, Python compilation, XML, release metadata, package-list rules, live configuration and theme assets |
| `test_cli.sh` | CLI commands, exit codes, missing dependencies, theme handling, report creation and identifier masking |
| `test_iso.sh` | ISO verification when an image is available |
| `vm-boot.sh` | Boots the built live image in QEMU and waits for the login prompt |

The test runner treats missing summaries and unexpected test-script failures as failures. A skipped ISO test before an image exists is expected during the pre-build test stage.

## Stable build pipeline

GitHub Actions runs the tests and package validation before building. It then verifies the ISO contents and boots the image in QEMU. The workflow must complete successfully before its artifact is considered a verified CI build.

## Manual hardware validation

QEMU testing does not replace testing on physical devices. Record the exact machine and result when performing these checks:

- [ ] Boot from USB in legacy BIOS mode
- [ ] Boot from USB in UEFI mode
- [ ] Reach the XFCE desktop after automatic login
- [ ] Confirm the Cindra wallpaper, panel, launchers and tray
- [ ] Confirm window decorations and both theme profiles
- [ ] Run `cindra checkup`
- [ ] Test wired and wireless networking on the device
- [ ] Test audio input and output
- [ ] Launch Firefox ESR
- [ ] Confirm internal disks are not automatically modified
- [ ] Confirm the live session resets after reboot

## Not covered automatically

The automated tests do not fully validate every GPU, Wi-Fi adapter, sound device, suspend/resume path, physical USB controller, or firmware implementation. They also do not establish that all optional CLI operations work correctly on every physical system.

When reporting a bug, include the device model and relevant error messages. You may attach `cindra report`, but inspect the report first because automated masking cannot guarantee removal of every personal detail.
