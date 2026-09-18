# Discord feature request draft — dock / laptop profile switching

Copy one of the versions below into the Umbriel Discord server.

---

## Full version

**Feature request: automatic dock / laptop profile switching**

I use Umbriel on a laptop that docks to dual external monitors. Right now I keep separate include files (`dock.toml` vs `laptop.toml`) and manually switch the `[include]` list in `config.toml`, then `umbriel msg config-reload`.

**Use case:** When I plug/unplug the dock (or start a session docked vs on battery), I'd like Umbriel to automatically pick the right output layout, workspace inventory, and window rules — without editing config or restarting the session.

**What would help:**
- Profiles matched by connected outputs (e.g. "if DP-11 is connected → dock profile, else laptop profile")
- Hot-reload when the match changes on hotplug
- Per-profile output config + window rules

**Workaround I'm considering:** symlink `machine.toml` + a script watching `/sys/class/drm/.../status` + `config-reload`, but I'd rather wait for first-class support if it's on the roadmap.

Is something like this planned, or is there a recommended pattern I'm missing?

---

## Short version

Any plans for dock/laptop profile auto-switching? I split output + window rules into separate include files (`dock.toml` / `laptop.toml`) and switch manually today. Would love profiles keyed off connected outputs with hot-reload on hotplug.
