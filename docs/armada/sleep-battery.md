# Sleep and Battery Management (Armada OS)
> Scope: Deep sleep states and battery manager interaction · Researched: 2026-10-03 · Confidence: high

The AYN Thor, like most Qualcomm Android handhelds running Linux, relies heavily on specific kernel patches to achieve proper battery life during suspend.

## Sleep Mode (s2idle)
Armada supports s2idle (suspend-to-idle) for deep power cuts during sleep. 
When the user presses the power button, Gamescope triggers a system suspend. The s2idle implementation requires all hardware components (Wi-Fi, Bluetooth, Touchscreens, and the Awinic audio amplifier) to enter their lowest power states.
- Recent Armada kernel updates explicitly improved the s2idle sleep power cut for SM8550 handhelds, bringing Linux suspend battery drain closer to Android's.

## Battery Management (qcom_battmgr)
The kernel uses the Qualcomm Battery Manager (attmgr) to interface with the PMIC (Power Management IC).
- **Charge Limits**: While stock Armada does not include it by default, custom patches (like those from MgeeeeK) allow interacting with the qcom_battmgr to set physical charge limits (e.g., 80%) to prolong battery health.
- **Charging Fan Control**: Because the device can get hot while fast-charging, rmada-powerd and rmada-control implement a "Charging PWM" feature to force a minimum fan speed when the attmgr reports the device is plugged in and charging, preventing the SoC from overheating while asleep.
