# FerrOS Contributor Guide

These instructions apply to humans and coding agents working in this repository. Read this file before making changes. README.md describes the project and its intended directory organization; ROADMAP.md describes the staged development plan.

## Project context

FerrOS is a bare-metal operating system written in Rust, initially targeting the Raspberry Pi 4 (BCM2711, AArch64). It does not run on top of Linux or another host operating system.

This is an incremental, educational project. Changes should improve the system while making the underlying mechanisms understandable. Do not optimize for producing the largest amount of code in the fewest steps.

## Before making changes

1. Read the relevant parts of README.md and ROADMAP.md.
2. Inspect the current implementation and the related GitHub issue before assuming how something works.
3. Check existing module boundaries and conventions before adding files or abstractions.
4. For nontrivial work, state the intended change, important assumptions, and how it will be verified.
5. Keep changes scoped to the requested issue. Do not opportunistically rewrite unrelated code.

Treat the repository as the source of truth. A roadmap item is not proof that something is implemented, and earlier discussions are not a substitute for inspecting the current code.

## Organization and module boundaries

The directory structure should communicate the architecture of the system. Place code according to its responsibility:

- **Boot code:** earliest startup and handoff logic. Keep assembly and boot-specific artifacts separate from ordinary kernel services.
- **Architecture (arch/):** CPU-specific mechanisms, such as AArch64 registers, exception levels, exception vectors, MMU operations, barriers, and context switching.
- **Board support (board/):** Raspberry Pi 4-specific configuration and initialization, including its memory map, peripheral wiring/addresses, and platform details.
- **Drivers (drivers/):** hardware-specific device operations. Keep drivers distinct from generic services that consume those devices.
- **Kernel (kernel/):** general kernel mechanisms such as scheduling, processes, synchronization, IPC, and system-call dispatch.
- **Memory management (mm/):** physical allocation, virtual memory, page tables, heaps, and related memory policy.
- **Filesystems (fs/):** filesystem abstractions and filesystem implementations. A block-device driver belongs with drivers; filesystem interpretation belongs here.
- **Networking (net/):** protocol implementations and generic networking services. Ethernet-controller mechanics belong in drivers.
- **Console/display:** presentation and text/graphics services. A framebuffer or display-controller driver remains a driver.
- **Tests:** keep unit tests close to the code they exercise. Use the top-level tests/ directory for integration tests that exercise public interfaces or multiple components.
- **Documentation:** use docs/architecture/ for system design, docs/hardware/ for board/peripheral notes, and docs/decisions/ for Architecture Decision Records.

These are responsibility boundaries, not a requirement to create every directory immediately. Add modules and directories when there is a concrete implementation or document to place there. Avoid empty scaffolding, speculative frameworks, and excessive fragmentation. A small module may begin in one file and be split when it develops distinct responsibilities.

Use Rust module conventions consistently. Keep module declarations aligned with the surrounding code; do not mix styles arbitrarily.

## Design principles

- Prefer small modules with one coherent responsibility.
- Keep architecture-independent logic independent of Raspberry Pi-specific details where practical.
- Keep board-specific addresses, register layouts, and initialization requirements out of generic kernel code.
- Separate mechanism from policy. For example, a UART driver transmits bytes; a console decides what text to display.
- Define interfaces at genuine subsystem boundaries, not merely to make code look abstract.
- Avoid premature generalization for hypothetical boards or devices.
- Explain important invariants and non-obvious hardware behavior in comments or nearby documentation.
- Record consequential architectural choices as concise ADRs in docs/decisions/, including context, alternatives, decision, and consequences.

## Rust and bare-metal constraints

- Kernel code is no_std and no_main. Do not introduce standard-library dependencies into kernel code.
- Be deliberate about dependencies. Check that a crate supports the target and the project's no_std requirements before adding it.
- Keep unsafe blocks small and local. Every unsafe block should have a safety comment explaining the invariant that makes the operation valid.
- Use volatile access for memory-mapped device registers where required. Ordinary Rust references are not a substitute for hardware MMIO semantics.
- Respect AArch64 alignment, calling conventions, exception-level rules, memory ordering, and cache-coherency requirements.
- Do not assume firmware or QEMU initialized a peripheral unless that assumption is documented and verified.
- Do not hard-code board-specific details in generic subsystems when they belong in board support or a driver.
- Avoid allocation in early boot and exception paths unless allocator availability and safety are established.
- Treat pointers and structures supplied by firmware, including the device tree, as untrusted input. Validate ranges, lengths, alignment, and bounds before accessing them.

## Testing and verification

Use the narrowest useful verification, and report exactly what was and was not run.

- **Host-side unit tests:** use for portable logic such as parsers, checksums, algorithms, and data structures when those modules can be built for the host.
- **QEMU:** use for kernel boot and emulated hardware behavior. Record the machine type and relevant command-line options.
- **Physical Raspberry Pi 4:** use to validate behavior that depends on actual firmware, clocks, pin muxing, peripheral wiring, or hardware not faithfully represented by QEMU.
- **Integration tests:** put cross-module tests in tests/ when they can be run meaningfully in the available environment.

Because this is a bare-metal no_std project, ordinary cargo test may not run the kernel test harness for the target. Do not claim it passed unless it was actually run successfully. Where appropriate, factor pure logic into host-testable modules or create explicit test harnesses.

Never report a build, QEMU boot, or hardware test as successful unless it was actually executed and observed. Distinguish clearly between code reviewed but not built, build completed, QEMU behavior observed, and physical hardware behavior observed.

## Changes and repository hygiene

- Keep commits and pull requests focused and describe the reason for the change.
- Update README.md, ROADMAP.md, or docs when behavior, supported hardware, build instructions, or architecture materially changes.
- Do not mark roadmap checkboxes complete based solely on code being written; use stated exit criteria and observed verification.
- Do not add generated build artifacts, binaries, logs, or local IDE state to version control.
- Do not silently change target architecture, board assumptions, boot protocol, or project scope.
- If a task reveals a necessary architectural change beyond its scope, explain it and propose a separate decision or issue rather than burying it in an unrelated patch.

## Working style for coding agents

FerrOS is also a learning project for its maintainer. When implementing or proposing a nontrivial change:

1. Explain the mechanism and the reason for the design, not just the code to paste.
2. Identify assumptions and hardware-specific behavior.
3. Break work into reviewable steps.
4. Prefer a minimal, understandable implementation over clever abstractions.
5. Call out tradeoffs and alternatives when they materially affect future architecture.
6. Ask before making broad refactors or changing project conventions.
7. Never imply code has been committed, tested, or run unless the corresponding action actually succeeded.

The goal is not merely to make FerrOS work. The goal is to build an operating system whose structure and behavior its maintainers can understand.
