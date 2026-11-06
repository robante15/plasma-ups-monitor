#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
package_dir=$(dirname "$script_dir")
pot_file=$(mktemp)
file_list=$(mktemp)
trap 'rm -f "$pot_file" "$file_list"' EXIT HUP INT TERM

cd "$package_dir"
find contents/ui -type f -name '*.qml' -print | sort > "$file_list"
xgettext \
    --language=JavaScript \
    --from-code=UTF-8 \
    --add-location=file \
    --keyword=i18n:1 \
    --keyword=i18nc:1c,2 \
    --flag=i18nc:2:no-javascript-format \
    --package-name=io.maciek.plasma.upsmonitor \
    --msgid-bugs-address=https://github.com/maku2903/plasma-ups-monitor/issues \
    --files-from="$file_list" \
    --output="$pot_file"

msgmerge --update --backup=none "$script_dir/es.po" "$pot_file"
mv "$pot_file" "$script_dir/template.pot"
chmod 644 "$script_dir/template.pot"
