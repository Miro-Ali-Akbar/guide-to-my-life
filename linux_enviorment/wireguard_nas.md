# Make a permanent connection to my nas

1. Import the config: `nmcli connection import type wireguard file nas.conf`
2. Enable autoconnect `nmcli connection modify nas connection.autoconnect yes`
3. Start it: `nmcli connection up nas`
4. Verify: `nmcli connection show --active | grep wg-client`
5. In nautilus connect to `smb://storage.miro.zip/share`
