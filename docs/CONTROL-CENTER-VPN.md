# Darth Control Center and VPN

## Darth Control Center

The 0.5 post-install setup installs the GTK4 dashboard and its launcher. On a fresh Archinstall target, first run `sudo bash scripts/install-custom-tools.sh` from the Darth Linux repository checkout:

```bash
sudo bash scripts/install-custom-tools.sh
```

Then open **Darth Control Center** from the XFCE applications menu, or run `darth-control-center`.

The dashboard provides launchers for Virtual Machine Manager, NetworkManager's connection editor, btop, local network diagnostics, Darth Notes, ClamUI, Darth Center, and the scope-limited lab scanner. It also displays the current NetworkManager VPN connection state and nftables service state.

## VPN support

Darth Linux includes:
- NetworkManager's native WireGuard support, plus `wireguard-tools`
- OpenVPN and the NetworkManager OpenVPN plugin
- `nm-connection-editor` for importing and managing profiles

To configure a VPN, obtain a client configuration from a VPN provider or administrator you trust. Open **VPN Connections** in Darth Control Center, add a connection, and import the provider's supported `.ovpn` or WireGuard configuration. Then connect from NetworkManager. WireGuard is supported natively by NetworkManager; OpenVPN uses its NetworkManager plugin.

Darth Linux does not include a paid VPN subscription, VPN server, or anonymous relay. A VPN shifts trust from the local network/ISP to the VPN operator; it does not make a user anonymous or protect against malware, account tracking, or unsafe browsing. Check DNS and IPv6 leak behavior with the provider's documented tests. A kill switch is not configured by default, so do not assume traffic is blocked if the tunnel drops.

Protect VPN configuration files: WireGuard profiles contain private keys. Keep them private, restrict file permissions, and never commit them to Git.

## Hardware and validation notes

The VM manager requires CPU virtualization support and enough memory for the guest. The control center and VPN features are configured in the build profile, but the ISO still needs a complete Archiso build and boot test before release.
