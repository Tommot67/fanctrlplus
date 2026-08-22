#!/bin/bash
# Build the Slackware-style package consumed by unraid/fanctrlplus.plg.
set -euo pipefail

version="${1:-}"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Usage: $0 <version, e.g. 1.3.4>" >&2
  exit 1
fi

project_root="$(cd "$(dirname "$0")/.." && pwd)"
release_dir="$project_root/release"
stage_dir="$(mktemp -d)"
package_root="$stage_dir/usr/local/emhttp/plugins/fanctrlplus"
package="$release_dir/fanctrlplus-$version.txz"

cleanup() { rm -rf "$stage_dir"; }
trap cleanup EXIT

mkdir -p "$package_root" "$release_dir"
tar -C "$project_root" \
  --exclude=.git --exclude=release --exclude=unraid \
  -cf - . | tar -C "$package_root" -xf -
tar -C "$stage_dir" -cJf "$package" .

echo "Package: $package"
md5sum "$package"
