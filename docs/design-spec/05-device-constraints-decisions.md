# 05 - Device and OS constraints, design decisions

## Device and OS constraints

| Constraint | Effect in this repo | Source |
|---|---|---|
| Armada is an image-based OS; `/usr` read-only (hub note; **UNVERIFIED** in this read) | Binaries go to `/var/local/bin`, units to `/etc/systemd/system` | `tweaks/apply-all-tweaks.sh`; `tweaks/system/setup-device-fixes.sh` |
| `/etc` drift is tracked (`ostree admin config-diff`) | Redeploys change `/etc`; the 2026-10-07 survey listed the drift | `docs/hardware/device-observed.md`, "Re-survey 2026-10-07" |
| Backlights are root-only on stock Armada | Anything writing the bottom backlight needs root; display sync runs as root | `docs/armada/dual-screen-dimming.md` (line 9) |
| Armada steers Steam's backlight writes to the top panel | Bottom panel does not dim with Steam. The doc says display sync addressed sleep rather than dim, and is superseded | `docs/armada/dual-screen-dimming.md` (lines 5 and 20) |
| Stick LEDs shared with `armada-rgb` | Unit has `Conflicts=armada-rgb.service`; `--all` skips the daemon | `tweaks/lighting/armada-stick-led.service`; `tweaks/README.md` section 3 |
| Gamepad device name differs by family | Code accepts two names; the Thor name is marked unverified | `tweaks/lighting/stick-led-color.py` lines 121-130 |
| Thor firmware ignores `charge_control_end_threshold` (read back 0) | No charge tweak here; the 80 % cap is Gleipnir | `tweaks/README.md` section 2 |
| Thor sleeps and may not answer SSH | Orchestrator checks reachability and fails fast | `CLAUDE.md`, "Device access" |
| Device IP changes | Host is in `local/thor.env`, not in scripts | `CLAUDE.md`, "Device access" |
| Linux-bound files need LF | `.gitattributes` pins them | `.gitattributes` |

## Design decisions

| # | Decision | Reason given in repo | Alternatives mentioned | Source |
|---|---|---|---|---|
| D1 | Dry run is the default for `cleanup-device.sh` | Script header: "Nothing changes without --apply" | Apply by default (rejected, not stated) | `tweaks/cleanup-device.sh` |
| D2 | `--all` skips the stick-RGB daemon | Armada already ships `armada-rgb`; two writers fight | Install both (rejected) | `apply-all-tweaks.sh` NOTE; `tweaks/README.md` |
| D3 | Charge cap moved out to Gleipnir, watch-only until tested | Firmware behaviour not shown; a root daemon and UI need their own test | Keep in this repo (`--battery` now exits 1) | `tweaks/README.md` section 2; `tweaks/apply-all-tweaks.sh` |
| D4 | Stick LED code kept unmodified, credited in header and `CREDITS.md` | Fork copied as is; only a credit line added | Rewrite for the Thor (not done) | `tweaks/lighting/stick-led-color.py` header; `tweaks/README.md` provenance |
| D5 | Ambilight keeps one ffmpeg process | Process start-up cost dominates | Spawn per sample | `AmbilightSampler` docstring |
| D6 | LED config write is atomic (tmp file then rename) | Written by a root daemon and CLI | Direct write (not stated) | `save_state`, `stick-led-color.py` |
| D7 | Restart policies: display sync `always`, LEDs and WoWLAN `on-failure` | Repo does not state the reason | - | `.service` files |
| D8 | WoWLAN treats missing support as a non-retry condition (exit 78) | Avoid restart loops on unsupported hardware | Retry forever (not used) | `tweaks/system/thor-wowlan` header |
| D9 | Benchmarks restore state in `finally` or by docstring | Avoid leaving a profile or scheduler changed | - | `profile-bench.py` `main()`; `system-bench.py` docstring |
| D10 | Real host, MAC and broadcast kept out of tracked files | Privacy; placeholders in tracked files | Hard-code (rejected) | `CLAUDE.md`; `scripts/thor.env.example` |
| D11 | Per-game caps are a judgement table in a generator, not a measured set | No A/B measurement yet | Measure first (not done) | `tweaks/game-profiles/README.md` |
| D12 | `setup-device-fixes.sh` only checks the KWin layout; it never edits it | Safety: Desktop Mode layout is user state | Auto-fix (not done) | `tweaks/system/setup-device-fixes.sh` step 2 comment |

## Rejected or superseded approaches

| Approach | Status | Source |
|---|---|---|
| Polling daemon copying the top panel's DRM active state to the bottom (`thor-display-sync`) | Superseded for dim; still deployed by `--system` (see L1 in [application spec 05](../application-spec/05-requirements-testing-limitations.md)) | `docs/armada/dual-screen-dimming.md` line 20 |
| 80 % cap through `charge_control_end_threshold` in this repo | Not effective on stock kernel; `thor-charge-limit` removed by `cleanup-device.sh` | `tweaks/cleanup-device.sh` step 1 |

## Known design gaps
- Display sync regex: DOTALL search can take an `active=` value from another block (see [02](02-algorithms-protocols.md#display-sleep-sync)).
- Display sync hard-codes UID 1000 and `/var/home/armada`.
- Stick LED `size` parameter is stored as a float (see application spec 03).
- No verification of deployed file contents; `--status` checks services only.
