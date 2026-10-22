# AynThor Design Spec

How the tweaks and tooling work: module layout, algorithms and their parameters, protocols and timing, data flow, interfaces, error handling, device constraints, design decisions and roadmap.
Companion to the [application spec](../application-spec/README.md). Facts come from reading the files named in each section on 2026-10-22; `file:line` anchors may drift as code changes. **UNVERIFIED** marks anything not traced in the code.

| # | File | Topic |
|---|---|---|
| 01 | [architecture-modules.md](01-architecture-modules.md) | Repo layout, deploy topology, what runs where |
| 02 | [algorithms-protocols.md](02-algorithms-protocols.md) | LED modes, display sleep sync, WoWLAN packets, speaker EQ, game caps, sampling |
| 03 | [data-flow.md](03-data-flow.md) | Mermaid flow and sequence diagrams |
| 04 | [interfaces-error-handling.md](04-interfaces-error-handling.md) | sysfs/debugfs/socket interfaces, exit codes, failure handling |
| 05 | [device-constraints-decisions.md](05-device-constraints-decisions.md) | Device and OS constraints, design decisions, rejected alternatives |
| 06 | [roadmap.md](06-roadmap.md) | Open items, all from repo files |
