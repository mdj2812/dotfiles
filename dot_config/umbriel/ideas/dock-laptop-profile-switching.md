# Dock / laptop profile auto-switching (deferred)

Status: **waiting for official Umbriel support** — do not implement the workaround yet.

## Goal

Automatically switch between `dock.toml` and `laptop.toml` when docking or
undocking, without manually editing `config.toml` or restarting the session.

## Current setup

- `config.toml` includes one profile via `[include].files`.
- `dock.toml` — DP-11 (main) + DP-10 (portrait), eDP-2 disabled.
- `laptop.toml` — eDP-2 only, numbered/named workspaces on built-in panel.
- Switching today: change the include line and run `umbriel msg config-reload`.

## Proposed workaround (if official support does not arrive)

1. Include a single `machine.toml` symlink instead of hard-coding dock/laptop.
2. Script detects dock by DP-11 connector status:
   `cat /sys/class/drm/card1-DP-11/status` → `connected` = dock.
3. Symlink `machine.toml` → `dock.toml` or `laptop.toml`, then `config-reload`.
4. Trigger via:
   - `general.autostart` (session start only), and/or
   - systemd user path unit on DRM hotplug, and/or
   - manual keybind.

## What official support could look like

- Built-in profile selection (e.g. `[[profile]]` with match rules on connected
  outputs).
- Hot-reload when profile match changes on output connect/disconnect.
- Per-profile window rules and output layout without symlink/script hacks.

## Caveats noted

- eDP-2 may report `connected` even with lid closed; prefer detecting external
  DP-11 rather than eDP absence.
- Window rules differ between profiles; open windows may not fully rearrange
  until relaunch.
- `general.autostart` is shared across profiles.

## Discord feature request

Draft posted in conversation on 2026-08-25. See message template below if needed
for follow-up.
