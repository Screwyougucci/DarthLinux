#!/usr/bin/env python3
"""Static regression checks for Darth desktop integration and known UI regressions."""
import ast
import configparser
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROFILE = ROOT / "profiles/darth/airootfs"
PACKAGES = set(
    line.strip() for line in (ROOT / "profiles/darth/packages.x86_64").read_text().splitlines()
    if line.strip() and not line.lstrip().startswith("#")
)

required_packages = {"adw-gtk-theme", "adwaita-icon-theme", "librsvg", "noto-fonts"}
missing = sorted(required_packages - PACKAGES)
if missing:
    sys.exit("Missing desktop theme dependencies: " + ", ".join(missing))

xml_files = list((PROFILE / "etc/skel/.config").rglob("*.xml"))
svg_files = list((PROFILE / "usr/share/icons").rglob("*.svg"))
for path in xml_files + svg_files:
    try:
        ET.parse(path)
    except ET.ParseError as exc:
        sys.exit(f"Invalid XML in {path.relative_to(ROOT)}: {exc}")

wallpaper = PROFILE / "usr/share/backgrounds/darth-linux/wallpaper.svg"
if not wallpaper.is_file():
    sys.exit("Darth desktop wallpaper is missing.")

greeter = PROFILE / "etc/lightdm/lightdm-gtk-greeter.conf"
greeter_text = greeter.read_text(encoding="utf-8")
for setting in ("theme-name=adw-gtk3-dark", "icon-theme-name=Adwaita", "background=#0b0d12"):
    if setting not in greeter_text:
        sys.exit(f"LightDM greeter is missing setting: {setting}")

terminal = PROFILE / "etc/skel/.config/xfce4/terminal/terminalrc"
terminal_text = terminal.read_text(encoding="utf-8")
for setting in ("ColorBackground=#0b0d12", "ColorForeground=#edf0f5", "ColorCursor=#c51d38"):
    if setting not in terminal_text:
        sys.exit(f"Darth terminal theme is missing setting: {setting}")

installer = ROOT / "tools/darth-installer"
desktop = ROOT / "packaging/darth-installer.desktop"
if not installer.is_file() or not desktop.is_file():
    sys.exit("Darth Installer command or desktop entry is missing.")
desktop_config = configparser.ConfigParser(interpolation=None)
desktop_config.read(desktop, encoding="utf-8")
if desktop_config.get("Desktop Entry", "Exec", fallback="") != "darth-installer":
    sys.exit("Darth Installer desktop entry does not launch darth-installer.")

store = (ROOT / "tools/darth-store").read_text(encoding="utf-8")
for token in ("SEARCH_RE", "OFFICIAL_REPOSITORIES", '"pacman", "-Ss"', "re.escape(query)"):
    if token not in store:
        sys.exit(f"Darth Store search regression: missing {token}")
header = re.compile(r"^([A-Za-z0-9_-]+)/([A-Za-z0-9@._+:-]+)\s+(\S+)(?:\s+\[installed\])?$")
sample = "extra/firefox 145.0-1 [installed]"
match = header.fullmatch(sample)
if not match or match.group(1) != "extra" or match.group(2) != "firefox":
    sys.exit("Darth Store package-search result parser failed its regression sample.")

watchtower = (ROOT / "tools/darth-watchtower").read_text(encoding="utf-8")
if "self.set_status(" in watchtower:
    sys.exit("Watchtower calls an undefined set_status method.")
for token in ("def show_message(", "os.O_EXCL", "0o600", "permission denied"):
    if token not in watchtower.lower():
        sys.exit(f"Watchtower regression check failed: missing {token}")

control = (ROOT / "tools/darth-control-center").read_text(encoding="utf-8").lower()
if "permission denied" not in control or "unknown (administrator permission required)" not in control:
    sys.exit("Control Center firewall permission handling regression.")

print(f"Darth desktop checks passed: {len(xml_files)} XML configs, {len(svg_files)} SVG icons, theme, installer and dashboard regressions.")
