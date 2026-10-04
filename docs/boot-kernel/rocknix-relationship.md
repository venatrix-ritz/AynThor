# The ROCKNIX Relationship
> Scope: How Armada relates to ROCKNIX · Researched: 2026-10-03 · Confidence: high

Armada OS is heavily influenced by, and shares components with, ROCKNIX (a popular Linux distribution for retro handhelds). While Armada focuses on a Fedora ootc immutable base similar to SteamOS/Bazzite, it borrows crucial low-level boot infrastructure from ROCKNIX.

## Application Boot Loader (ABL)
The most significant piece of shared infrastructure is the custom unlocked Application Boot Loader (ABL).
- Armada directs users to flash the ocknix_abl to enable dual-booting.
- This ABL replaces the stock Android bl_a/bl_b partitions.
- It provides the physical boot menu (accessed via VOL-) that allows selecting between Android and Linux, and choosing the specific hardware model to pass the correct Device Tree Blob (DTB) to the kernel.

## Device Trees (DTS/DTB)
Armada's kernel patches and device tree sources (like sm8550-ayn-thor.dts) often share lineage with ROCKNIX, as the ROCKNIX community has historically done the heavy lifting for reverse-engineering AYN and Retroid hardware for mainline Linux.

## Key Differences
- **OS Base**: ROCKNIX uses an older, more traditional Linux rootfs built specifically for emulation. Armada uses an OCI container image (edora-bootc) designed to mimic the Steam Deck experience (Gamescope + Steam UI).
- **Update Mechanism**: ROCKNIX uses traditional partition flashing or package managers. Armada relies entirely on ostree and ootc for atomic, image-based OTA updates.
