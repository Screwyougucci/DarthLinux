# Darth Proxy

Darth Proxy is a small GTK utility for configuring a **provider-supplied residential proxy** in a separate Firefox profile.

## Use

1. Install the custom tools: `sudo bash scripts/install-custom-tools.sh`.
2. Open **Darth Linux → Control Center → Residential Proxy**, or run `darth-proxy`.
3. Choose HTTP/HTTPS (HTTP CONNECT for HTTPS websites) or SOCKS5.
4. Enter the hostname, port, and optional username/password from your proxy provider.
5. Use **Test proxy** to check connectivity and the public IP reported by `api.ipify.org`.
6. Choose **Save & launch Firefox**. This starts a dedicated Firefox profile with the proxy configured.

The utility supports one endpoint at a time. Provider-specific rotating-session syntax, IP allowlisting, geo-targeting, and account dashboards remain provider-managed. For a rotating residential session, use the provider's documented hostname/port and username format.

## Storage and privacy

Settings are saved to `~/.config/darth-linux/proxy.json` with owner-only permissions (0600). The dedicated Firefox profile is `~/.mozilla/darth-proxy-profile`. Do not share your account credentials or commit local proxy configuration to Git. Firefox may prompt for proxy authentication when it first connects.

The test makes a request to `https://api.ipify.org` through the configured proxy. Do not run it if you do not want that endpoint to receive the request.

## Scope and limitations

- This configures only the dedicated Firefox profile; it does not redirect system-wide traffic or other applications.
- HTTP proxy mode uses the proxy for HTTP and HTTPS website requests (CONNECT). SOCKS5 mode enables remote DNS resolution.
- A proxy is not a VPN, does not encrypt arbitrary application traffic, and does not guarantee anonymity or prevent browser fingerprinting.
- Clear saved settings in the app and close the dedicated Firefox window to stop using the proxy. The app does not kill existing browser sessions.
- Use proxies in accordance with the provider's terms, applicable law, and the destination service's rules. Do not use them to evade bans, rate limits, or access controls.
