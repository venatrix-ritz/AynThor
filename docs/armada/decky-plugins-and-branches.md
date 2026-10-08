# Decky Plugins and Branches (Armada OS)
> Scope: the Decky plugins Armada ships and how its branches map to update channels · Researched: 2026-10-03, re-sourced 2026-10-07 · Confidence: high where tagged. Earlier guesses about the store ("likely a bridge") and a "stable/latest" branch were removed.

## Plugins baked into the image
- `decky/` in the Armada repo contains exactly two plugins: **armada-control** and **armada-store**. Both declare `flags: ["root"]`, author "Armada". [src: refs/upstream/armada@574da80:decky/armada-control/plugin.json#L1-L5; refs/upstream/armada@574da80:decky/armada-store/plugin.json#L1-L5]
- The image build copies each plugin's `plugin.json`, `package.json`, `main.py`, `py_modules`, optional `catalog.json` and `templates`, plus the built `dist/`, into `/usr/share/decky-plugins/<name>`; it also downloads the latest Decky Loader release from SteamDeckHomebrew at build time and installs an `armada-decky-sync` helper. [src: refs/upstream/armada@574da80:build_files/45-install-decky-plugins.sh#L4-L29]
- **armada-control** imports fan-curve, power and charging-PWM handling (`fan_curves.py`, `config.py`); details in `docs/armada/armada-control-internals.md`. [src: refs/upstream/armada@574da80:decky/armada-control/main.py#L30]
- **armada-store** is a catalogue-driven installer: `catalog.json` lists apps with a category and an install method (the first entries are Flatpaks such as RetroArch and Dolphin). [src: refs/upstream/armada@574da80:decky/armada-store/catalog.json#L1-L22]
- On the Thor running `20261006.9c7dd3e` the Decky plugins directory held `armada-control`, `armada-store` and `thor-input` (Touch Master, from this repo's `plugins/`). [observed 2026-10-07]

## Branches and channels
- Building the `main` branch publishes the container tag **`testing`** on channel **`preview`**; building `staging` publishes tag **`staging`** on channel **`staging`**. The tags `testing`, `preview`, `beta`, `stable` and `latest` are reserved: other branches build under their own branch name. [src: refs/upstream/armada@574da80:.github/workflows/build.yml#L64-L70]
- The *Promote* workflow copies a build (`testing` or `staging`) to **`beta`** or **`stable`**, refuses to promote an unsigned build, and also tags `stable` as `latest`. [src: refs/upstream/armada@574da80:.github/workflows/promote.yml#L10-L15, #L70-L71, #L91-L93]
- User-facing wording: **Beta** is recommended and receives builds after release testing; **Preview** follows the latest commits on `main`; a Beta user can switch to Preview from the OS Update Channel setting. [src: refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/updating.md#L5-L10; refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/preview-images.md#L15]
- The Thor surveyed 2026-10-07 runs `ghcr.io/armada-os/armada:testing`. [observed 2026-10-07]
- The repo also has many feature branches (e.g. `armada-tools`, `dual-dsi-fix`, `fast-wifi-reconnect`). [src: refs/_gh/branches.json]

## Sources
- [S1] refs/upstream/armada@574da80 (decky/, build_files/, .github/workflows/)
- [S2] refs/upstream/armadaos.dev@26dcfc3:docs/getting-started/
- [S3] refs/_gh/branches.json; on-device `bootc status`, 2026-10-07
