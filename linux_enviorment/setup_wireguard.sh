#!/bin/bash
#
# Usage: sudo ./setup_wireguard.sh /path/to/client.conf
#
#

set -euo pipefail

# --- Local network where nas is hosted
HOME_SSID="The_Armor"
LAN_HOSTNAME="storage.miro.zip"
LAN_IP="192.168.0.176"
SMB_SHARE="share"
REAL_USER="${SUDO_USER:-$(logname)}"
REAL_UID="$(id -u "$REAL_USER")"
# ---

if [ "$#" -ne 1 ]; then
    echo "Usage: sudo $0 <path-to-wireguard-client.conf>" >&2
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    echo "This needs root" >&2
    exit 1
fi

CONF_PATH="$1"
if [ ! -f "$CONF_PATH" ]; then
    echo "Config file not found: $CONF_PATH" >&2
    exit 1
fi

CONF_NAME="$(basename "$CONF_PATH" .conf)"

echo "Importing $CONF_PATH as NetworkManager connection '$CONF_NAME'"
nmcli connection delete "$CONF_NAME" 2>/dev/null || true
nmcli connection import type wireguard file "$CONF_PATH"

echo "Enabling autoconnect for '$CONF_NAME'"
nmcli connection modify "$CONF_NAME" connection.autoconnect yes

echo "Bringing the tunnel up now"
nmcli connection up "$CONF_NAME"

echo "Installing split-DNS dispatcher script for $LAN_HOSTNAME"
DISPATCHER_PATH="/etc/NetworkManager/dispatcher.d/90-${CONF_NAME}-split-dns"
cat > "$DISPATCHER_PATH" <<EOF

#!/bin/bash
# Sets up home nas configuration

HOSTS_MARKER="# $LAN_HOSTNAME (home LAN override, managed by NetworkManager dispatcher)"
HOSTS_LINE="$LAN_IP $LAN_HOSTNAME \$HOSTS_MARKER"
HOME_SSID="$HOME_SSID"
REAL_USER="$REAL_USER"
REAL_UID="$REAL_UID"

is_home() {
    nmcli -t -f active,ssid dev wifi 2>/dev/null | grep -q "^yes:\${HOME_SSID}\$"
}

sed -i "\\|\$HOSTS_MARKER|d" /etc/hosts

if is_home; then
    echo "\$HOSTS_LINE" >> /etc/hosts
fi

# GVFS/Nautilus keeps the previous SMB session alive across network
# changes, so a saved bookmark tries the dead connection first and hangs
# through a slow SMB timeout before retrying fresh. Force-unmount it here
# so the next click always starts clean.
sudo -u "\$REAL_USER" \\
    XDG_RUNTIME_DIR="/run/user/\$REAL_UID" \\
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/\$REAL_UID/bus" \\
    gio mount -u "smb://$LAN_HOSTNAME/$SMB_SHARE" >/dev/null 2>&1 || true
EOF
chmod 755 "$DISPATCHER_PATH"
chown root:root "$DISPATCHER_PATH"

echo "Running dispatcher script once now to apply immediately"
"$DISPATCHER_PATH"

echo "Done. Current resolution for $LAN_HOSTNAME:"
getent hosts "$LAN_HOSTNAME" || echo "  (not in /etc/hosts - will resolve via normal DNS instead)"

echo "Tunnel status:"
nmcli connection show --active | grep "$CONF_NAME" || echo "  (not active - check nmcli connection show --active)"
