#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
list=$root/live/config/package-lists/cindra.list.chroot

command -v apt-cache >/dev/null || { echo "check-packages: apt-cache not found, run this on Debian" >&2; exit 3; }

codename=$(. /etc/os-release && echo "${VERSION_CODENAME:-unknown}")
if [[ $codename != trixie ]]; then
    echo "check-packages: this host is '$codename'; results only count on Debian 13 (trixie)" >&2
fi

missing=0
while read -r pkg; do
    [[ -z $pkg ]] && continue
    if apt-cache show "$pkg" >/dev/null 2>&1; then
        printf '  ok       %s\n' "$pkg"
    else
        printf '  MISSING  %s\n' "$pkg"
        missing=$((missing + 1))
    fi
done < "$list"

echo
if (( missing )); then
    echo "$missing package(s) not found. Run 'apt-get update' (with non-free-firmware enabled) and check the names."
    exit 1
fi
echo "all packages found"
