# Building CindraOS

## Requirements

- Debian 13 Trixie on an x86_64 host
- Approximately 20 GB free disk space
- Internet access
- Root access through `sudo`
- A working Debian `live-build` and `debootstrap` installation

Install the build dependencies:

```bash
sudo apt update
sudo apt install live-build debootstrap squashfs-tools xorriso python3 python3-pil python3-numpy file mtools dosfstools sbsigntool ovmf qemu-system-x86 initramfs-tools-core git
```

The build script checks the host, required tools, debootstrap suite support, live-build options and available disk space before building.

## Build steps

```bash
git clone https://github.com/danielwav1/CindraOS.git
cd CindraOS
chmod +x build.sh verify-iso.sh scripts/*.sh scripts/cindra tests/*.sh
bash tests/run.sh
bash scripts/check-packages.sh
./build.sh --check
./build.sh
```

The resulting ISO, SHA-256 checksum, build log and any package/content manifests are written to `out/`.

The expected image name for this release is:

```
out/CindraOS-1.0.0-live-amd64.iso
out/CindraOS-1.0.0-live-amd64.iso.sha256
```

## Build process

1. The staging step copies live-build configuration and CindraOS assets into the work directory.
2. The XFWM4 window themes are generated.
3. `lb config` configures a Debian Trixie amd64 hybrid ISO and requires signed UEFI boot files with `--uefi-secure-boot enable`.
4. `lb build` bootstraps Debian, installs the declared package list and runs the CindraOS chroot hook.
5. The image is copied to `out/`, checksummed and verified.
6. CI checks the shim, GRUB and kernel signatures, then boots the ISO in OVMF with Secure Boot enabled.

The build script writes only to its configured work and output directories. It does not partition or format drives.

## Verification

The normal build runs `verify-iso.sh` after creating the image. To inspect the root filesystem as well:

```bash
./verify-iso.sh --deep out/CindraOS-1.0.0-live-amd64.iso
```

The deep check extracts the live SquashFS temporarily and verifies CindraOS identity files and required components.

Boot testing in QEMU:

```bash
sudo apt install qemu-system-x86
bash tests/vm-boot.sh out/CindraOS-1.0.0-live-amd64.iso
bash tests/vm-secure-boot.sh out/CindraOS-1.0.0-live-amd64.iso
```

## Options and environment

| Option or variable | Purpose |
|---|---|
| `--check` | Run preflight checks without building |
| `--clean` | Remove the marked build work directory |
| `--no-verify` | Skip the post-build verification (not recommended) |
| `CINDRA_WORK_DIR` | Override the work directory |
| `CINDRA_OUT_DIR` | Override the output directory |
| `CINDRA_MIN_FREE_GB` | Required free space; default 20 GB |
| `CINDRA_LOCALE` | Default live-session locale |
| `CINDRA_KEYMAP` | Default keyboard layout |
| `CINDRA_MIRROR` | Alternate Debian mirror |

## Reproducibility

The build sets `SOURCE_DATE_EPOCH` from the source commit. Package repositories are not snapshot-pinned, so builds made at different times may contain different Debian package revisions and are not guaranteed to be bit-for-bit identical.

## GitHub Actions

The `.github/workflows/build-iso.yml` workflow runs on pushes to `main` and `release/1.0-stable`, version tags, or manual dispatch. It:

1. Installs the Debian Trixie build and QEMU dependencies.
2. Renders artwork and runs the automated test suite.
3. Validates package names; this step is required to pass.
4. Builds the ISO and performs deep filesystem verification.
5. Boots the image in QEMU and waits for the live login prompt.
6. Uploads the ISO, checksum, manifests and build log as an artifact.

A successful workflow confirms the automated checks and QEMU boot test. It does not prove compatibility with every physical computer.
