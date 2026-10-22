# 02 - Users and workflows

## Users
| User | Role | Access | Source |
|---|---|---|---|
| Ven | Owner, sole operator, hobbyist developer | Workstation (`G:\Projects\Hardware\AynThor`) and the Thor over SSH key auth (`armada@<thor-ip>`) | `CLAUDE.md` ("Device access", "Git and GitHub") |
| Device user `armada` | The account the tweaks run as on the Thor (UID 1000) | Passwordless sudo on the Thor, granted by Ven (`/etc/sudoers.d/91-claude-full`) | `CLAUDE.md`; `tweaks/system/thor-display-sync.py` (`HOME` and `XDG_RUNTIME_DIR` hard-coded to UID 1000) |
| Other contributors | None in this repo | - | `CREDITS.md` lists upstream authors whose code is adapted, not repo contributors |

## Workflows

### W1 - Deploy the tweaks to the Thor
Entry point: `tweaks/apply-all-tweaks.sh` with one mode flag and an optional host.

| Step | Action | Notes | Source |
|---|---|---|---|
| 1 | Check that `local/thor.env` (or `THOR_HOST`) gives a host | Exit 2 if none | `apply-all-tweaks.sh` header block |
| 2 | Check key-based SSH reachability (`BatchMode=yes`, 8 s) | Exit 2 if unreachable | `apply-all-tweaks.sh` |
| 3 | Pick a mode: `--audio`, `--lighting`, `--system`, `--wowlan`, `--status` or `--all` | `--all` is the default when no flag is given | `apply-all-tweaks.sh` (`MODE="${1:---all}"`) |
| 4 | Verify on the device | Use `--status` | `show_status()` |

Known behaviour: `--all` runs the audio and system deploys and status, but skips the stick-RGB daemon (`apply-all-tweaks.sh`, NOTE line). See [05](05-requirements-testing-limitations.md) for the conflict with `docs/armada/dual-screen-dimming.md`.

### W2 - Remove what earlier sessions left behind
`tweaks/cleanup-device.sh` is a dry run by default. Re-run with `--apply` to change the device. Steps and their reasons are in `docs/hardware/device-observed.md` ("Re-survey 2026-10-07", as the script header says). See [03](03-tools-reference.md#cleanup-devicesh).

### W3 - Install the 80 % battery ceiling
Not in this repo. Use the Gleipnir plugin repo: `plugins/gleipnir/scripts/deploy.sh`, then the Decky UI (`tweaks/README.md` section 2).

### W4 - Log battery and power state
Run `tweaks/battery-monitor.py` on the Thor with `python3`. It writes JSON lines to `~/battery-logs/` and never writes to sysfs (`tweaks/battery-monitor.py`, docstring lines 1-15).

### W5 - Benchmark the device
| Tool | Run as | Changes the device? | Source |
|---|---|---|---|
| `tweaks/system-bench.py` | root, no game running | Temporarily changes the UFS I/O scheduler and Wi-Fi power save; storage reads are O_DIRECT and read-only | docstring, lines 1-8 |
| `tweaks/profile-bench.py` | any session on the Thor | Switches Armada power profiles with `armada-power profile NAME`; restores the original profile in a `finally` block | `profile-bench.py` `main()` |

### W6 - Wake the Thor over Wi-Fi
Send a magic packet from the workstation: `scripts/wake-thor.ps1` or `scripts/wake-thor.py`. Both read `THOR_MAC` and `THOR_BROADCAST` from the environment or `local/thor.env` (see [04](04-configuration.md)).

### W7 - Choose per-game profiles
Edit the table in `tweaks/game-profiles/build_game_tweaks.py`, run it to regenerate `game-tweaks.json`, then copy the JSON to `/etc/armada/game-tweaks.json` by hand (`tweaks/game-profiles/README.md`, "Deploy"). The builder and the JSON are not deployed by any script in `tweaks/apply-all-tweaks.sh`.

### W8 - Refresh the reference clones and GitHub metadata
- `scripts/clone-refs.ps1 [-UseLock]` rebuilds `refs/` and writes `refs/MANIFEST.md` and `scripts/refs.lock.json` (see script header).
- `scripts/fetch-gh-meta.ps1` exports Armada releases, issues, PRs and tags to `refs/_gh/` using `gh`.

### W9 - Write or change a doc
Follow `docs/reference/CONVENTIONS.md`: claim tags on every factual line, a Sources section, and absolute dates. Verify against the source before citing (its "Rules" paragraph).

### W10 - Ship a change
From `CLAUDE.md` ("Git and GitHub"): branch for every change, open a PR, merge with `gh pr merge --merge` once verified. History rewrites need the owner's explicit OK and a `git bundle` backup first.
