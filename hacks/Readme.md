# Containerised build hack scripts

Scripts are meant to be called from the repository root.

* `hacks/build-guest-kernel.sh` - build the guest (L2) kernel in an ephemeral Alpine container.
  - will put `vmlinux` and `vmlinux.kconfig` in the repo root after build.
* `hacks/build-static-rust.sh` - statically compile Rust binaries from this repo.
  - e.g. `hacks/build-static.sh containerd-shim-cloudhv crates/agent/cloudhv-agent` will build both L1 containerd shim and L2 cloud hypervisor agent.
  - will put the build result (static binary) into the repo root.
* `hacks/build-guest.sh` - Build a full guest, kernel and rootfs including agent and crun.
  - will  put `root.erofs`, `vmlinux`, and `vmlinux.kconfig` into the repository root.
* `hacks/build-host-deps.sh` - Build host (L1) dependencies. All deps are statically linked. Currently only `mkfs.erofs` is built.
  - will put static `mkfs.erofs` into the repo root.
* `hacks/build-sysext.sh` - Will build a system extension image with guest (L2) and host bits, including host configuration.
  - will put `containerd-cloudhypervisor.raw` into the repo root.

## Using the sysext image

The easiest way to test the sysext image is to leverage the [`boot` feature](https://github.com/flatcar/sysext-bakery?tab=readme-ov-file#interactively-test-extension-images-in-a-local-vm)
of Flatcar's [sysext bakery](https://github.com/flatcar/sysext-bakery).

1. Check out the bakery repo into a separate directory:
   ```
   git clone --depth 1 https://github.com/flatcar/sysext-bakery.git
   ```
2. Copy `containerd-cloudhypervisor.raw` into the bakery repo root
3. Run
   ```
   ./bakery.sh boot containerd-cloudhypervisor.raw
   ```

This will download the latest Flatcar Alpha release for qemu, then start a Flatcar VM in ephemeral mode (no changes will be persisted in the image).
`bakery.sh boot` will also launch a local Python webserver and generate transient Ignition configuration to provision `containerd-cloudhypervisor.raw` at boot time.

After the VM boot finished, run the demo included with the extension image to verify:
```
sudo /usr/share/cloudhv/demo/demo.sh
```

## Building for different architectures

If qemu-user-static is installed on the build host and `binfmt-misc` is set up appropriately, builds for different architectures can be performed.
Note that the build containers run on their _native_ architecture and are _software emulated_ on the host.
This means that these builds will take many times longer than host-native builds.

Pass `--arch <arch>` to the build scripts for a software-emulated build.
* `--arch x86-64` will build for amd64
* `--arch arm64` will build for ARM64
