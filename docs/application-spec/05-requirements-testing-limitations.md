# 05 - Requirements, testing and limitations

## Requirements

### Device
| Requirement | Value | Source |
|---|---|---|
| Hardware | AYN Thor (Snapdragon 8 Gen 2, dual DSI panels) | `README.md`, `docs/hardware/specs.md` |
| OS | Armada OS (observed builds `20260926`, `20261006.9c7dd3e`, `20261004.c32590d`) | `docs/hardware/device-observed.md`, `tweaks/README.md` |
| Access | SSH key auth as `armada`; passwordless sudo for `--system`, `--lighting`, `--wowlan`, `cleanup-device.sh` | `apply-all-tweaks.sh`, `CLAUDE.md` |
| Userland | `python3`, `systemd`, `iw` (for WoWLAN), `pipewire`, `runuser`, `gamescopectl` (display sync), `armada-power` (profile bench), `journalctl` | Scripts named in [03](03-tools-reference.md) |
| Optional | `ffmpeg` with `kmsgrab` (ambilight mode) | `tweaks/lighting/stick-led-color.py` (`AmbilightSampler`) |
| Optional | `armada-rgb` disabled or absent (stick LED clashes with it) | `armada-stick-led.service` `Conflicts=` |
| Optional | `rpm-ostree-countme` present (masked by setup script) | `setup-device-fixes.sh` |

### Workstation
| Requirement | Used by | Source |
|---|---|---|
| Git for Windows (Bash, `ssh`, `scp`) | `apply-all-tweaks.sh`, `cleanup-device.sh` | Script shebangs and `CLAUDE.md` (Git Bash) |
| PowerShell 7 | `clone-refs.ps1`, `fetch-gh-meta.ps1`, `wake-thor.ps1` | Script headers |
| Python 3 | `wake-thor.py`, `build_game_tweaks.py` | Script headers. `CLAUDE.md` says `python` (not `python3`) on the Bash PATH |
| GitHub CLI `gh`, authenticated | `fetch-gh-meta.ps1`, PR flow | Script and `CLAUDE.md` |
| `rg` (ripgrep) | Searching `docs/` and `refs/` | `docs/reference/CONVENTIONS.md` |
| Network | Thor on the same LAN, broadcast reachable for wake | `scripts/wake-thor.py` docstring |

## Testing and verification

### Automated tests
**No test suite exists in this repo.** A search for filenames containing `test` returned nothing (`find` over the tree, 2026-10-22). The Decky plugins have their own tests in their own repos (`CLAUDE.md`, Gleipnir section, which the hub also records; **UNVERIFIED** from this repo).

### How changes are verified in practice
| Method | What it covers | Where recorded | Source |
|---|---|---|---|
| Dry-run mode | `cleanup-device.sh` prints actions without `--apply` | Script output | `cleanup-device.sh` |
| Read-back checks | `thor-wowlan` checks `wowlan show`; `--status` prints service state | Journal, `--status` output | `thor-wowlan`, `apply-all-tweaks.sh` |
| On-device surveys | Read-only checks recorded with dates | `docs/hardware/device-observed.md` (latest "Re-survey 2026-10-07") | Doc |
| Tests in the plugin repos | Gleipnir and Ratatoskr behaviour | Their own repos | Not in this repo |
| Bench tools | CPU, memory, storage, Wi-Fi and battery measurements | Output files named in [03](03-tools-reference.md) | Scripts |

### Before a tweak is considered working
The repo does not define a pass/fail procedure for the tweaks. The docs say which ones are untested:
- The charge limit was tested in the Gleipnir plugin, not in this repo (`tweaks/README.md` section 2).
- The display-sync effect "was not tested" (`tweaks/README.md`, provenance note).
- Community tweaks are "mostly untested on this hardware" (`CLAUDE.md`, "Tweak scripts").

## Known limitations and conflicts

| # | Item | Evidence | Status |
|---|---|---|---|
| L1 | `--system` and `--all` install and enable `thor-display-sync`, but `docs/armada/dual-screen-dimming.md` says it is superseded and "not part of the re-apply set" | `apply-all-tweaks.sh` `deploy_system()` (enable line); `docs/armada/dual-screen-dimming.md` line 20 | **Conflict between code and doc.** Not resolved in this spec |
| L2 | Stick LED daemon conflicts with Armada's `armada-rgb` on the same HTR3212 channels | `armada-stick-led.service` comment; `tweaks/README.md` section 3 | Handled: `--all` skips it; unit has `Conflicts=` |
| L3 | Stick LED code was written for the Retroid Pocket Mini V2 and copied unmodified | Header of `tweaks/lighting/stick-led-color.py` (lines 2-7); `tweaks/README.md` provenance note | Known. Thor gamepad name `AYN Odin2 Gamepad` is marked unverified in the code comment (lines 126-129) |
| L4 | Speaker EQ README says it "automatically disables when headphones are connected" | `tweaks/README.md` section 1 | **UNVERIFIED / not in the config.** `50-thor-speaker-eq.conf` has no such logic, and no other file in `tweaks/` was found to implement it |
| L5 | Speaker EQ values in the hub memory note differ from the repo | `tweaks/README.md` section 1 and `tweaks/audio/50-thor-speaker-eq.conf` agree: 80 Hz high-pass, -5 / -12 / -15 / -16 dB at 444 / 700 / 1860 / 3800 Hz, +3 dB at 11 kHz. The hub note gives different gains | Repo files used as the source. The hub note needs correcting outside this repo |
| L6 | Per-game frame caps and `cores: big` are a judgement, not measured | `tweaks/game-profiles/README.md` | Stated in README |
| L7 | The 80 % cap is not in this repo | `tweaks/apply-all-tweaks.sh` `--battery` exits 1 | Moved to Gleipnir |
| L8 | Device user, UID and paths are hard-coded in the display sync daemon | `tweaks/system/thor-display-sync.py` lines 14-16, 26-27 | Known design limit |
| L9 | `system-bench.py` restore behaviour not traced | Docstring only | **UNVERIFIED** |
| L10 | `cleanup-device.sh` comment says the old charge limiter "only checks charge_control_limit, which this kernel lacks" | `tweaks/cleanup-device.sh` step 1 comment | Quoted from the script, not re-verified against the kernel here |
| L11 | No deployed-version check: `apply-all-tweaks.sh --status` reports service state, not file hashes | `show_status()` | Known |
| L12 | No application binary: the workstation-side entry points are the deploy, cleanup, build and wake scripts; everything else runs on the device | Repo layout | By design |

Open research questions are tracked in `docs/reference/open-questions.md` (last updated 2026-10-03 per its header). Device findings are in `docs/hardware/device-observed.md`.
