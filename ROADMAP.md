# FerrOS Roadmap

> **The long-term ambition is Factorio. The immediate ambition is to own the machine.**

## Vision

FerrOS is a general-purpose, bare-metal operating system written in Rust, initially targeting the Raspberry Pi 4. It will boot directly on the hardware without Linux or another host operating system underneath.

The long-term goal is to support existing applications through a Linux-compatible user-space environment, with the ARM64 Linux version of Factorio as a demanding demonstration. The first priority, however, is to build a sound, understandable operating system one layer at a time.

## Guiding principles

- **Bare metal:** FerrOS owns the machine; it does not run as an application under another OS.
- **Understandable:** Prefer designs whose behavior can be explained and debugged.
- **Incremental:** Each phase should produce a testable capability.
- **Portable where practical:** Separate architecture-independent kernel concepts from Raspberry Pi-specific board support.
- **Testable:** Use QEMU for fast iteration, while validating hardware behavior on a real Pi early and often.
- **Safe by design:** Use Rust's guarantees where possible, and keep unavoidable unsafe hardware boundaries small and explicit.

---

# Part I — Building FerrOS

## 0.1 — Kernel foundations

Establish a reliable boot path and the minimum infrastructure needed to diagnose problems.

- [ ] Stabilize the kernel entry point and boot flow.
- [ ] Initialize the primary core and park secondary cores safely.
- [ ] Establish the exception vector table and basic exception handling.
- [ ] Improve panic handling and early diagnostic output.
- [ ] Explicitly initialize the PL011 UART and make serial output reliable.
- [ ] Document and verify the linker layout, stack, and BSS initialization.
- [ ] Read and parse the device tree for hardware discovery.
- [ ] Record board and boot information in early kernel diagnostics.

**Exit criteria:** FerrOS boots repeatably in QEMU and on the target boot environment, reports its basic hardware state over serial, and can diagnose basic exceptions and panics.

## 0.2 — Memory and CPU management

Build the foundations for safely using memory and processor resources.

- [ ] Discover and describe available physical memory.
- [ ] Implement a physical page-frame allocator.
- [ ] Enable and configure the AArch64 MMU.
- [ ] Establish kernel virtual memory mappings and page-table management.
- [ ] Add a kernel heap allocator.
- [ ] Define cache maintenance and memory-ordering primitives where required.
- [ ] Establish DMA-capable memory allocation and mapping rules.
- [ ] Initialize the ARM generic timer.
- [ ] Initialize the interrupt controller and route interrupts.
- [ ] Develop safe inter-core coordination and synchronization primitives.

**Exit criteria:** The kernel can allocate and free physical and virtual memory, handle timer interrupts, and coordinate processor cores using defined synchronization mechanisms.

## 0.3 — Hardware console and input

Create a usable local interface for operating and debugging FerrOS.

- [ ] Initialize a display path, initially using a practical firmware-provided framebuffer where appropriate.
- [ ] Implement framebuffer drawing primitives.
- [ ] Add text rendering, scrolling, and a basic console abstraction.
- [ ] Investigate and initialize the Raspberry Pi 4 USB host path (PCIe/VL805).
- [ ] Support a USB keyboard and translate input into kernel events.
- [ ] Add mouse support if useful to the console/UI direction.
- [ ] Implement a basic shell with built-in commands.
- [ ] Add diagnostic commands for memory, devices, interrupts, and system state.

**Exit criteria:** On a physical Pi 4, FerrOS can display a text console, accept keyboard input, and run basic shell and diagnostic commands.

## 0.4 — Storage and filesystems

Give FerrOS persistent storage and a usable file abstraction.

- [ ] Initialize the Raspberry Pi 4 SD/eMMC host controller.
- [ ] Define a block-device interface.
- [ ] Discover partitions and read block devices.
- [ ] Implement FAT32 read support.
- [ ] Add directory traversal and file metadata operations.
- [ ] Implement file creation, modification, and write support.
- [ ] Add persistent configuration and basic system data.
- [ ] Investigate USB mass-storage support.

**Exit criteria:** FerrOS can read and write files on the Pi's SD storage through a filesystem interface, with USB storage as an additional supported device where feasible.

