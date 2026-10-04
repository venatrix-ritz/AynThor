# Thorch and Related Linux Distributions
> Scope: Other Thor-compatible Linux OSes · Researched: 2026-10-04 · Confidence: high

Alongside Armada OS, the AYN Thor has other community Linux distributions available, often exploring different architectural paths.

## Thorch (Thor + Arch Linux)
Thorch is an experimental, unofficial OS project for the AYN Thor that runs **Arch Linux ARM** instead of Armada's Fedora base.
- **Boot and Root**: It builds raw SD card images (.img) with an xt4 or Btrfs root filesystem.
- **First-Boot**: Unlike Armada's container approach, Thorch runs a fullscreen QML onboarding flow on first login to configure Wi-Fi, passwords, Steam/Waydroid setup, and safe internal installation.
- **Desktop Environment**: Focuses on KDE Plasma defaults and Plasma Mobile.
- **Shared DNA**: Thorch shares the same hardware enablement DNA as Armada—it also relies on the ROCKNIX custom ABL and patches, utilizing the same fake Android KERNEL oot.img trick to boot Linux on the SM8550.
- **Installation**: Like Armada, installing Thorch to internal storage uses a destructive userdata shrink (	horch-install-internal --create-from-userdata) but can alternatively be run entirely from a MicroSD card.

## ROCKNIX
As mapped in ocknix-relationship.md, ROCKNIX is the grandparent project to both Armada and Thorch. It provides the initial ABL unlocked bootloader, the initial device trees for the AYN Thor and Thor Lite, and the baseline kernel patches for the SM8550 and SM8250 platforms.
