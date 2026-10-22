# AynThor Application Spec

What the AynThor repo is, who uses it, which tools it ships, how they are configured and what they require.
Written from a read of the repo on 2026-10-22 (branch `main`, commit `3631b5f`). Paths are repo-relative. Every factual line is anchored to a file (and line or function) or marked **UNVERIFIED**.
The companion [design spec](../design-spec/README.md) explains how the parts work.

| # | File | Topic |
|---|---|---|
| 01 | [purpose-scope.md](01-purpose-scope.md) | Purpose, what is in the repo, what is elsewhere, what is out of scope |
| 02 | [users-workflows.md](02-users-workflows.md) | The single operator and the day-to-day workflows |
| 03 | [tools-reference.md](03-tools-reference.md) | Every script and daemon: commands, flags, defaults, outputs |
| 04 | [configuration.md](04-configuration.md) | Environment variables, local env file, device config files, deploy paths |
| 05 | [requirements-testing-limitations.md](05-requirements-testing-limitations.md) | Requirements, verification practice, known limitations and conflicts |
| 06 | [glossary.md](06-glossary.md) | Terms |

**Plain summary.** AynThor is a sourced research knowledge base about the AYN Thor handheld running Armada OS (`docs/`), plus a small set of scripts, systemd units and config files that are deployed to that device over SSH (`tweaks/`, `scripts/`). Nothing in the repo runs automatically on the device; an operator deploys each piece by hand or with `tweaks/apply-all-tweaks.sh`.
