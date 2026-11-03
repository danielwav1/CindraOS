# The live session

CindraOS 0.3 boots from the ISO into a RAM-backed overlay. Nothing is installed.

## Account

- user `cindra`, auto-login to XFCE
- password `cindra1` (set at boot by `cindra-password.service`, which runs after live-config creates the user)
- `sudo` works without a password
- the password is public, so don't reuse it anywhere; change it with `passwd` if you like (lost on reboot)

## What is written, and where

| Location | Lives in | Survives reboot |
|---|---|---|
| `/` changes, installed packages, `/etc` edits | overlay in RAM | no |
| `/home/cindra` | overlay in RAM | no |
| `/tmp`, `/run` | tmpfs | no |
| journal (`/run/log/journal`) | tmpfs | no |
| Wi-Fi passwords, NetworkManager connections | overlay in RAM | no |
| Firefox profile, bookmarks, downloads | overlay in RAM | no |
| the ISO / USB stick itself | read-only medium | unchanged |

Everything you do is gone after shutdown. Copy files you want to keep to another
drive first. RAM is the limit: large downloads or `cindra update` upgrades can fill it.

## Internal disks

The live system does not mount or modify internal disks on its own, and there is no
installer. Disks show up in the file manager. Mounting a fixed internal disk goes
through udisks2/polkit and asks for authentication. Removable media (USB sticks)
mount when you click them, as on any XFCE desktop. Once you mount something
read-write, you can of course change it.

## Persistence (not part of 0.3)

live-boot supports persistence, but CindraOS does not enable it. A later version could
document it like this:

1. Create a partition or file labelled `persistence` on the USB stick (not on an internal disk).
2. Put a file `persistence.conf` containing `/ union` on it.
3. Boot with the `persistence` parameter added.

This writes to the stick, so it needs to be opt-in and clearly explained. It would
also need a decision about encryption (live-boot supports LUKS persistence).
