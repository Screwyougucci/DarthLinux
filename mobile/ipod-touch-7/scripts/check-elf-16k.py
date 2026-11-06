#!/usr/bin/env python3
"""Check ELF program-header alignment against Sandcastle's 16 KiB ABI note."""
import re
import subprocess
import sys

PAGE = 0x4000

def main(path: str) -> int:
    output = subprocess.check_output(
        ["readelf", "-lW", path], text=True, stderr=subprocess.STDOUT
    )
    loads = []
    relro = None
    for line in output.splitlines():
        fields = line.split()
        if not fields:
            continue
        if fields[0] == "LOAD" and len(fields) >= 8:
            loads.append(int(fields[7], 0))
        elif fields[0] == "GNU_RELRO" and len(fields) >= 6:
            relro = (int(fields[2], 0), int(fields[5], 0))
    if not loads:
        print("FAIL: no ELF LOAD segments found", file=sys.stderr)
        return 1
    bad = [align for align in loads if align < PAGE or align % PAGE != 0]
    if bad:
        print("FAIL: LOAD segment alignment below 16 KiB: " +
              ", ".join(hex(value) for value in bad), file=sys.stderr)
        return 1
    if relro is not None:
        start, size = relro
        end = start + size
        if start % PAGE != 0 and end % PAGE != 0:
            print("FAIL: GNU_RELRO neither starts nor ends on a 16 KiB boundary",
                  file=sys.stderr)
            return 1
    print("PASS: ELF LOAD segments satisfy 16 KiB alignment" +
          ("; GNU_RELRO boundary is aligned" if relro else ""))
    return 0

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} ELF_FILE", file=sys.stderr)
        raise SystemExit(2)
    raise SystemExit(main(sys.argv[1]))
