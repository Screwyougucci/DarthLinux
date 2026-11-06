#!/bin/sh
set -eu

if [ "$(uname -s)" != "Linux" ]; then
  echo "ERROR: the pinned Sandcastle Buildroot build must run on a Linux host." >&2
  exit 1
fi

missing=0
for tool in bash git make gcc g++ python3 wget cpio rsync bc perl file readelf sha256sum unzip tar patch gzip bzip2 xz flex bison awk sed find pkg-config; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'OK      %s\n' "$tool"
  else
    printf 'MISSING %s\n' "$tool"
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  echo "Install the missing Buildroot host tools, then rerun this check." >&2
  exit 1
fi

echo "Linux Buildroot host dependency check passed."
