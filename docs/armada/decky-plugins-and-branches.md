# Decky Plugins and Branches Guide (Armada OS)
> Scope: Pre-installed Decky plugins and GitHub branch strategy · Researched: 2026-10-03 · Confidence: high

## Pre-installed Decky Plugins
Armada OS includes several custom Decky plugins baked directly into the OS image to manage hardware specific to ARM64 handhelds.
These are located in the decky/ directory of the rmada repo and compiled during the .github/workflows/packages.yml step.
1. **rmada-control**: The primary hardware configuration plugin. Handles dual-screen toggles, fan curves, RGB, controller calibration, power profiles, and s2idle toggles.
2. **rmada-store**: A custom plugin store (or store bridge) likely used to distribute or update Armada-specific plugins without relying on the generic Decky plugin store, ensuring compatibility with the ARM64 base.

## Branches Guide
The Armada GitHub repository (rmada-os/armada) uses a specific branching strategy to manage releases:
- main: The bleeding-edge development branch. Commits here trigger the 	esting/preview channel container builds on ghcr.io.
- staging: The beta branch. Used to stabilize features before a major release. Triggers staging channel builds.
- Other tags (stable, latest): Reserved for official release channels. 

Users switch branches on their device by rebasing their bootc image to the corresponding tag (e.g., ootc switch ghcr.io/armada-os/armada:testing).
