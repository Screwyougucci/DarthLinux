#!/usr/bin/env bash
set -euo pipefail

# Read-only package-version audit for ZDI-CAN-33367.
# This does NOT execute an exploit or modify a host system.
fixed_version="7.2.15.arch1-1"

package_info="$(pacman -Si linux)"
package_version="$(awk '$1 == "Version" && $2 == ":" { print $3; exit }' <<<"$package_info")"

if [[ -z "$package_version" ]]; then
  echo "::error::Could not determine the Arch Linux kernel package version."
  exit 2
fi

echo "Arch repository kernel package: linux $package_version"
echo "Known fixed Arch package baseline: $fixed_version"
echo "Relevant upstream fix: 79dc34beb1fdb3da79753e51e15c68591a2561fe"
echo

comparison="$(vercmp "$package_version" "$fixed_version")"
if (( comparison >= 0 )); then
  echo "RESULT: PACKAGE_VERSION_AT_OR_ABOVE_FIX_BASELINE"
  echo "The repository package version is at or above the known fixed baseline."
  echo "This is package-version evidence only; confirm the patch is present in the built kernel source and test the resulting ISO."
else
  echo "RESULT: PACKAGE_VERSION_BELOW_FIX_BASELINE"
  echo "::warning::The Arch repository package is older than the known fixed baseline and should be treated as potentially affected."
  echo "This does not prove a working exploit or establish runtime reachability."
fi

echo
echo "Installed kernel on this ephemeral runner (if any):"
uname -r
echo "Note: uname reports the runner kernel, not the kernel package that Darth Linux will install."
