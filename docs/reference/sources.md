# Sources (merged)

> Researched 2026-10-02/03. Primary = clones under `refs/` (SHAs in `refs/MANIFEST.md`) and `refs/_gh/` gh exports. WebFetch/WebSearch results are secondary (small-model summaries).

## Armada docs + releases (agent B fragment)
Researched 2026-10-03. Citation formats used by agent B (extensions of CONVENTIONS.md):
- Docs-site source: `[src: refs/upstream/armadaos.dev@26dcfc3:<path>#L<n>]` (clone HEAD 26dcfc3844859ac10d5c300d91430f493faadc30, commit dated 2026-09-30 21:34 -0400).
- Armada repo file at HEAD: `[src: refs/upstream/armada@574da80:<path>#L<n>]` (clone HEAD 574da80f5f87942fa5d4f46de273edb7b85308f6, commit dated 2026-10-02 17:51 -0400).
- Armada repo file as of a release tag: `[src: refs/upstream/armada@574da80:<path>@<tag>#L<n>]` (read with `git show <tag>:<path>`).
- Armada git history: `[src: refs/upstream/armada@574da80:commit <sha7>]` (SHAs are abbreviated 7 chars from `git log`; release-to-commit mapping by ancestry via `git tag --contains`, not by date).
- GitHub metadata: `[src: refs/_gh/releases/<tag>.json]`, `[src: refs/_gh/issues.json#<n>]`, `[src: refs/_gh/prs.json#<n>]` (`#<n>` = issue/PR number), plus `releases-list.json`, `tags.json`, `branches.json`, `contributors.json`, `repo.json`. GitHub JSON pulled by `scripts/fetch-gh-meta.ps1` on 2026-10-02 (files stamped 19:09-19:10 PDT = 2026-10-03 ~02:10Z; repo.json `updated_at` 2026-10-03T02:00:58Z).

## Paths used
| path | used for |
|---|---|
| refs/MANIFEST.md | clone SHAs and dates |
| refs/upstream/armadaos.dev (all of docs/, includes/abbreviations.md, mkdocs.yml, data/videos.json, hooks/generate_downloads.py, hooks/generate_videos.py, README.md) | docs-site pages (primary source for user-facing guidance) |
| refs/upstream/armadaos.dev git log | staleness of each docs page |
| refs/_gh/releases-list.json, releases/*.json (13 files) | release history |
| refs/_gh/tags.json | tag to commit SHA mapping (matches local `git rev-parse` for all 13 tags) |
| refs/_gh/issues.json (342 issues), prs.json (258 PRs) | issue/PR digest |
| refs/_gh/branches.json, contributors.json, repo.json | repo facts, credits |
| refs/upstream/armada (git log, git show <tag>:README.md, git tag --contains) | release context, Thor timeline |

## Community / forks (agent E fragment)
## Clones and local sources
- `refs/upstream/armada` remotes `silentbob347`, `ga1dz1`, `mgeeeek-thor` + `origin` (574da80): fork diffs, upstream context. Used by docs/armada/forks-and-related.md.

## GitHub API (gh api, pulled 2026-10-03)
- https://api.github.com/repos/MgeeeeK/thor-armada, /MgeeeeK/armada-packages (+ compare, contents of kernel patches, issues), /Ga1dz1/armada, /Ga1dz1/nebel, /SilentBob347/armada-os, /armada-os/armada, /virtudude/armada (redirect to armada-os/armada), /users/SilentBob347/repos: repo metadata, fork kernel patches.
- `gh search repos` queries: "ayn thor", "aynthor", "ayn-thor", "ayn thor dual screen", "thor wayfinder", "cocoon launcher", "armada os handheld", "nebel ga1dz1", "ayn thor linux", "ayn thor rocknix", "ayn thor launcher", "ayn odin 2 armada": star counts, descriptions, not-cloned repo tables.

## Main-thread sources (this pass)
- refs/upstream/armadaos.dev@26dcfc3 (docs source) — all pages under docs/armada/{overview,install-*,restore-android,updating-ota,armada-*,desktop-mode,known-issues,faq,devices-ayn,community-credits}.md
- refs/upstream/armada@574da80 — Thor device conf, dual-screen scripts/units, kernel dts + patch (docs/armada/dual-screen.md, docs/boot-kernel/devicetree-thor.md)
- refs/upstream/rocknix@9f8c79dc12 — Thor dts provenance/history
- refs/_gh/{releases,issues,prs}.json — thor-changelog.md, thor-issues-and-prs.md
- refs/thor-android/* READMEs + ayn-thor-root-guide@8eed02f — docs/android/{community-tools,bootloader-root}.md
- https://liliputing.com/ayn-thor-is-dual-screen-android-handheld-game-console-with-oled-displays-and-qualcomm-snapdragon-inside/ — specs, launch prices (WebFetch)
- https://droix.net/blogs/en-gb/ayn-thor-handheld-review/ — review facts (WebFetch)
- https://www.ayntec.com/products/ayn-thor — vendor page: variants/colours (WebFetch)
- https://androidauthority.com/ayn-odin-thor-handheld-price-hike-june-2026-3682290/ — HTTP 403 on fetch; price table via WebSearch snippet only
- Web search results (not opened): Notebookcheck, Android Authority, PCGuide, Steam Deck HQ, retrohandhelds.gg, joeysretrohandhelds.com (armada setup guide), newreleases.io, DeepWiki (virtudude/armada), ithome — URLs in conversation log; to open in a follow-up
- refs/upstream/armada@574da80:system_files/usr/lib/armada/devices/*.conf — device comparisons (docs/comparison/thor-vs-odin2-odin3-others.md)
- Live device survey & tests on armada@<thor-ip> (2026-10-03/04): read speeds, ABL verification, dmesg, user-space RPM extraction test for barry-launcher (docs/hardware/device-observed.md, docs/android/community-tools.md)
