# Boot Chain (Armada on Thor)
> Scope: From power-on to user space on an internal Armada installation · Researched: 2026-10-03 · Confidence: high

Armada leverages the ROCKNIX custom Application Boot Loader (ABL) to boot a standard mainline Linux kernel packaged in an Android oot.img envelope.

## 1. Qualcomm Primary Boot
When the Thor is powered on, it executes the immutable Primary Bootloader (PBL) from ROM. This verifies and loads the secondary boot stages (XBL) from sdb/sdc, which initializes the hardware and RAM, eventually loading the Android Bootloader (ABL) from the bl_a or bl_b partition.

## 2. Custom ABL (ROCKNIX)
The stock Thor ABL is replaced during Armada installation with a custom, unlocked ABL built by the ROCKNIX team. This ABL implements a text-based boot menu (accessed by holding VOL-) that allows users to switch between Linux and Android boot modes, and set their device model.

If the boot mode is "Linux", the ABL mounts the ARMADA EFI System Partition (sda18, /boot/efi) and looks for a file explicitly named KERNEL.

## 3. The KERNEL Boot Image
Despite the EFI partition, Armada does not use systemd-boot or GRUB. Instead, KERNEL is a standard Android oot.img (identifiable by its ANDROID! magic header).
Because ostree/bootc updates the kernel and initramfs in /boot/ostree, Armada uses a systemd service and script (rmada-bootimg-update) to regenerate this KERNEL image whenever an update is applied:
1. It reads the default Boot Loader Specification (BLS) entry created by ostree.
2. It compresses the Linux kernel binary (gzip -c).
3. It appends **all** supported device tree blobs (.dtb) directly to the end of the kernel.gz.
4. It packages the kernel.gz+dtbs and the initramfs together using mkbootimg.py.

The ABL loads this KERNEL image, parses the appended DTBs, selects the correct DTB based on the device model set in the ABL menu, and executes the Linux kernel.

## 4. Ostree / Bootc
The kernel boots with the ostree command line arguments (e.g., ostree=/ostree/boot.0/armada/...), mounts the BTRFS ARMADA_ROOT (sda20), and transitions to the ostree deployment, bringing up the immutable Fedora base and launching Gamescope.
