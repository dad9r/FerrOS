# FerrOS

A bare-metal operating system written in Rust.

The goal is to build an operating system from the ground up, initially targeting the Raspberry Pi 4 and AArch64 architecture, without relying on Linux or another underlying operating system.

The long-term ambition is to support existing ARM64 Linux applications. The immediate ambition is to own the machine.

## Project principles

- **Understandable:** the codebase should make the system's architecture discoverable.
- **Incremental:** build capabilities in small, testable steps.
- **Clear boundaries:** distinguish CPU architecture, board support, hardware drivers, and generic operating-system services.
- **Testable:** use host-side tests for portable logic, QEMU for emulated system behavior, and physical hardware for final validation.
- **Explicit:** document hardware assumptions, unsafe boundaries, and architectural decisions.

## Repository organization

The repository is organized around the responsibilities of an operating system, not around arbitrary collections of files.

| Location | Responsibility |
| --- | --- |
| `boot/` | Assembly and other code involved in the earliest boot stages. |
| `src/arch/` | CPU-architecture-specific code, such as AArch64 registers, exceptions, and context switching. |
| `src/board/` | Board-specific support, such as Raspberry Pi 4 memory maps and platform initialization. |
| `src/drivers/` | Hardware-device drivers. Drivers expose device capabilities; they do not implement higher-level policy. |
| `src/kernel/` | Core kernel services, including scheduling, processes, synchronization, and system calls. |
| `src/mm/` | Physical and virtual memory management, page tables, and heap allocation. |
| `src/fs/` | Filesystem abstractions and filesystem implementations. |
| `src/net/` | Network protocols and networking abstractions. |
| `src/console/` | Text console and display-facing console services. |
| `tests/` | Integration and system-level tests, including host-runnable tests where appropriate. |
| `docs/architecture/` | Architecture descriptions and subsystem documentation. |
| `docs/hardware/` | Board, peripheral, and hardware bring-up notes. |
| `docs/decisions/` | Short Architecture Decision Records (ADRs) explaining consequential design choices. |
| `scripts/` | Repeatable development, build, and test helper scripts. |

This table describes the intended organization as the project grows; it is not a request to create empty directories or placeholder modules in advance. Introduce a directory when there is real code or documentation to put there. Keep the initial boot path and kernel entry point simple until their responsibilities justify being split.

See [AGENTS.md](AGENTS.md) for detailed guidance for contributors and coding agents.

## Development environment

- Rust (target: `aarch64-unknown-none`)
- QEMU (Raspberry Pi 4 `raspi4b` machine)
- GDB (`gdb-multiarch`)
- Visual Studio Code
- WSL2 / Ubuntu

## Building

```bash
cargo build
```

## Running in QEMU

```bash
qemu-system-aarch64 \
    -machine raspi4b \
    -display none \
    -serial stdio \
    -monitor none \
    -kernel target/aarch64-unknown-none/debug/ferros
```

## Project status

See [ROADMAP.md](ROADMAP.md) for the staged development plan and [GitHub issues](https://github.com/dad9r/FerrOS/issues) for current work.

Current high-level milestones:

- [x] Initial bare-metal Rust kernel
- [x] Initial Raspberry Pi 4 QEMU boot path
- [ ] Reliable, explicitly initialized hardware diagnostics
- [ ] Exception and interrupt handling
- [ ] Memory management
- [ ] Multicore support
- [ ] Filesystem and persistent storage
- [ ] Console, graphics, and input
- [ ] Networking and broader device support
- [ ] Physical-hardware 1.0 release
