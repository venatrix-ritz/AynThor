# 01 - Purpose and scope

## Purpose
| Item | Statement | Source |
|---|---|---|
| Product | Source-grounded knowledge base on the AYN Thor and Armada OS, plus the small amount of code built from it | `README.md` (first paragraph), `CLAUDE.md` ("What lives here") |
| Target device | AYN Thor (dual-screen Snapdragon 8 Gen 2 handheld) | `README.md`, `docs/hardware/specs.md` |
| Target OS | Armada OS (SteamOS-like ARM64 Linux) | `README.md`, `tweaks/README.md` |
| Owner / operator | Ven (single operator; see [02](02-users-workflows.md)) | `CLAUDE.md` ("Device access") |

## What is in the repo

| Area | Path | Contents | Runs where |
|---|---|---|---|
| Knowledge base | `docs/` | Armada, hardware, Android, boot/kernel, comparison and reference docs, each with claim tags | Read only |
| Device tweaks | `tweaks/` | PipeWire EQ config, systemd units and daemons, LED daemon, per-game profile builder and JSON, battery logger, benchmarks, cleanup script, deploy orchestrator | Units and scripts run on the Thor; the orchestrator and builder run on the workstation |
| Helper scripts | `scripts/` | Wake-on-LAN senders (PowerShell and Python), upstream clone script with lock file, GitHub metadata exporter, env template | Workstation |
| Licences | `LICENSE`, `LICENSES/GPL-2.0.txt`, `CREDITS.md` | MIT for original material (docs, scripts, original tweaks, `CREDITS.md`, `README.md`). `stick-led-color.py` stays GPL-2.0-or-later as an Armada-derived file (`CREDITS.md`) | `LICENSE` header, `CREDITS.md` ("Licence" paragraph) |
| Ignored local data | `local/` (gitignored), `refs/` (gitignored), `plugins/ratatoskr`, `plugins/gleipnir` (junctions, gitignored) | Real device values, upstream clones, the two Decky plugin repos | Workstation only |

Source for the directory list: `.gitignore`, `.gitattributes`, `CLAUDE.md` ("What lives here").

## What is not in the repo

| Item | Where it lives | Source |
|---|---|---|
| Ratatoskr (bottom-screen trackpad/keyboard driver, formerly Touch Master) | Its own repo, linked as `plugins/ratatoskr` | `CLAUDE.md` ("The two Decky plugins"), `.gitignore` |
| Gleipnir (80 % battery ceiling plugin, formerly `tweaks/battery`) | Its own repo, linked as `plugins/gleipnir` | `CLAUDE.md`, `tweaks/README.md` section 2 |
| Upstream Armada, ROCKNIX, Thor Android and community sources | Clones under `refs/` built by `scripts/clone-refs.ps1` | `scripts/clone-refs.ps1`, `CLAUDE.md` |
| Real device host, MAC and broadcast address | `local/thor.env` | `scripts/thor.env.example`, `CLAUDE.md` ("Device access") |
| Personal memory / hub notes | Outside the repo | Not used as a source in this spec |

## Out of scope (stated in the repo)
- Writing status or handoff documents unless asked (`CLAUDE.md`, conventions in `docs/reference/CONVENTIONS.md`).
- Editing anything under `refs/` (`docs/reference/CONVENTIONS.md`, "Do not").
- Unprompted LAN scanning (`CLAUDE.md`, "Device access": "No LAN scanning").
- Charge limiting in this repo: the 80 % cap moved to Gleipnir on 2026-10-07 (`tweaks/README.md` section 2; `tweaks/apply-all-tweaks.sh`, `--battery` branch exits 1).
