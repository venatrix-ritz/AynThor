# AynThor — research repo (AYN Thor + Armada OS)

Research-only knowledge base (no code). Start at [README.md](README.md); rules for writing docs are in [docs/reference/CONVENTIONS.md](docs/reference/CONVENTIONS.md) (claim tags, Sources section, no unsourced causal claims, today's date absolute).

- **Upstream clones** live in `refs/` (gitignored): `scripts/clone-refs.ps1` rebuilds them; SHAs in `refs/MANIFEST.md` + `scripts/refs.lock.json`. Cite as `refs/<dir>@<sha7>:path#Lnn`. Never edit `refs/`.
- **GitHub exports** in `refs/_gh/` (`scripts/fetch-gh-meta.ps1`) are the primary source for Armada release history/issues/PRs; WebFetch output is secondary.
- **Subagents cannot see `G:\`** via Read/Grep/Write — use Bash `G:/...` paths. Heredocs in Bash tool calls with mixed quotes failed once; use the Write tool per file.
- The Thor (Max 1 TB, Armada 20260926) is reachable read-only: `ssh armada@<thor-ip>` (PC key authorized 2026-10-03; IP may change — Armada Tools → Remote Access shows it). Read-only unless Ven says otherwise; no sudo, no LAN scanning. Findings: docs/hardware/device-observed.md.
- Git: repo initialised on `main`, nothing committed; commit/branch only when Ven asks.
- Coverage gaps and unanswered questions: `docs/reference/open-questions.md`.
- Comparisons (`docs/comparison/`), glossary (`docs/reference/glossary.md`), and on-device hardware/mod verifications (audio-fix, LSFG-VK, barry-launcher full installation and user space dependency resolution) are completed. Remaining open items are tracked in `docs/reference/open-questions.md`.
