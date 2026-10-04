# Claims log (merged)

| Doc | Claim | Tag | Confidence |
|---|---|---|---|
| docs/armada/forks-and-related.md | `gh api repos/virtudude/armada --jq .full_name` returns `armada-os/armada` (redirect) | [src: https://api.github.com/repos/virtudude/armada] | high |
| docs/armada/forks-and-related.md | `users/virtudude` returns 404; what happened to the account is not known | [UNVERIFIED — best guess: org created, repo transferred] | low |
| docs/armada/forks-and-related.md | SilentBob347/armada-os has 0 commits authored by SilentBob347; all unique commits are by virtudude/dependabot; main is 0 ahead / 648 behind origin/main | [src: refs/upstream/armada@0116cad (git log origin/main..silentbob347/*)] | high |
| docs/armada/forks-and-related.md | Ga1dz1/armada targets Retroid Pocket SM8250 devices (Mini V2, RP5, Flip2) plus RP6 extras, 116 commits, 140 files, archived; continues as Ga1dz1/nebel | [src: refs/upstream/armada@39a6dea:README.md#L1-L11] | high |
| docs/armada/forks-and-related.md | Ga1dz1 `passthrough: true` on 02-ayn-controller.yaml is called "unverified" on Thor hardware by its own comment | [src: refs/upstream/armada@39a6dea:system_files/usr/share/inputplumber/devices/02-ayn-controller.yaml#L57-L69] | high (that the comment says so) |
| docs/armada/forks-and-related.md | MgeeeeK fork: 5 commits ahead, 456 behind, merge-base f7eef88; adds thor-charge-limit service (80% fixed), cosign key, kernel pin | [src: refs/upstream/armada@7e17352 (git log origin/main..mgeeeek-thor/thor)] | high |
| docs/armada/forks-and-related.md | MgeeeeK commits carry `Claude-Session:` trailers (4 of 5 + kernel commit) = AI-assisted | [src: refs/upstream/armada@7e17352 (git log)] | high |
| docs/armada/forks-and-related.md | Thor charge-limit mechanism: writes 80 to charge_control_end_threshold (firmware property 16), clamps charge_control_limit to 1000 on charger >=80%, releases <=77% | [src: refs/upstream/armada@7e17352:system_files/usr/libexec/armada/thor-charge-limit#L1-L29] | high (code), UNVERIFIED on hardware |
| docs/armada/forks-and-related.md | AYN SM8550 firmware accepts SET property 16, GET of properties 25/26 always return 0 | [src: https://api.github.com/repos/MgeeeeK/armada-packages/contents/kernel/patches/0921-power-supply-qcom-battmgr-ayn-limit-capacity.patch?ref=thor] fork author's claim | low (single-source, AI-assisted author) |
| docs/armada/forks-and-related.md | SDR104 via downstream sdhci-msm: ~13 -> ~85 MB/s | [src: https://api.github.com/repos/MgeeeeK/armada-packages/compare/armada-os:main...MgeeeeK:thor] fork author's dtsi comment | [UNVERIFIED — not reproduced] |
| docs/armada/forks-and-related.md | Upstream 574da80 exposes BATT_CHG_CTRL_LIM as constant_charge_current (bypass charging), commit 431bf57, 2026-09-24 | [src: refs/upstream/armada@574da80:packages/kernel/patches/0903-power-supply-qcom-battmgr-expose-the-charge-current-limit.patch#L1-L8] | high |
| docs/armada/forks-and-related.md | Upstream removed `sdhci-caps-mask` from AYN common DTSI (patch) but keeps `max-sd-hs-hz = 37500000` | [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-common.dtsi.patch#L1-L2] | high; effect on SDR104 UNVERIFIED |
| docs/armada/forks-and-related.md | Upstream main supports AYN Thor Lite (SM8250): devices/ayn-thor-lite.conf, sm8250-ayn-thorlite in supported-dtbs, abl/README | [src: refs/upstream/armada@574da80:system_files/usr/lib/armada/devices/ayn-thor-lite.conf#L1-L14] | high |
| docs/armada/dual-screen.md | Thor top panel=DSI-2 (mdss_dsi1), bottom=DSI-1 (mdss_dsi0); gamescope drives top only, desktop uses both | [src: refs/upstream/armada@574da80:system_files/usr/lib/armada/devices/ayn-thor.conf] | high |
| docs/armada/dual-screen.md | Bottom screen in Game Mode runs a second gamescope over a DRM lease socket | [src: …/libexec/armada/bottom-gamescope#L18-L31] | high (flags read); lease semantics UNVERIFIED |
| docs/boot-kernel/devicetree-thor.md | Armada base Thor dts/dtsi are byte-identical to ROCKNIX copies | [src: diff -q refs/upstream/armada vs refs/upstream/rocknix, 2026-10-03] | high |
| docs/boot-kernel/devicetree-thor.md | Top panel icna3520 (FT5426 touch), bottom ch13726a,thor (FT5452 touch) | [src: packages/kernel/dts/qcs8550-ayn-thor.dts] | high |
| docs/hardware/specs.md | UFS 4.0 early batches, UFS 3.1 from Batch 6; Ven unit = UFS 4.0 | [observed + WebSearch headlines] | medium-high |
| docs/hardware/variants-pricing.md | July 2026 prices Lite $259 / Base $329 / Pro $409 / Max512 $479 / Max1TB $579 | [src: Android Authority via WebSearch snippet] | medium-low (secondary) |
| docs/armada/thor-changelog.md | Thor firmware in tree at 20260605; ayn-thor.conf at 20260611; README "Supported and tested" at 20260612 | [src: git ls-tree/show @ tags, verified 2026-10-03] | high |
| docs/android/community-tools.md | Missing barry-launcher RPMs (libxdo, xdotool, qt6-qtdeclarative-devel) extracted cleanly to ~/.local/opt/barry-deps in user space | [observed on device 2026-10-04] | high |
| docs/hardware/device-observed.md | Flashed ABL v1.1.8 confirmed via sha256 of abl_a/abl_b matching approved SM8550 manifest | [observed on device 2026-10-03] | high |
| docs/hardware/device-observed.md | Stock kernel negotiates SDR104 @ 202 MHz on Samsung SDXC; sequential read throughput = 89.5 MB/s | [observed on device 2026-10-03] | high |
| docs/comparison/thor-vs-odin2-odin3-others.md | Thor maps primary=DSI-2 / secondary=DSI-1; AYANEO Pocket DS inverts this (primary=DSI-1 / secondary=DSI-2) | [src: refs/upstream/armada@574da80:system_files/usr/lib/armada/devices/*.conf] | high |
| docs/comparison/android-vs-armada.md | Android uses DisplayManager for dual screen; Armada uses primary gamescope + DRM-leased secondary gamescope | [src: docs/armada/dual-screen.md; docs/android/community-tools.md] | high |
| docs/reference/glossary.md | Technical terminology compiled across all research documents | [src: repo documentation cross-index] | high |
