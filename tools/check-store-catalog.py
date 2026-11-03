#!/usr/bin/env python3
"""Validate Darth Store catalogs against the current official Arch Extra index."""
import ast
import re
import subprocess
import sys
from pathlib import Path

source = Path("tools/darth-store").read_text(encoding="utf-8")
tree = ast.parse(source, filename="tools/darth-store")
catalogs = {}
for node in tree.body:
    if isinstance(node, ast.Assign):
        for target in node.targets:
            if isinstance(target, ast.Name) and target.id in {"CATALOG", "FLATPAK_CATALOG"}:
                catalogs[target.id] = ast.literal_eval(node.value)

if set(catalogs) != {"CATALOG", "FLATPAK_CATALOG"}:
    sys.exit("Store catalog declarations are missing or not literal data.")

try:
    result = subprocess.run(
        ["pacman", "-Sl", "extra"], text=True, capture_output=True,
        timeout=90, check=False
    )
except (OSError, subprocess.TimeoutExpired) as exc:
    sys.exit(f"Could not read the official Extra package index: {exc}")

if result.returncode:
    sys.exit("pacman -Sl extra failed: " + (result.stderr or result.stdout)[-4000:])

available = {
    fields[1] for line in result.stdout.splitlines()
    if len(fields := line.split()) >= 2
}
packages = [entry[2] for entry in catalogs["CATALOG"]]
missing = sorted(set(packages) - available)
if missing:
    sys.exit("Packages missing from official Extra: " + ", ".join(missing))
if len(packages) != len(set(packages)):
    sys.exit("Duplicate package names found in the Store catalog.")

flatpak_ids = [entry[1] for entry in catalogs["FLATPAK_CATALOG"]]
valid_id = re.compile(r"^[A-Za-z0-9_-]+(?:\.[A-Za-z0-9_-]+){2,}$")
invalid = sorted(app_id for app_id in flatpak_ids if not valid_id.fullmatch(app_id))
if invalid:
    sys.exit("Invalid Flatpak application IDs: " + ", ".join(invalid))
if len(flatpak_ids) != len(set(flatpak_ids)):
    sys.exit("Duplicate Flatpak application IDs found.")

print(f"Store catalog OK: {len(packages)} official Extra packages, "
      f"{len(flatpak_ids)} curated Flathub apps.")
