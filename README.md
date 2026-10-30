
# FerrOS

A bare-metal operating system written in Rust.

The goal is to build an operating system from the ground up, targeting
the Raspberry Pi 4 and AArch64 architecture, without relying on Linux
or another underlying operating system.

## Development Environment

- Rust (`aarch64-unknown-none`)
- QEMU (`raspi4b` machine)
- GDB (`gdb-multiarch`)
- Visual Studio Code
- WSL2 / Ubuntu

## Building

```bash
cargo build
```

## Running

```bash
qemu-system-aarch64 \
    -machine raspi4b \
    -display none \
    -serial stdio \
    -monitor none \
    -kernel target/aarch64-unknown-none/debug/ferros
```

## Project Status

- [x] Initial bare-metal Rust kernel
- [x] UART output on QEMU virt
- [x] Initial Raspberry Pi 4 emulation
- [ ] Explicit hardware initialization
- [ ] Exception handling
- [ ] Interrupt handling
- [ ] Memory management
- [ ] Multicore support
- [ ] Filesystem
- [ ] Graphics
