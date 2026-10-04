# Armada OS - Build and CI Architecture
> Scope: OS image build process and GitHub Actions workflow · Researched: 2026-10-03 · Confidence: high

Armada is built entirely on GitHub Actions, leveraging edora-bootc (Fedora 44) as its immutable base. The final OS image is an OCI container that devices pull natively via ostree/bootc.

## CI Workflow (.github/workflows)
The build is orchestrated through a pipeline of workflows:
1. **Packages (packages.yml)**: Compiles custom RPMs and dependencies (Kernel, Mesa, Gamescope, InputPlumber, Decky plugins). These are cached in GitHub Packages (ghcr.io/.../armada/pkg/...) indexed by a hash of their source files.
2. **Container Image (uild.yml)**:
   - Pulls the pre-built packages as OCI layers.
   - Runs Containerfile via uildah using edora-bootc as a base.
   - Executes uild_files/build.sh sequentially (installing packages, system_files overlays, initramfs generation).
   - Optimizes the output using chunkah (to merge/split OCI layers smartly within 128 layers for ostree).
   - Pushes to ghcr.io/armada-os/armada.
3. **Disk Image (uild-disk.yml)**: Uses osbuild or similar to stamp the OCI container onto a flashable disk image for new installations.

## Build Steps
The rootfs construction (uild_files/build.sh) follows strict ordering:
- 10-base-packages.sh: DNF installs from upstream.
- 20-install-kernel.sh: Drops in the SM8550 patched kernel.
- 30-install-steam-session.sh: Injects the gamescope-session stack.
- 40-vendor-system-files.sh: Overlays files from the repo's system_files tree.
- 45-install-decky-plugins.sh: Places Decky plugins (like rmada-control).
- 50-create-user.sh / 55-generate-initramfs.sh: Dracut generation.

This OCI container approach means "updating the OS" on the Thor is just pulling the latest ghcr.io image via ootc upgrade.
