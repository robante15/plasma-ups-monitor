#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
package_dir=$(dirname "$script_dir")
catalog_dir="$package_dir/contents/locale/es/LC_MESSAGES"

mkdir -p "$catalog_dir"
msgfmt --check --check-header \
    --output-file="$catalog_dir/plasma_applet_io.maciek.plasma.upsmonitor.mo" \
    "$script_dir/es.po"
