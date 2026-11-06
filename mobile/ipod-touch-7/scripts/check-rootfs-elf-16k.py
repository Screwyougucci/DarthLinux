#!/usr/bin/env python3
"""Audit every AArch64 ELF in a Buildroot target tree for 16 KiB page alignment."""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

PAGE_SIZE = 0x4000
ELF_MAGIC = b"\x7fELF"


def inspect_elf(path: Path) -> tuple[bool, str]:
    header = subprocess.run(
        ["readelf", "-hW", str(path)], text=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    if header.returncode != 0:
        return False, f"{path}: readelf header failed: {header.stderr.strip()}"
    if "Machine:" not in header.stdout or "AArch64" not in header.stdout:
        return True, "SKIP"
    # Kernel modules and relocatable objects have no LOAD segments to align.
    if "Type:" in header.stdout and "REL (Relocatable file)" in header.stdout:
        return True, "SKIP"
    result = subprocess.run(
        ["readelf", "-lW", str(path)], text=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        return False, f"{path}: readelf program headers failed: {result.stderr.strip()}"

    load_alignments: list[int] = []
    relro: tuple[int, int] | None = None
    for line in result.stdout.splitlines():
        fields = line.split()
        if not fields:
            continue
        if fields[0] == "LOAD" and len(fields) >= 8:
            try:
                load_alignments.append(int(fields[-1], 0))
            except ValueError:
                return False, f"{path}: could not parse LOAD alignment: {line}"
        elif fields[0] == "GNU_RELRO" and len(fields) >= 6:
            try:
                relro = (int(fields[2], 0), int(fields[5], 0))
            except ValueError:
                return False, f"{path}: could not parse GNU_RELRO segment: {line}"

    if not load_alignments:
        return False, f"{path}: no ELF LOAD segments found"
    bad = [value for value in load_alignments
           if value < PAGE_SIZE or value % PAGE_SIZE != 0]
    if bad:
        return False, (
            f"{path}: LOAD alignment below 16 KiB: "
            + ", ".join(hex(value) for value in bad)
        )
    if relro is not None:
        start, size = relro
        if start % PAGE_SIZE != 0 and (start + size) % PAGE_SIZE != 0:
            return False, f"{path}: GNU_RELRO does not start or end on a 16 KiB boundary"
    return True, "PASS"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("target_tree", type=Path)
    args = parser.parse_args()
    if not args.target_tree.is_dir():
        parser.error(f"not a directory: {args.target_tree}")

    scanned = 0
    failures: list[str] = []
    for path in args.target_tree.rglob("*"):
        if path.is_symlink() or not path.is_file():
            continue
        try:
            with path.open("rb") as stream:
                if stream.read(4) != ELF_MAGIC:
                    continue
        except OSError as exc:
            failures.append(f"{path}: read failed: {exc}")
            continue
        ok, message = inspect_elf(path)
        if message == "SKIP":
            continue
        scanned += 1
        if ok:
            print(f"PASS {path}")
        else:
            failures.append(message)

    if scanned == 0:
        print("FAIL: no AArch64 ELF files found in target tree", file=sys.stderr)
        return 1
    if failures:
        for failure in failures:
            print("FAIL " + failure, file=sys.stderr)
        print(f"FAIL: {len(failures)} of {scanned} AArch64 ELF files violate the 16 KiB ABI",
              file=sys.stderr)
        return 1
    print(f"PASS: all {scanned} AArch64 ELF files satisfy the 16 KiB ABI")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
