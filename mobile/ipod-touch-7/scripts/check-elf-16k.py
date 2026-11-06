#!/usr/bin/env python3
"""Validate AArch64 ELF load-segment alignment for the 16 KiB Sandcastle ABI."""
import subprocess
import sys

PAGE_SIZE = 0x4000

def main(path):
    try:
        output = subprocess.check_output(
            ["readelf", "-lW", path], text=True, stderr=subprocess.STDOUT
        )
    except (OSError, subprocess.CalledProcessError) as exc:
        print(f"ERROR: cannot inspect ELF: {exc}", file=sys.stderr)
        return 2

    load_alignments = []
    relro = None
    for line in output.splitlines():
        fields = line.split()
        if not fields:
            continue
        if fields[0] == "LOAD" and len(fields) >= 8:
            load_alignments.append(int(fields[7], 0))
        elif fields[0] == "GNU_RELRO" and len(fields) >= 6:
            relro = (int(fields[2], 0), int(fields[5], 0))

    if not load_alignments:
        print("FAIL: ELF has no readable LOAD segments", file=sys.stderr)
        return 1

    invalid = [value for value in load_alignments
               if value < PAGE_SIZE or value % PAGE_SIZE != 0]
    if invalid:
        print("FAIL: LOAD alignment must be a multiple of 0x4000; found "
              + ", ".join(hex(value) for value in invalid), file=sys.stderr)
        return 1

    if relro is not None:
        start, size = relro
        end = start + size
        if start % PAGE_SIZE and end % PAGE_SIZE:
            print("FAIL: GNU_RELRO neither starts nor ends on a 16 KiB boundary",
                  file=sys.stderr)
            return 1

    print("PASS: LOAD segments satisfy 16 KiB alignment"
          + ("; GNU_RELRO boundary is aligned" if relro else ""))
    return 0

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} ELF_FILE", file=sys.stderr)
        raise SystemExit(2)
    raise SystemExit(main(sys.argv[1]))
