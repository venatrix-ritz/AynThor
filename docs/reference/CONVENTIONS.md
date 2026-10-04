# Conventions (read before writing any doc)

Today = **2026-10-03** (research began 2026-10-02; clones taken 2026-10-02 — see `refs/MANIFEST.md`). Armada release tags are dates (`YYYYMMDD`). Cloud/GitHub timestamps are UTC; local `git`/`stat` are PDT (UTC-7).

## Claim tags (every factual line carries one)
- `[src: <URL>]` — web source you opened this session.
- `[src: refs/<dir>@<sha7>:<path>#L<n>]` — file in a clone under `refs/` (see `refs/MANIFEST.md` for dir → repo → SHA).
- `[src: refs/_gh/<file>]` — GitHub release/issue/PR metadata pulled by `scripts/fetch-gh-meta.ps1` (primary source for release history).
- `[UNVERIFIED — best guess: …]` — plausible but not confirmed against a source. Never state a *cause* ("X happens because Y") without a source or this tag.
- `[CONFLICT: A says … (src), B says … (src)]` — sources disagree; do not pick silently.
- `[observed]` — output from a read-only command on Ven's physical Thor (state the date; commands in `docs/hardware/device-observed.md`). Main thread only.

Rules: re-open the source before citing it (no recall from memory/training). WebFetch output is a small-model summary = secondary; prefer clones, `gh` JSON, raw files. Paraphrase web prose; quote at most one short (<15 words) line per source; code/config from GPL repos may be quoted briefly with `path:line`. No lyrics, no long copied passages.

## Doc template
```
# <Title>
> Scope: … · Researched: 2026-10-03 · Confidence: high | medium | low
## Summary
## Details
## Sources
- [S1] URL or refs path — what it was used for
```

## Write to disk incrementally
Write each doc (and append to your fragments) the moment it is finished — never batch writes at the end. Agents can be cut off by rate limits; work not on disk is lost.

## Write only what the sources support
If a topic has no real source, **do not write a thin doc** — add a one-line entry to your open-questions fragment instead.

## Fragments (no shared-file collisions)
Each agent owns only the files listed in its prompt, plus three fragment files in `docs/reference/_fragments/`:
`<AGENT>-sources.md` (every URL/path used, with what it supports), `<AGENT>-claims.md` (one row per non-trivial claim: doc, claim, tag, confidence), `<AGENT>-open-questions.md` (unanswered/unsourced). Synthesis merges them into `docs/reference/{sources,claims-log,open-questions}.md`.

## Paths
Repo root `G:/Projects/Hardware/AynThor`. Subagents cannot see `G:\` via Read/Grep/Write — use **Bash with `G:/...` paths** (e.g. `cat > 'G:/...' <<'EOF'`, `rg`, `git -C`) for all reading and writing. `rg` is available. Windows + Git Bash.

## Do not
Edit anything under `refs/` (read-only clones), touch files you don't own, run LAN scans, access any device, or `git commit`.
