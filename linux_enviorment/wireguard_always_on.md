# Make a WireGuard tunnel always-on (NetworkManager)

Import a `.conf` as a native NetworkManager connection and set it to
autoconnect, instead of manually running `wg-quick up`.

1. Import the config: `nmcli connection import type wireguard file /path/to/client.conf`
2. Find its name: `nmcli connection show` (defaults to the filename minus `.conf`)
3. Enable autoconnect: `nmcli connection modify <name> connection.autoconnect yes`
4. Bring it up now (or just reboot/reconnect wifi): `nmcli connection up <name>`

It'll reconnect automatically on boot/network changes from here on -
check status anytime with `nmcli connection show --active` or `wg show`.

## Avoiding conflicts with another VPN on the same subnet

If another always-on VPN (school, work) uses the same private range as
the one you're tunneling into (very common with `192.168.0.0/24` and
`10.0.0.0/8`), both can't claim the same broad route at once - whichever
connects second usually wins, silently breaking the other.

Fix: don't route real LAN subnets through the tunnel's `AllowedIPs` at
all. Instead:
- Pick a small IP range that only exists inside the tunnel itself (e.g.
  `10.200.0.0/24`) and use *only* that in the client's `AllowedIPs`.
- On the WireGuard server, `iptables` DNAT-translates one fake address
  in that range to the real destination:
  ```
  # in wg0.conf, [Interface] section
  PostUp = iptables -t nat -A PREROUTING -i wg0 -d 10.200.0.100 -p tcp --dport 445 -j DNAT --to-destination 192.168.0.176:445
  PostDown = iptables -t nat -D PREROUTING -i wg0 -d 10.200.0.100 -p tcp --dport 445 -j DNAT --to-destination 192.168.0.176:445
  ```
- Point DNS (or just remember) at the fake address (`10.200.0.100`),
  never the real one.

This way the client's routing table never claims any real-world subnet,
so it can run permanently alongside any other VPN with zero collision
risk - used for reaching my home NAS (`storage.miro.zip`) from outside
without fighting my school VPN over `192.168.0.0/24`.
