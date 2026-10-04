# AYN Thor — specifications
> Scope: hardware spec sheet reconciled across sources · Researched: 2026-10-03 · Confidence: medium (press + vendor page; no teardown or on-device check yet)

## Summary
Dual-screen clamshell Android handheld. Base/Pro/Max use Snapdragon 8 Gen 2 (SM8550; upstream Linux calls it QCS8550); **Thor Lite** uses Snapdragon 865 (SM8250). Controllers sit between two AMOLED screens. Stock OS: Android 13.

| Item | Base / Pro / Max | Lite | Source |
|---|---|---|---|
| SoC | Snapdragon 8 Gen 2 | Snapdragon 865 | [src: https://liliputing.com/ayn-thor-is-dual-screen-android-handheld-game-console-with-oled-displays-and-qualcomm-snapdragon-inside/] |
| RAM | 8 / 12 / 16 GB, LPDDR5x-4200 | 8 GB LPDDR4(x)-2133 | same; Droix agrees (LPDDR5x / LPDDR4x) [src: https://droix.net/blogs/en-gb/ayn-thor-handheld-review/] |
| Storage | 128 GB / 256 GB / 512 GB or 1 TB (Max) | 128 GB UFS 3.1 | see [variants-pricing](variants-pricing.md) |
| Storage type | **UFS 4.0 on early batches, UFS 3.1 from Batch 6** — AYN switched Base/Pro/Max to UFS 3.1 because of component costs (a new Max 16 GB/512 GB SKU appeared). Not a conflict: the spec changed between batches. Ven's early-batch Max 1 TB reports UFS 4.0 on the device. | UFS 3.1 | [src: Notebookcheck / multiplayer.it / criticalhits headlines via WebSearch 2026-10-03, not opened] [src: https://www.ayntec.com/products/ayn-thor (Batch 7 page lists UFS 3.1)] [observed: [device-observed](device-observed.md)] |
| Top display | 6" AMOLED, 1080×1920, 120 Hz | same | [src: https://liliputing.com/…] [src: https://droix.net/…] |
| Bottom display | 3.92" AMOLED, 1080×1240, 60 Hz, touch | same | [src: https://droix.net/…]; resolution also in the devicetree touch size (1080×1240) [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts#L376-L399] |
| Battery | 6000 mAh | 6000 mAh | [src: https://liliputing.com/…] |
| Wireless | Wi-Fi 7, Bluetooth 5.3 | Wi-Fi 6, Bluetooth 5.1 | [src: https://liliputing.com/…] |
| Ports | USB 3.1 Type-C, 3.5 mm jack, microSD | same | [src: https://liliputing.com/…] |
| Size / weight | 150 × 94 × 25.6 mm, 380 g | same | [src: https://liliputing.com/…] |
| Sticks | Hall-effect | same | [src: https://www.ayntec.com/products/ayn-thor (WebFetch summary)] |
| Cooling | active fan; Droix measured ~45 °C max in a stress test, fan ≈ 63 dB max / 58 dB Sport / 47 dB Smart | — | [src: https://droix.net/…] |
| OS | Android 13 | Android 13 | [src: https://liliputing.com/…] |
| Colours | Black, White, Rainbow, Clear Purple | — | [src: https://www.ayntec.com/products/ayn-thor (WebFetch summary)] |

## Hardware confirmed from the Armada/ROCKNIX devicetree
- Panels: top ICNA3520-class DSI panel; bottom `ch13726a,thor` DSI panel; touch ICs FT5426 (top) / FT5452 (bottom). [src: refs/upstream/armada@574da80:packages/kernel/dts/qcs8550-ayn-thor.dts#L167-L183, #L258-L281, #L376-L437]
- Hall-effect lid sensor (clamshell), "AYN key" button, two HTR3212 RGB LED drivers (stick lighting), dual speaker amps, WCD938x audio codec. See [devicetree-thor](../boot-kernel/devicetree-thor.md).
- Armada's device conf records a **650-nit** HDR target for the Thor panel. [src: refs/upstream/armada@574da80:system_files/usr/lib/armada/devices/ayn-thor.conf]

## Performance notes (secondary)
Droix: "noticeable drop in performance when both screens are switched on", benchmarks slightly below the Odin 2 Portal; DS/3DS excellent (Drastic, Azahar dual-screen), PS2 "very well". [src: https://droix.net/blogs/en-gb/ayn-thor-handheld-review/ (WebFetch summary)]

## Not found / open
Charging wattage and protocol, haptics motor type, gyro IMU part, speaker/mic details, exact Wi-Fi/BT chip, panel brightness nits (Armada says 650 for HDR): see [open-questions](../reference/open-questions.md). Official AYN page has **no spec table** (as fetched).

## Sources
- [S1] https://liliputing.com/ayn-thor-is-dual-screen-android-handheld-game-console-with-oled-displays-and-qualcomm-snapdragon-inside/ (launch-era spec article; WebFetch summary)
- [S2] https://droix.net/blogs/en-gb/ayn-thor-handheld-review/ (review; WebFetch summary)
- [S3] https://www.ayntec.com/products/ayn-thor (vendor Batch-7 pre-order page; WebFetch summary)
- [S4] refs/upstream/armada@574da80 devicetree + device conf
