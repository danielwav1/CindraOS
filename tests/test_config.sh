#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
echo "Configuration"

for f in build.sh verify-iso.sh scripts/cindra scripts/configure-live.sh scripts/check-packages.sh desktop/shell/cindra.bashrc desktop/shell/skel-bashrc; do
    if bash -n "$ROOT/$f" 2>/dev/null; then pass "bash -n $f"; else fail "bash -n $f"; fi
done
for f in "$ROOT"/tests/*.sh; do
    if bash -n "$f" 2>/dev/null; then pass "bash -n tests/$(basename "$f")"; else fail "bash -n tests/$(basename "$f")"; fi
done

for f in scripts/gen-xfwm4.py scripts/render-assets.py; do
    if python3 -m py_compile "$ROOT/$f" 2>/dev/null; then pass "py_compile $f"; else fail "py_compile $f"; fi
done

while IFS= read -r f; do
    if python3 -c "import sys, xml.dom.minidom as m; m.parse(sys.argv[1])" "$f" 2>/dev/null; then pass "valid XML: ${f#$ROOT/}"; else fail "invalid XML: ${f#$ROOT/}"; fi
done < <(find "$ROOT/desktop" -name '*.xml' | sort)

out=$(bash -c 'source "$1"; echo "$ID|$ID_LIKE|$NAME|$VERSION_ID|$VARIANT_ID"' _ "$ROOT/assets/branding/os-release")
expect_eq "os-release fields" "cindra|debian|CindraOS|0.3|live" "$out"
out=$(bash -c 'source "$1"; echo "$VERSION|$EDITION|$STATUS|$AUTHOR"' _ "$ROOT/assets/branding/cindra-release")
expect_eq "cindra-release fields" "0.3|Live|experimental|Daniel.cindra" "$out"
expect_eq "VERSION file matches os-release" "$(tr -d '[:space:]' < "$ROOT/VERSION")" "$(bash -c 'source "$1"; echo "$VERSION_ID"' _ "$ROOT/assets/branding/os-release")"

list=$ROOT/live/config/package-lists/cindra.list.chroot
expect_eq "package list has no duplicates" 0 "$(sort "$list" | uniq -d | wc -l)"
expect_eq "package list has no blank lines" 0 "$(grep -c '^[[:space:]]*$' "$list")"
for p in xfce4 lightdm network-manager sudo live-boot live-config linux-image-amd64; do
    if grep -qx "$p" "$list"; then pass "package list contains $p"; else fail "package list lacks $p"; fi
done
for p in calamares debian-installer-launcher live-installer ssh openssh-server telnetd; do
    if grep -qx "$p" "$list"; then fail "package list must not contain $p"; else pass "package list excludes $p"; fi
done

expect_not_contains "no installer in boot parameters" "$(grep -- '--bootappend-live' "$ROOT/build.sh")" "install"
expect_contains "debian installer disabled" "$(cat "$ROOT/build.sh")" "--debian-installer none"
expect_not_contains "build script never calls a partitioning tool" "$(grep -vE '^\s*#' "$ROOT/build.sh")" "parted"
expect_not_contains "build script never formats" "$(cat "$ROOT/build.sh")" "mkfs"

unit=$(cat "$ROOT/desktop/systemd/cindra-password.service")
expect_contains "password unit runs after live-config" "$unit" "After=live-config.service"
expect_contains "password unit sets the cindra user password" "$unit" "cindra:cindra1"
expect_contains "password unit creates the user if missing" "$unit" "adduser"
expect_contains "pnd2_edac is blacklisted at boot" "$(cat "$ROOT/build.sh")" "modprobe.blacklist=pnd2_edac"
expect_contains "hook enables the password unit" "$(cat "$ROOT/scripts/configure-live.sh")" "systemctl enable cindra-password.service"
expect_contains "build stages the password unit" "$(cat "$ROOT/build.sh")" "cindra-password.service"

lm=$(cat "$ROOT/desktop/lightdm/50-cindra.conf")
expect_contains "lightdm autologin user is not root" "$lm" "autologin-user=cindra"
expect_contains "lightdm starts xfce" "$lm" "autologin-session=xfce"

rc=$(grep -o '#[0-9a-f]\{6\}' "$ROOT/desktop/xfce/skel/.config/xfce4/terminal/terminalrc" | wc -l)
expect_eq "terminal palette has 16 colors plus fg/bg/cursor" 19 "$rc"
for t in cindra-dark cindra-light; do
    f=$ROOT/desktop/themes/profiles/$t.theme
    for k in NAME DESCRIPTION GTK ICONS WM; do
        if grep -q "^$k=" "$f"; then pass "$t.theme has $k"; else fail "$t.theme lacks $k"; fi
    done
done
for d in Cindra-Dark Cindra-Light; do
    expect_file "$d index.theme" "$ROOT/desktop/themes/$d/index.theme"
    expect_file "$d gtk.css" "$ROOT/desktop/themes/$d/gtk-3.0/gtk.css"
done

tmp=$(mktemp -d)
python3 "$ROOT/scripts/gen-xfwm4.py" dark "$tmp/dark" && python3 "$ROOT/scripts/gen-xfwm4.py" light "$tmp/light"
expect_eq "xfwm4 theme generates 61 files" 61 "$(ls "$tmp/dark" | wc -l)"
expect_file "xfwm4 themerc" "$tmp/dark/themerc"
expect_file "xfwm4 close button" "$tmp/light/close-active.xpm"
rm -rf "$tmp"

finish
