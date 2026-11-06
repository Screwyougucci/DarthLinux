#!/bin/sh
set -eu

missing=0
for tool in git make gcc g++ python3 wget cpio rsync bc perl file readelf sha256sum; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'OK      %s\n' "$tool"
  else
    printf 'MISSING %s\n' "$tool"
    missing=1
  fi
done

if [ "$(uname -s)" != "Linux" ]; then
  echo "WARNING: Sandcastle build/loader tooling expects a Linux host."
fi

if [ "$missing" -ne 0 ]; then
  echo "Install the missing host tools, then rerun this check." >&2
  exit 1
fi

echo "Host dependency check passed."
