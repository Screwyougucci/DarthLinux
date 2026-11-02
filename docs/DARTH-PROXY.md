# Darth Proxy

Darth Proxy is a GTK utility for managing multiple **provider-supplied residential proxy profiles** and launching each in a dedicated Firefox profile.

## Set up a provider profile

1. Install custom tools: `sudo bash scripts/install-custom-tools.sh`.
2. Open **Darth Linux → Control Center → Residential Proxy**, or run `darth-proxy`.
3. Select **New**, enter a profile name, proxy type, gateway hostname, port, and provider credentials.
4. Select **Save profile**. You can save multiple providers, regions, or endpoints and switch between them from the profile selector.
5. Select a saved profile and choose **Test selected proxy** or **Connect / launch Firefox**.

HTTP proxy mode uses HTTP CONNECT for HTTPS websites. SOCKS5 mode enables remote DNS resolution. Firefox may prompt for HTTP proxy authentication when the browser first connects. Native Firefox SOCKS5 username/password authentication is not reliable; use provider IP allowlisting if offered or an HTTP proxy endpoint when available.

## Provider-supported session rotation

Some providers issue a new exit IP when the username contains a provider-specific session identifier. If your provider documents this feature:

1. Put its exact username format in **Username template**.
2. Insert `{session}` exactly where the provider says the session ID belongs.
3. Save the profile.
4. Choose **New provider session + launch** to generate a fresh random session token and open a new Firefox profile.

Example format only (not a real provider syntax): `customer-123-session-{session}`.

This feature changes only the session token. It cannot guarantee a different IP: the provider controls session duration, IP assignment, pool availability, and rotation policy. If your provider rotates only on a timer or API call, use the provider's own documented mechanism; this utility does not guess private provider APIs. The older Firefox window is not terminated automatically. Close previous proxy browser windows when switching or rotating so you do not continue using the old session.

## Testing

The test makes a request to `https://api.ipify.org` through the selected proxy and displays the public IP returned by that endpoint. The endpoint will receive the request. Test results confirm only that the test request succeeded; they do not prove anonymity, location accuracy, or that every browser request follows the proxy.

## Storage and privacy

Profiles are stored in `~/.config/darth-linux/proxy-profiles.json`; the directory is set to 0700 and the file to 0600. Credentials are stored locally in that file, not encrypted at rest. Protect your Linux account and disk, and never commit or share this file. Dedicated Firefox profiles are created under `~/.mozilla/` with owner-only directory and preference-file permissions.

## Scope and limitations

- Proxy settings apply only to the dedicated Firefox profile, not the whole operating system or other applications.
- A proxy is not a VPN, does not encrypt arbitrary application traffic, and does not prevent browser fingerprinting.
- SOCKS5 provider username/password authentication may not work in Firefox; prefer IP allowlisting or HTTP proxy mode if the provider supports it.
- Automatic rotation requires a provider-documented `{session}` username format. The tool does not automate provider dashboards, payment, API calls, or IP guarantees.
- Use proxies under the provider's terms and applicable law. Do not use them to evade bans, rate limits, or access controls.
