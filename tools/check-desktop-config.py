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

boot_splash = ROOT / "profiles/darth/boot/splash.svg"
if not boot_splash.is_file():
    sys.exit("Darth boot splash SVG is missing.")
try:
    ET.parse(boot_splash)
except ET.ParseError as exc:
    sys.exit(f"Invalid Darth boot splash SVG: {exc}")
build_script = (ROOT / "build.sh").read_text(encoding="utf-8")
for token in ("rsvg-convert", "MENU BACKGROUND splash.png", "sed -i 's/Arch Linux/Darth Linux/g' \"$entry\"", "Darth Linux Live System"):
    if token not in build_script:
        sys.exit(f"Boot branding regression: build.sh is missing {token}")

wallpaper = PROFILE / "usr/share/backgrounds/darth-linux/wallpaper.svg"
if not wallpaper.is_file():
    sys.exit("Darth desktop wallpaper is missing.")

greeter = PROFILE / "etc/lightdm/lightdm-gtk-greeter.conf"
greeter_text = greeter.read_text(encoding="utf-8")
for setting in ("theme-name=adw-gtk3-dark", "icon-theme-name=Adwaita", "background=/usr/share/backgrounds/darth-linux/wallpaper.svg"):
    if setting not in greeter_text:
        sys.exit(f"LightDM greeter is missing setting: {setting}")

for gtk_settings in (
    PROFILE / "etc/skel/.config/gtk-3.0/settings.ini",
    PROFILE / "etc/skel/.config/gtk-4.0/settings.ini",
):
    settings_text = gtk_settings.read_text(encoding="utf-8")
    if "gtk-theme-name=adw-gtk3-dark" not in settings_text or "gtk-application-prefer-dark-theme=true" not in settings_text:
        sys.exit(f"GTK theme defaults are incomplete in {gtk_settings.relative_to(ROOT)}")

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

for app_name, expected_exec in (("darth-terminal.desktop", "xfce4-terminal --title=DARTH-TERMINAL"),
                          ("darth-files.desktop", "thunar")):
    entry_path = ROOT / "packaging" / app_name
    entry = configparser.ConfigParser(interpolation=None)
    entry.read(entry_path, encoding="utf-8")
    if entry.get("Desktop Entry", "Exec", fallback="") != expected_exec:
        sys.exit(f"Invalid Darth launcher entry: {app_name}")
    if app_name not in build_script:
        sys.exit(f"Build does not install {app_name}")

store = (ROOT / "tools/darth-store").read_text(encoding="utf-8")
for token in ("SEARCH_RE", "OFFICIAL_REPOSITORIES", '"pacman", "-Ss"', "re.escape(query)"):
    if token not in store:
        sys.exit(f"Darth Store search regression: missing {token}")
header = re.compile(r"^([A-Za-z0-9_-]+)/([A-Za-z0-9@._+:-]+)\s+(\S+)(?:\s+\[installed\])?$")
sample = "extra/firefox 145.0-1 [installed]"
match = header.fullmatch(sample)
if not match or match.group(1) != "extra" or match.group(2) != "firefox":
    sys.exit("Darth Store package-search result parser failed its regression sample.")

settings_source = (ROOT / "tools/darth-settings").read_text(encoding="utf-8")
if "Refresh audio devices" not in settings_source or 'refresh_audio.connect("clicked", read_volume)' not in settings_source:
    sys.exit("Darth Settings audio device refresh regression.")

ai_manager = (ROOT / "tools/darth-ai-manager").read_text(encoding="utf-8")
for token in ("/health", "server_ready", "apply_server_probe", "def do_shutdown(self)"):
    if token not in ai_manager:
        sys.exit(f"AI Manager readiness/shutdown regression: missing {token}")

watchtower = (ROOT / "tools/darth-watchtower").read_text(encoding="utf-8")
if "self.set_status(" in watchtower:
    sys.exit("Watchtower calls an undefined set_status method.")
for token in ("def show_message(", "os.o_excl", "0o600", "permission denied"):
    if token not in watchtower.lower():
        sys.exit(f"Watchtower regression check failed: missing {token}")

driver_source = (ROOT / "tools/darth-driver-manager").read_text(encoding="utf-8")
if "threading.Thread(target=worker,daemon=True).start()" not in driver_source or "GLib.idle_add(apply_refresh" not in driver_source:
    sys.exit("Driver Manager hardware inventory must run outside the GTK main thread.")

center_source = (ROOT / "tools/darth-center").read_text(encoding="utf-8").lower()
if "permission denied" not in center_source or "unknown (administrator permission required)" not in center_source:
    sys.exit("Darth Center firewall permission handling regression.")

control_source = (ROOT / "tools/darth-control-center").read_text(encoding="utf-8")
if "threading.Thread(target=worker, daemon=True).start()" not in control_source or "GLib.idle_add(apply_refresh, message)" not in control_source:
    sys.exit("Control Center status refresh must run in a worker thread and update GTK via GLib.")

control = (ROOT / "tools/darth-control-center").read_text(encoding="utf-8").lower()
if "permission denied" not in control or "unknown (administrator permission required)" not in control:
    sys.exit("Control Center firewall permission handling regression.")

print(f"Darth desktop checks passed: {len(xml_files)} XML configs, {len(svg_files)} SVG icons, theme, installer and dashboard regressions.")
