# Armada OS: Build and CI
> Scope: how the OS image is built · Researched: 2026-10-03, re-sourced 2026-10-07 · Confidence: high, read from the Armada repo at `574da80`. Corrected: the step list (it has ten numbered scripts, not six), the disk-image tool (`bootc-image-builder`), and the "128 layers" detail, which is not in the files cited.

## Image
- The `Containerfile` starts from `quay.io/fedora/fedora-bootc:44` and takes each package as a pre-built image passed in by hash: "Package images, resolved by content hash", published as `ghcr.io/<owner>/armada/pkg/<name>:<tag>` and tagged by `packages/package-hash.sh` from that package's sources. [src: refs/upstream/armada@574da80:Containerfile#L1-L19]
- Packages (Steam bootstrap, FEX, Mesa, MangoHud, Gamescope and its session packages, KWin, kernel, InputPlumber, …) live under `packages/`, one directory each. [src: refs/upstream/armada@574da80:packages/]

## Workflows (`.github/workflows`)
- **`packages.yml`:** builds each package as a Containerfile stage, one job per package so they run in parallel ("folding them into the image build would serialise 20 builds onto one machine"). [src: refs/upstream/armada@574da80:.github/workflows/packages.yml#L1-L7]
- **`build.yml`:** builds the image; `main` → tag `testing`, `staging` → tag `staging`; a "Chunkah" step (the Containerfile pins `quay.io/coreos/chunkah`) prepares a chunked layout (`--target=chunkah`) before pushing to `ghcr.io/armada-os/armada` (`virtudude/armada` is kept as the legacy image name). [src: refs/upstream/armada@574da80:.github/workflows/build.yml#L11-L16, #L64-L70, #L133-L192; refs/upstream/armada@574da80:Containerfile#L1]
- **`build-disk.yml`:** builds flashable disk images with `quay.io/centos-bootc/bootc-image-builder`, for the channels beta, stable, testing and staging. [src: refs/upstream/armada@574da80:.github/workflows/build-disk.yml#L10, #L42]
- **`promote.yml`:** copies a signed `testing`/`staging` build to `beta` or `stable` (see `docs/armada/decky-plugins-and-branches.md`). Also present: `pr.yml`, `pr-disk-link.yml`, `publish-channel-disk.yml`, `label_issues.yml`. [src: refs/upstream/armada@574da80:.github/workflows/]

## Build steps (`build_files/build.sh`)
Run in this order, each timed: `10-base-packages.sh`, `20-install-kernel.sh`, `30-install-steam-session.sh`, `40-vendor-system-files.sh`, `45-install-decky-plugins.sh`, `50-create-user.sh`, `52-configure-os-release.sh`, `55-generate-initramfs.sh`, `60-set-default-target.sh`, `70-cleanup.sh`, `80-finalize-update-state.sh`. [src: refs/upstream/armada@574da80:build_files/build.sh#L14-L24]
- `30-install-steam-session.sh` fetches the FEX x86 RootFS and installs the Gamescope/Steam session; `40-vendor-system-files.sh` overlays `system_files/` and enables Armada's units; `45-install-decky-plugins.sh` places the two Decky plugins. [src: refs/upstream/armada@574da80:build_files/30-install-steam-session.sh#L77-L83; refs/upstream/armada@574da80:build_files/40-vendor-system-files.sh#L88-L121; refs/upstream/armada@574da80:build_files/45-install-decky-plugins.sh#L4-L18]

## Updates on a device
The device runs a bootc image (`ghcr.io/armada-os/armada:testing` on the surveyed Thor). [observed 2026-10-07: `bootc status`] Updates are manual: the image disables the automatic fetch timer ("Updates are manual (Steam UI / steamos-update)"; opt in with `systemctl unmask --now bootc-fetch-apply-updates.timer`). [src: refs/upstream/armada@574da80:build_files/40-vendor-system-files.sh#L123-L126]

## Sources
- [S1] refs/upstream/armada@574da80 (Containerfile, build_files/, .github/workflows/)
- [S2] On-device `bootc status`, 2026-10-07
