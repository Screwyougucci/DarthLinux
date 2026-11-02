# Darth Security Toolkit

The profile groups tools for network discovery, web application assessment, wireless auditing, password auditing, reverse engineering, digital forensics, and defensive inspection. Package availability must be validated by an Archiso build.

## Custom utilities

Install them with:

```bash
sudo bash scripts/install-custom-tools.sh
```

- `darth-audit`: read-only local snapshot of kernel, firewall/network service status, block-device/filesystem view, listening sockets, and SSH server configuration. It makes no configuration changes and sends no probes.
- `darth-scope-scan`: Nmap host discovery only (`nmap -sn -n`) against a private IPv4 range no larger than /24. It requires explicit permission confirmation. No exploit scripts, brute force, or service/version scan.

## Responsible use

Only assess systems and wireless networks you own or have explicit written permission to test. Confirm scope, timing, and rate limits with the owner. Do not use tools to access, disrupt, or monitor third-party systems. The custom utilities intentionally use read-only or tightly scoped defaults.

## Build validation

The package names are a proposed Arch repository set, not a verified build. If a package is unavailable, fix the list or move it to a separately reviewed optional installer; do not silently fetch untrusted binaries.
