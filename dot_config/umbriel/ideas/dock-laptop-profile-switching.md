# Dock / laptop profile auto-switching (deferred)

Status: **working via kanshi (2026-09-21)** — after updating Umbriel to
`75e35316ae29`, kanshi auto-swaps the include symlink on dock/undock. Still an
external workaround; native Umbriel profile support would replace it.

## Resolved: installed build predated protocol-driven output disable

- The running binary is revision `aa9d523`, 30 commits behind this checkout.
- It logs `output-management: disabling outputs is not supported, use the
  config 'enabled' key` and fails the whole transaction when a head is disabled.
- Kanshi always emits an explicit enable/disable per head, so any profile that
  disables one (the dock profile, to turn off the internal panel) fails, and its
  `exec` never runs. Protocol-driven disable landed in `61c580b`, which is in
  this checkout but not in the installed build.
- Fixed by rebuilding/reinstalling Umbriel (`just install`). Verified: kanshi
  applies the `dock` profile, logs `configuration for profile 'dock' applied`,
  and runs the switcher.

## Also fixed while setting this up

- Both profiles targeted `eDP-2`, but the active internal panel is `eDP-1`
  (`card2-eDP-1` connected; `card1-eDP-2` disconnected). The dock profile's
  `enabled = false` and the laptop profile's scale/VRR/workspaces never matched
  it, so dock mode was NOT actually disabling the built-in panel. Renamed to
  `eDP-1` in `dock.toml`, `laptop.toml`, and the kanshi config. Verified: the
  internal panel now reports `enabled=False` while docked.
- Note: `laptop.toml`'s `scale = 1.50` and `vrr = "fullscreen"` on the internal
  panel take effect for the first time now. Adjust if that is not wanted.

## Implemented workaround (kanshi)

- `config.toml` includes `machine.toml`, a symlink to `dock.toml` or `laptop.toml`.
- `~/.config/kanshi/config` defines a `dock` profile (DP-10 + DP-11 present,
  internal `eDP-2` optionally disabled) and a `laptop` profile (`eDP-2` only).
  Each profile's `exec` calls `~/.config/umbriel/switch-profile.sh <profile>`,
  which repoints the symlink and runs `umbriel msg config-reload`.
- `kanshi` is in `general.autostart`.
- Umbriel profile files stay the source of truth for output geometry; kanshi
  only triggers the switch and toggles the internal panel.
- The `...output eDP-2 disable` directive uses kanshi's "any number" form so the
  profile still matches when the lid is closed and `eDP-2` is not connected.

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
