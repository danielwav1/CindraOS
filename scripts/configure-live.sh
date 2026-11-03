#!/bin/bash
set -eu

ln -sf ../usr/lib/os-release /etc/os-release
echo cindraos > /etc/hostname
printf '127.0.0.1\tlocalhost\n127.0.1.1\tcindraos\n::1\tlocalhost ip6-localhost ip6-loopback\n' > /etc/hosts

for loc in en_US.UTF-8 de_DE.UTF-8; do
    sed -i "s/^# *${loc} UTF-8/${loc} UTF-8/" /etc/locale.gen
done
locale-gen

xfconf_dir=/etc/xdg/xfce4/xfconf/xfce-perchannel-xml
mkdir -p "$xfconf_dir"
{
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo '<channel name="xfce4-desktop" version="1.0">'
    echo '  <property name="backdrop" type="empty">'
    echo '    <property name="screen0" type="empty">'
    for mon in 0 Virtual-1 VGA-1 HDMI-1 HDMI-A-1 DP-1 DP-2 eDP-1 LVDS-1 Virtual1 VGA1 HDMI1 eDP1; do
        echo "      <property name=\"monitor$mon\" type=\"empty\">"
        echo '        <property name="workspace0" type="empty">'
        echo '          <property name="color-style" type="int" value="0"/>'
        echo '          <property name="image-style" type="int" value="5"/>'
        echo '          <property name="last-image" type="string" value="/usr/share/backgrounds/cindra/cindra-default.png"/>'
        echo '        </property>'
        echo '      </property>'
    done
    echo '    </property>'
    echo '  </property>'
    echo '</channel>'
} > "$xfconf_dir/xfce4-desktop.xml"

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor
    gtk-update-icon-cache -f -t /usr/share/icons/Cindra-Icons
fi

if update-alternatives --list x-terminal-emulator 2>/dev/null | grep -q xfce4-terminal.wrapper; then
    update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper
fi

for unit in avahi-daemon cups cups-browsed ssh exim4; do
    if systemctl cat "$unit.service" >/dev/null 2>&1; then
        systemctl disable "$unit.service"
    fi
done

systemctl enable cindra-password.service
systemctl set-default graphical.target
chmod 755 /usr/local/bin/cindra
chmod -R go-w /etc/skel

missing=0
for path in /usr/local/bin/cindra /etc/cindra-release /usr/lib/os-release \
            /usr/share/themes/Arc-Dark/gtk-3.0/gtk.css /usr/share/themes/Cindra-Dark/xfwm4/themerc \
            /usr/share/icons/Papirus-Dark /usr/share/backgrounds/cindra/cindra-default.png \
            /usr/share/cindra/themes/cindra-dark.theme /etc/lightdm/lightdm.conf.d/50-cindra.conf \
            /etc/systemd/system/cindra-password.service; do
    if [ ! -e "$path" ]; then
        echo "configure-live: expected $path is missing" >&2
        missing=1
    fi
done
exit "$missing"