## 0.5 — General-purpose kernel

Move from a single kernel execution path toward isolated, schedulable programs.

- [ ] Define kernel/user privilege boundaries.
- [ ] Implement user-space address spaces and memory protection.
- [ ] Define process and thread abstractions.
- [ ] Implement context switching and a scheduler.
- [ ] Add process creation, termination, and resource cleanup.
- [ ] Implement inter-process communication and synchronization primitives.
- [ ] Define a system-call ABI and dispatch mechanism.
- [ ] Load and execute static ELF user programs.

**Exit criteria:** FerrOS can run multiple isolated user-space programs and provide a documented, testable set of kernel services.

## 0.6 — Networking

Build a network stack and connect it to the Pi 4's wired network hardware.

- [ ] Initialize the BCM2711 GENET Ethernet controller.
- [ ] Define a network-device abstraction.
- [ ] Implement Ethernet framing and ARP.
- [ ] Implement IPv4 and ICMP.
- [ ] Implement UDP and TCP.
- [ ] Add DHCP and DNS support.
- [ ] Define socket APIs for user-space programs.
- [ ] Add basic network diagnostic tools and client/server test programs.

**Exit criteria:** FerrOS can configure its network interface, communicate with other hosts, and run basic network client and server programs.

## 0.7 — Audio and expanded peripherals

Broaden the hardware capabilities available to applications.

- [ ] Define an audio-device abstraction and buffering model.
- [ ] Implement basic audio output on the Pi 4.
- [ ] Investigate the Pi 4 wireless SDIO interface and required firmware.
- [ ] Implement Wi-Fi association and authentication if practical.
- [ ] Expand USB device-class support beyond keyboard and mass storage.
- [ ] Improve device discovery and driver registration.

**Exit criteria:** FerrOS has basic audio output and a path to broader peripheral support; Wi-Fi is supported if the hardware and firmware work justify its complexity.

## 0.8 — Graphics and system integration

Develop a more capable graphics path while consolidating the operating environment.

- [ ] Improve framebuffer graphics and drawing APIs.
- [ ] Define a graphics interface suitable for user-space applications.
- [ ] Investigate the Pi 4 V3D GPU, memory requirements, and command submission.
- [ ] Evaluate the feasibility and cost of hardware-accelerated graphics.
- [ ] Explore windowing and compositing if warranted by application needs.
- [ ] Integrate shell, console, graphics, input, and system services.
- [ ] Establish broader automated and hardware regression tests.

**Exit criteria:** FerrOS provides a coherent interactive environment and a documented graphics path, with hardware acceleration pursued only when it is a sound investment.

## 0.9 — Physical-hardware release candidate

Integrate and harden the capabilities required for a usable first release.

- [ ] Make boot and recovery behavior repeatable and documented.
- [ ] Integrate memory management, timers, interrupts, and scheduling.
- [ ] Stabilize process isolation and core kernel interfaces.
- [ ] Integrate display and keyboard input.
- [ ] Stabilize persistent filesystem operations.
- [ ] Integrate USB and wired Ethernet.
- [ ] Integrate basic audio if it is stable and useful.
- [ ] Provide a useful set of native user-space programs.
- [ ] Document supported hardware, known limitations, and build/boot procedures.
- [ ] Run repeatable QEMU and physical-hardware regression tests.

**Exit criteria:** The 1.0 feature set works together on physical hardware, and the remaining known limitations are explicit.

## 1.0 — Physical-hardware release

FerrOS is a usable operating system running directly on the Raspberry Pi 4, with no underlying operating system.

The intended baseline includes:

- Reliable boot and recovery.
- Memory management and multitasking.
- A display console and keyboard input.
- Persistent SD-card storage and filesystem support.
- USB support.
- Wired networking.
- Basic audio, provided it can be delivered without compromising stability.
- Native user-space applications.
- Stable, documented kernel and driver interfaces.

Wi-Fi and accelerated graphics may be deferred if necessary to deliver a reliable release. A text-oriented console is a valid 1.0 interface; a desktop environment is not a prerequisite.

**Exit criteria:** FerrOS boots on a Pi 4, supports interactive use, runs multiple programs, stores data persistently, and communicates over a network—all directly on the hardware.

