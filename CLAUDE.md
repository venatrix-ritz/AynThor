# AynThor — research repo + Thor tooling

Source-grounded knowledge base on the AYN Thor (Armada OS), plus the small amount of code built from it. Start at [README.md](README.md). Rules for writing docs: [docs/reference/CONVENTIONS.md](docs/reference/CONVENTIONS.md) (claim tags, Sources section, no unsourced causal claims, today's date written absolutely).

## What lives here
- `docs/` — the sourced knowledge base. Gaps and open questions: [docs/reference/open-questions.md](docs/reference/open-questions.md).
- `tweaks/` — device tweak scripts, deployed over SSH (see Tweak scripts below).
- `refs/` — upstream clones, gitignored. `scripts/clone-refs.ps1` rebuilds them; SHAs in `refs/MANIFEST.md` and `scripts/refs.lock.json`. Cite as `refs/<dir>@<sha7>:path#Lnn`. Never edit `refs/`.
- `refs/_gh/` — GitHub exports (`scripts/fetch-gh-meta.ps1`): the primary source for Armada release history, issues and PRs. WebFetch output is secondary.
- `plugins/ratatoskr`, `plugins/gleipnir` — junctions to the two Decky plugins below.

## The two Decky plugins
They are their own repos, git-ignored here and linked in by junction. Commit plugin changes in those repos, not this one.

| Plugin | What it is | Repo | Local path |
|---|---|---|---|
| **Ratatoskr** (formerly Touch Master) | bottom-screen trackpad/keyboard driver | [venatrix-ritz/Ratatoskr](https://github.com/venatrix-ritz/Ratatoskr) | `G:\Projects\Hardware\Ratatoskr` as `plugins/ratatoskr` |
| **Gleipnir** | the 80 % battery ceiling; watch-only until its on-device test passes | [venatrix-ritz/Gleipnir](https://github.com/venatrix-ritz/Gleipnir) | `G:\Projects\Hardware\Gleipnir` as `plugins/gleipnir` |

**Junction hazard:** never check out a branch that still tracks `plugins/thor-input` while a junction sits in `plugins/`. Git would overwrite the real repo through it. That happened once on 2026-10-07; nothing was lost because the work was committed.

## Working rules
- **Subagents cannot see `G:\`** through Read/Grep/Write. Use Bash with `G:/...` paths.
- **Bash tool:** heredocs with mixed quotes failed once, so use the Write tool per file. `python3` is not on the Bash PATH here; use `python`.
- **Line endings:** Linux-bound files (`tweaks/`, `*.sh`, `*.service`, `*.py`) are pinned to LF by `.gitattributes`. This machine has `core.autocrlf=true`; never let CRLF reach the Thor.

## Tweak scripts (`tweaks/`)
- Community-sourced and mostly untested on this hardware; see the provenance note in `tweaks/README.md`.
- Deploy with `tweaks/apply-all-tweaks.sh [--audio|--system|--wowlan|--lighting|--status] [HOST]`.
- `--all` omits the stick-RGB daemon, because Armada ships `armada-rgb`.
- The 80 % battery ceiling is not a tweak any more; it is the Gleipnir plugin.

## Device access
- **Connect:** SSH key auth only, `armada@<ip>`. The real host, Wi-Fi MAC and LAN broadcast live in the git-ignored `local/thor.env` (template `scripts/thor.env.example`) and never go in tracked files. The IP changes; Armada Tools → Remote Access shows it. The Thor sleeps and may not answer. No LAN scanning.
- **Privileges:** passwordless sudo (Ven, 2026-10-04: "so you can do the rest"; `/etc/sudoers.d/91-claude-full`). The Thor is Ven's hobby device: make any change the task needs, as root where necessary, and run the project's device scripts yourself (`tweaks/apply-all-tweaks.sh`, `tweaks/cleanup-device.sh`, `~/stage/apply-system-bits.sh`), hardware tests included.
- **Every change:** a timestamped backup first, a pre-flight on the Thor's own Python/bash in `/tmp`, and a report of what changed. Look at what is there before deleting or overwriting it. For hardware writes (charging, fans, LEDs), watch the run and keep the restore command ready.
- **History:** on 2026-10-04 Claude, at Ven's request, set up Barry's user-space deps and wrappers under `~/.local`, repointed the LSFG-VK DLL path and rewrote the KDE output layout so desktop mode opens on the top screen. Each change has a `.bak`, all inside `$HOME`; its `sudo` calls were reads. The charge limiter, stick-LED daemon, Wake-on-WLAN and display-sync units found in `/etc` before the 2026-10-07 reset came from the Antigravity sessions.
- **Surveys:** `docs/hardware/device-observed.md` has dated surveys (latest 2026-10-07).

## Git and GitHub
- Remote `origin` = `venatrix-ritz/AynThor` (public; credits in `CREDITS.md`).
- Never delete branches; push all of them.
- Branch for every change and merge with `--no-ff`. The commit author is `Ven <…@users.noreply.github.com>` (repo-local git config), and commit messages end with the Co-Authored-By line.
- Open a PR and merge it yourself with `gh pr merge --merge` once the change is verified.
- History rewrites need Ven's explicit OK and a `git bundle` backup first.

## Docs state (2026-10-07)
- The 19 docs that had no citations were re-sourced from the clones (327 `refs/` citations, 0 broken). `partition-layout.md` was re-verified on the device.
- Two docs still carry audit banners: `dual-screen-on-android.md` (Android internals) and `components.md` (only some rows re-read on the device).
- barry-launcher is not installed on the Thor.
