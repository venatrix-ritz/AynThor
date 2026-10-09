# Per-game Armada profiles (Ven's Thor)

`build_game_tweaks.py` writes `game-tweaks.json`, deployed to `/etc/armada/game-tweaks.json` on the Thor on 2026-10-09 (64 games; backup of the previous file, if any, in `~/stage-backups/`). Armada reads it through `armada_game_tweaks.load()` and applies it in `armada-game-launch` before each game starts. [src: refs/upstream/armada@574da80:system_files/usr/lib/armada/armada_game_tweaks.py#L6-L7]

| Tier | Games | Settings |
|---|---|---|
| Heavy | 13 (The Ascent, Abiotic Factor, both Octopaths, Galactic Racer, R.I.P., TerraTech Legion, Dungeons of Hinterberg, Subnautica, Outer Wilds, Schedule I, Be My Horde, Escape from Duckov) | `cores: big` (CPUs 3-7), FEX profile `default`, `DXVK_FRAME_RATE` and `VKD3D_FRAME_RATE` = 40 |
| Medium | 17 | `cores: big`, FEX `default`, frame rate 60 |
| Light | 34 | FEX `default` only |

## What is and is not backed by a source
- **The schema** (`games.<appid>` with `fexProfile`, `cores`, `nice`, `scheduler`, `wineTopology`, `thunks`, `env`; `global` for defaults) is read from Armada's code. [src: refs/upstream/armada@574da80:system_files/usr/lib/armada/armada_game_tweaks.py#L45-L60]
- **`cores: big`** resolves to CPUs 3-7 on the Thor (`little` 0-2, `prime` 7). [observed 2026-10-09: `/usr/libexec/armada/device-env`]
- **Big cores for 3D games** follows one user report on one device, with a 60 fps target. [src: refs/_gh/issues.json#449]
- **FEX `default`** makes Armada's launcher set TSO on, x87 reduced precision, Multiblock on and half-barrier TSO on for every game. [src: refs/upstream/armada@574da80:system_files/usr/share/armada/fex-profiles.json#L3-L11] The system file `/usr/share/fex-emu/Config.json` sets Multiblock to 0, but the launcher's per-game config replaces it. [src: refs/upstream/armada@574da80:build_files/30-install-steam-session.sh#L98] [src: refs/upstream/armada@574da80:system_files/usr/libexec/armada/armada-game-launch#L94-L101] FEX describes Multiblock as able to cause long JIT times and stutter. [src: refs/upstream/fex-emu@f11c8c7:FEXCore/Source/Interface/Config/Config.json.in#L4-L10]
- **The tiers and the 40 / 60 caps are judgement, not measurement.** No game has run with these profiles yet. 40 fps divides the 120 Hz top panel evenly. [observed 2026-10-09: `kscreen-doctor -o`] [UNVERIFIED — best guess: a lower cap leaves thermal headroom for the GPU; no A/B has been run.]
- **The frame-rate variables only affect Proton DX9-12 games** (DXVK and VKD3D); native Vulkan titles ignore them. [src: Armada's env preset descriptions, `/usr/share/armada/env-presets.json` on the Thor, observed 2026-10-09]

## Not here
Steam's own per-game settings (Gamescope frame limit, scaling filter and mode, TDP, VRS) live in Steam's config and are not part of this file; see `docs/hardware/device-observed.md`, section "Idle fix and Steam per-game settings, 2026-10-09".

Deploy: `scp game-tweaks.json armada@<host>:/tmp/` then `sudo install -m 0644 -o root -g root /tmp/game-tweaks.json /etc/armada/game-tweaks.json` (back up the existing file first).