---

# Part II — Application compatibility

## 2.0 — Linux application compatibility

Create an environment capable of running existing ARM64 Linux applications without recompilation.

- [ ] Mature the ELF loader and executable format support.
- [ ] Implement dynamic linking and shared-library loading.
- [ ] Establish the required runtime and libc compatibility.
- [ ] Support process arguments, environment variables, and standard streams.
- [ ] Implement Linux-relevant file descriptors and filesystem semantics.
- [ ] Add required metadata, permissions, and file operations.
- [ ] Implement signals and the required thread and synchronization behavior.
- [ ] Map Linux virtual-memory behavior onto FerrOS memory management.
- [ ] Implement the required Linux AArch64 system-call ABI.
- [ ] Connect Linux-compatible sockets to the FerrOS network stack.
- [ ] Investigate graphics and audio API compatibility.
- [ ] Build a repeatable compatibility test suite.

**Exit criteria:** A meaningful collection of ARM64 Linux applications runs on FerrOS without recompilation. Compatibility is measured against an explicit application set rather than a claim of complete Linux equivalence.

## 3.0 — Factorio

Use Factorio as a demanding end-to-end demonstration of FerrOS's application environment.

- [ ] Confirm a viable standalone ARM64 Linux Factorio build and its platform requirements.
- [ ] Identify the required system calls, shared libraries, and runtime behavior.
- [ ] Support the threading, synchronization, and memory behavior it requires.
- [ ] Support filesystem access and save-game persistence.
- [ ] Support TCP/IP networking and multiplayer requirements.
- [ ] Support required audio interfaces.
- [ ] Support the graphics API and rendering features required by the selected build.
- [ ] Profile performance and address major bottlenecks.
- [ ] Investigate Steam integration as a separate effort from running the game itself.

**Exit criteria:** Launch Factorio on FerrOS, load and play a factory, save and reload a game, and—if the networking and performance requirements are met—connect to a multiplayer session.

The initial target should be a standalone ARM64 Linux build if one is viable. Steam integration is a distinct compatibility and distribution challenge, not a prerequisite for proving that the game can run.

---

# Cross-cutting workstreams

These concerns span multiple roadmap phases and should be revisited as the system grows.

- **Architecture:** AArch64 startup, exceptions, MMU, timers, SMP, and architecture-specific primitives.
- **Board support:** Raspberry Pi 4 boot firmware, BCM2711 peripherals, device tree, and board-specific initialization.
- **Memory:** Physical allocation, virtual memory, heaps, DMA, cache coherency, and protection.
- **Drivers:** Consistent device interfaces, initialization, interrupts, and resource ownership.
- **Kernel services:** Scheduling, processes, synchronization, IPC, and system calls.
- **Filesystems:** Block devices, partitioning, filesystem semantics, and persistence.
- **User space:** Executables, runtime libraries, shell, native utilities, and application APIs.
- **Compatibility:** Linux ABI behavior, dynamic linking, and application-level testing.
- **Graphics and audio:** Display, GPU acceleration, input, sound, and application-facing APIs.
- **Tooling and quality:** QEMU, hardware debugging, automated tests, documentation, and reproducible builds.

# Development strategy

1. **Keep QEMU in the inner loop.** Use emulation for fast boot, kernel, and regression testing, while remembering that emulated devices and firmware behavior are not identical to physical hardware.
2. **Test on the Pi early.** Board-specific behavior—especially firmware handoff, device initialization, USB, storage, and graphics—must be validated on real hardware.
3. **Separate policy from mechanism.** Keep generic kernel interfaces distinct from Raspberry Pi-specific drivers and initialization.
4. **Build small test programs.** Validate memory, interrupts, storage, networking, and user-space behavior independently before integrating larger features.
5. **Record architectural decisions.** Use short design notes when a choice will constrain later work.
6. **Track work as measurable issues.** Each issue should describe a concrete capability, its dependencies, and an observable acceptance criterion.
7. **Revisit scope at each release boundary.** Prefer a stable, well-understood system over checking every feature box.

This roadmap is intentionally staged. Later phases will become more specific as earlier work reveals the real constraints of the hardware and the architecture.
