# Building the ISO

## Requirements

- Debian 13 "trixie" (recommended) or Debian 12 with a newer `debootstrap` from backports.
  A Debian container or VM on any other distribution works too. Ubuntu hosts are not
  supported (`build.sh` refuses unless `CINDRA_ALLOW_UNSUPPORTED=1`).
- x86_64 host, about 20 GB free disk space, a few GB of RAM, internet access
- root access through `sudo`. `build.sh` calls `sudo` only for `lb config`, `lb build`
  and cleaning the work directory.

```
sudo apt install live-build debootstrap squashfs-tools xorriso python3 file mtools dosfstools git
```

`build.sh` checks the host before it does anything and the installed live-build against
every option it intends to use (`lb config --help`).

## Steps

```
git clone https://github.com/danielwav1/CindraOS.git
cd CindraOS
chmod +x build.sh verify-iso.sh scripts/*.sh scripts/cindra tests/*.sh
bash scripts/check-packages.sh    # optional: are all package names valid on this host?
./build.sh --check                # preflight only
./build.sh                        # the real build
```

Result in `out/`:

- `CindraOS-0.3-live-amd64.iso`
- `CindraOS-0.3-live-amd64.iso.sha256`
- `CindraOS-0.3-live-amd64.packages` / `.contents` (if live-build produced them)
- `build-<timestamp>.log`

`build.sh` runs `verify-iso.sh` at the end. Use `./build.sh --no-verify` to skip it, and
`./verify-iso.sh --deep out/CindraOS-0.3-live-amd64.iso` for a check inside the root filesystem.

## How it works

1. `stage` copies `live/config/` into `build/work/config/` and adds the files from
   `assets/`, `desktop/` and `scripts/` as `includes.chroot`. The xfwm4 themes are
   generated here by `scripts/gen-xfwm4.py`.
2. `lb config` is called with the options visible at the top of `build.sh`.
3. `lb build` bootstraps Debian, installs `cindra.list.chroot`, runs
   `scripts/configure-live.sh` as a chroot hook and writes the hybrid ISO.
4. The ISO is copied to `out/`, checksummed and verified.

The build never touches partitions or block devices. It only writes inside
`build/` and `out/`.

## Options and environment

| | |
|---|---|
| `--check` | preflight only |
| `--clean` | delete `build/work` (also the package cache) |
| `--no-verify` | skip verify-iso.sh |
| `CINDRA_WORK_DIR`, `CINDRA_OUT_DIR` | change directories |
| `CINDRA_MIN_FREE_GB` | required free space, default 20 |
| `CINDRA_LOCALE`, `CINDRA_KEYMAP` | default language/keyboard of the live session |
| `CINDRA_MIRROR` | use another Debian mirror |

A second build reuses `build/work/cache`, so it is faster.

## Reproducibility

`SOURCE_DATE_EPOCH` is set from the last git commit. Beyond that, builds are not
bit-for-bit identical: packages come from the live Debian archive, so two builds on
different days differ. Pinning a snapshot mirror via `CINDRA_MIRROR` gets closer, but
this has not been tried.

## Writing the image to a USB stick

Triple-check the device name. This erases the stick.

```
lsblk
sudo dd if=out/CindraOS-0.3-live-amd64.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

Or use a graphical tool such as balenaEtcher. Test in a VM first (docs/TESTING.md).

## Building without a Debian machine (GitHub Actions)

Push the repository to GitHub, open the Actions tab, run "build-iso" and download the
`cindraos-iso` artifact when it finishes. The workflow (`.github/workflows/build-iso.yml`)
builds inside a privileged `debian:trixie` container. It has not been run yet; GitHub
runners have limited disk space, so if the build runs out, lower the package list or use
a larger runner.
