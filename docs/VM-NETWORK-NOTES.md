# Darth Linux Virtual Machines, Network Lab, and Notes

## Virtual machine manager

The desktop image includes QEMU/KVM, libvirt, virt-manager, dnsmasq, and OVMF firmware.

- Open **Virtual Machine Manager** from the XFCE applications menu.
- Create a VM from an ISO obtained from its official publisher.
- Use NAT networking for the default guest network.
- Do not bridge a guest onto a network unless you understand that it will become visible on that LAN.
- Keep untrusted test guests isolated; do not share host folders, USB devices, or credentials with them.
- VM performance depends on CPU virtualization support (Intel VT-x / AMD-V), available RAM, and disk space. Older or low-memory computers may run VMs slowly. No VM is created or started automatically.

## Network tools

Included tools:
- `nmap` for authorized host/service discovery
- `tcpdump` and `wireshark-cli` for packet capture and analysis
- `traceroute`, `mtr`, and `iperf3` for route and performance diagnostics
- `bind` tools (`dig` / `nslookup`), `whois`, and `netcat` for network troubleshooting

Only scan or capture traffic on systems and networks you own or have explicit permission to assess. Packet captures can contain private information; store and share them carefully.

## Notepad

**Mousepad** is the lightweight graphical notepad/editor. Find it in XFCE Accessories, or launch it with:

```bash
mousepad
```

It opens and saves plain-text notes, scripts, and configuration files. Use a normal user account for editing; use administrator privileges only when a system file genuinely requires them.
