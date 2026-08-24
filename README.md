# Dotfiles and CachyOS rebuild notes

This repository contains portable user configuration managed by chezmoi. It is
public: credentials, application databases, and machine-owned system files must
stay in the encrypted reinstall backup.

## Install the Niri + Noctalia desktop

On a fresh Arch/CachyOS installation:

```sh
sudo pacman -Syu
sudo pacman -S --needed - < packages/niri-noctalia.txt
chezmoi init --apply mdj2812/dotfiles
niri validate
```

Use the `Niri` display-manager session or start `niri-session` from a TTY. Do
not start a login session with raw `niri`; the session wrapper initializes the
graphical systemd target and portals.

The curated desktop list deliberately selects the repository `noctalia`
package. The old-machine inventory contains `noctalia-git`; do not install both.
Review `packages/pacman-explicit.txt` and `packages/aur-explicit.txt` rather than
blindly reinstalling the old Plasma desktop.

## Desktop integration

- `~/.config/niri/config.kdl` starts Noctalia and the KDE polkit agent.
- Niri starts `xwayland-satellite` on demand; do not spawn it or set `DISPLAY`
  manually.
- `~/.config/xdg-desktop-portal/niri-portals.conf` sends screencasting to the
  GNOME backend, ordinary portals and file picking to GTK, and Secret requests
  to gnome-keyring. Do not restore the old generic `portals.conf`.
- Noctalia supplies notifications, launcher, wallpaper, volume/brightness OSD,
  window switching, and locking.
- The Noctalia theme templates depend on the `~/Share/workspace/noctalia`
  checkout. Mount the NAS before applying themes.
- Herdr generates its own color files and agent-state scripts. Re-run the Herdr
  integrations after installation; the generated theme/script output is not
  tracked.
- Fcitx5 configuration and environment variables are managed here. Confirm the
  generated XDG autostart unit runs inside the Niri session.

Noctalia's main `settings.toml` is intentionally absent because it contains
service credentials and private state. Restore it from the encrypted backup
before starting Noctalia if the old layout and plugin settings are required.
Plugin source/materialization directories and caches are re-fetchable.

## Packages and services

- `packages/pacman-explicit.txt`: exact native explicit-package inventory from
  the old installation.
- `packages/aur-explicit.txt`: exact foreign/AUR explicit-package inventory.
- `packages/niri-noctalia.txt`: curated desktop packages for the new system.
- `services/system-enabled.txt` and `services/user-enabled.txt`: audit
  inventories, not scripts to enable every unit automatically.

Review the service lists after installing packages. In particular, restore only
the services still needed for NetworkManager, Bluetooth, SSH, UFW, Ollama,
RustDesk, Sunshine, snapshots, and hybrid graphics. Plasma Login Manager should
not be enabled unless it remains the chosen display manager.

## Fonts and icons

The desktop manifest installs Noto fonts, JetBrains Mono Nerd Font, and Papirus.
Other package-provided themes should be reinstalled through pacman. The custom
Seven Segment font and any irreplaceable user-owned assets are in the encrypted
backup; third-party font and icon trees are not committed to this public repo.

## Machine-owned state

Restore these from the encrypted backup, with their original ownership and
permissions:

- `/etc/fstab` and the separate NAS/CIFS credential file
- `/etc/NetworkManager/system-connections/`
- `/etc/ssh/ssh_host_*_key`
- `/etc/modprobe.d/supergfxd.conf`
- bootloader, firewall, and custom PAM configuration

This laptop uses hybrid AMD/NVIDIA graphics. Keep NVIDIA GBM/KMS support enabled;
the previous system used `nvidia-drm.modeset=1`. If Niri starts to a black
screen, verify the driver, KMS command line, and render device before adding a
hard-coded `render-drm-device`.

`~/Share` is NFS-backed and survives a local reinstall only if the NAS is
healthy. The reinstall backup on that mount is not a substitute for a separate
NAS backup.

Wake-critical read-only assets under Share (wallpapers and avatar) are mirrored
one-way to `~/.cache/share-cache` by `~/.local/bin/share-cache-sync`. Share
remains the source of truth; the cache is for fast local reads after resume.

After applying dotfiles:

```sh
share-cache-sync
systemctl --user daemon-reload
systemctl --user enable --now share-cache-sync.timer share-cache-sync-wake.service
```

Point Noctalia wallpaper and avatar paths at `~/.cache/share-cache/Pictures/...`
instead of `~/Share/Pictures/...`. Theme templates and workspace files should
keep using `~/Share/workspace/...` directly.

Optional earliest resume sync (requires sudo once per machine):

```sh
sudo ~/.local/share/share-cache/install-system-sleep-hook.sh
```

## Restore verification

Before wiping and again after installation:

```sh
chezmoi doctor
chezmoi status
niri validate
systemctl --user status niri.service
systemctl --user status xdg-desktop-portal.service
```

Confirm that the chezmoi branch is synchronized, the encrypted archive decrypts,
the NAS mounts, gnome-keyring unlocks, Noctalia can lock the session, portals can
share the screen, and an X11 application opens through xwayland-satellite.
