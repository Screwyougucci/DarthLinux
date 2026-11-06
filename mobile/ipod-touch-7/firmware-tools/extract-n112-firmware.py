#!/usr/bin/env python3
"""Extract the iPod touch 7 N112 multitouch properties from an Apple IPSW.

The helper reads the IPSW ZIP and APFS image with HTTP range requests; it does
not download the multi-gigabyte IPSW in full and does not connect to or modify
an iPod. The extracted Apple firmware is proprietary and must remain local.
"""
from __future__ import annotations

import argparse
import hashlib
import plistlib
import re
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
DEFAULT_URL = (
    "https://updates.cdn-apple.com/2025FallFCS/fullrestores/122-76865/"
    "68174A8B-44B2-4689-B8D4-C8F42F4FFBEE/"
    "iPodtouch_7_15.8.8_19H422_Restore.ipsw"
)
ROOTFS_PATH = "/usr/share/firmware/multitouch/N112.mtprops"
PERSONALITY = "C1F58,1"


def run(command: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        command,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
    )


def find_rootfs_dmg(url: str) -> str:
    # Apple names restore images differently across iOS releases. The APFS
    # root filesystem image is the largest .dmg in this device's IPSW.
    result = run(
        [sys.executable, str(HERE / "ipswget.py"), url, "list", "*.dmg"],
        capture=True,
    )
    matches: list[tuple[int, str]] = []
    for line in result.stdout.splitlines():
        match = re.match(r"^\s*(\d+)\s+(.+?)\s*$", line)
        if match:
            matches.append((int(match.group(1)), match.group(2)))
    if not matches:
        raise RuntimeError("The IPSW contains no .dmg entries")
    size, name = max(matches)
    if size < 1_000_000_000:
        details = "\n".join(f"{nbytes:12d}  {path}" for nbytes, path in matches)
        raise RuntimeError(
            "No large root filesystem DMG was found; pass --dmg explicitly.\n" + details
        )
    print(f"Selected root filesystem image: {name} ({size:,} bytes)")
    return name


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ipsw-url", default=DEFAULT_URL)
    parser.add_argument("--dmg", help="Exact root filesystem DMG path inside the IPSW")
    parser.add_argument(
        "--output",
        type=Path,
        default=HERE.parent / "firmware" / "N112.mtprops",
    )
    parser.add_argument("--force", action="store_true", help="Replace an existing output file")
    args = parser.parse_args()

    if args.output.exists() and not args.force:
        parser.error(f"{args.output} already exists; pass --force to replace it")

    try:
        dmg = args.dmg or find_rootfs_dmg(args.ipsw_url)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        run([
            sys.executable,
            str(HERE / "ipswfs.py"),
            args.ipsw_url,
            dmg,
            ROOTFS_PATH,
            str(args.output),
        ])
        props = plistlib.loads(args.output.read_bytes())
        if not isinstance(props, dict) or PERSONALITY not in props:
            raise RuntimeError(f"Extracted plist does not contain N112 personality {PERSONALITY}")
        personality = props[PERSONALITY]
        if not isinstance(personality, dict) or "Constructed Firmware" not in personality:
            raise RuntimeError("N112 personality has no Constructed Firmware payload")
        digest = hashlib.sha256(args.output.read_bytes()).hexdigest()
        print(f"PASS: extracted N112 multitouch properties ({args.output.stat().st_size} bytes)")
        print(f"Personality: {PERSONALITY}")
        print(f"SHA-256: {digest}")
        print("The firmware file is local and must not be committed or uploaded.")
        return 0
    except (OSError, RuntimeError, subprocess.CalledProcessError, plistlib.InvalidFileException) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
