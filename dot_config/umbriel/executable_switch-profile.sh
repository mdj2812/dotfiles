#!/bin/sh
# Point Umbriel's active machine profile at the requested one and reload.
#
# Usage: switch-profile.sh <dock|laptop>
#
# The Umbriel config includes "machine.toml", which is a symlink to the active
# profile file. Repointing the symlink re-resolves the include list, and the
# explicit reload makes the switch deterministic even if the file watcher
# already noticed the change.
#
# The reload always runs, even when the target is already active: kanshi's
# profile only names outputs (it does not carry geometry), so applying it can
# leave a monitor on its preferred mode. Reloading re-applies the profile's
# configured mode, position, and scale over the top of that.
set -eu

profile="${1:?usage: switch-profile.sh <dock|laptop>}"
dir="${XDG_CONFIG_HOME:-$HOME/.config}/umbriel"
target="$dir/$profile.toml"

if [ ! -f "$target" ]; then
    echo "switch-profile: no such profile: $target" >&2
    exit 2
fi

ln -sfn "$target" "$dir/machine.toml"

umbriel="$(command -v umbriel || true)"
if [ -z "$umbriel" ]; then
    umbriel=/usr/local/bin/umbriel
fi
exec "$umbriel" msg config-reload
