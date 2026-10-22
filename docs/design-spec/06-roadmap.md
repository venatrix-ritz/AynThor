# 06 - Roadmap

Only items written in repo files are listed. No roadmap file exists in the repo; each item cites where it is written.

| # | Item | Where it is written | Status in the file |
|---|---|---|---|
| R1 | Decide whether `--system` and `--all` should still deploy `thor-display-sync`, since the dimming doc calls it superseded | `docs/armada/dual-screen-dimming.md` line 20 vs `tweaks/apply-all-tweaks.sh` `deploy_system()` | Conflict, not resolved |
| R2 | Confirm whether the Thor's gamepad reports `AYN Odin2 Gamepad` | Comment, `tweaks/lighting/stick-led-color.py` lines 126-129 | "unverified" in code |
| R3 | Measure the per-game frame caps and `cores: big` choice with an A/B run | `tweaks/game-profiles/README.md` ("No A/B has been run") | Open |
| R4 | Test the display sync effect on the device | `tweaks/README.md` provenance note ("its effect was not tested") | Open |
| R5 | Verify the speaker EQ headphone behaviour claimed in the README, or remove the claim | `tweaks/README.md` section 1 | Not in code |
| R6 | Resolve the Gleipnir charge-limit test on the running kernel (watch-only until it passes) | `tweaks/README.md` section 2 | Moved to the Gleipnir repo |
| R7 | Resolve the Barry Launcher licence question | `CREDITS.md`, licence note | Open issue invited in the file |
| R8 | Check whether the stick LED mode and `size` values are used as integers | `PARAM_SPECS` in `tweaks/lighting/stick-led-color.py` | Not checked in this spec |
| R9 | Remove the hard-coded UID and home path from the display sync daemon | `tweaks/system/thor-display-sync.py` lines 14-16, 26-27 | Not in any file's TODO; listed here as a design gap |
| R10 | Open research gaps (historical; last updated 2026-10-03) | `docs/reference/open-questions.md` | Most items marked resolved |
