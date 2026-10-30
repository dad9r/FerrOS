# Kernel Boot Contract

## Status and scope

This document records the boot environment currently measured for FerrOS when launched in QEMU using the `raspi4b` machine model and QEMU's direct ELF `-kernel` loader.

It is deliberately specific to that configuration. It is **not** a statement of the Raspberry Pi 4 firmware-to-kernel handoff contract. The physical Pi boot chain and its handoff still need to be investigated and verified.

Three kinds of statements are distinguished:

- **Observed:** measured in the current QEMU/GDB setup or read from the built ELF.
- **Defined by FerrOS:** behavior implemented by the current linker script or startup code.
- **Not yet verified:** questions that remain open and must not be treated as boot guarantees.

## QEMU launch configuration

The regular QEMU invocation is:

```sh
qemu-system-aarch64 \
    -machine raspi4b \
    -display none \
    -serial stdio \
    -monitor none \
    -kernel target/aarch64-unknown-none/debug/ferros
```

The VS Code debugging task uses the same machine and kernel image, with the GDB stub enabled and the CPU initially paused (the `-S` and `-gdb tcp::1234` options).

This uses QEMU's Raspberry Pi 4 machine model and direct ELF loading. It does **not** run the physical Raspberry Pi boot sequence (SoC Boot ROM, EEPROM bootloader, and VideoCore firmware) before entering FerrOS.

The observed QEMU version during this investigation was `10.2.1 (Debian 1:10.2.1+ds-1ubuntu3.3)`.

## ELF image and linker layout

The built image was inspected with:

```sh
readelf -h target/aarch64-unknown-none/debug/ferros
readelf -l target/aarch64-unknown-none/debug/ferros
nm -n target/aarch64-unknown-none/debug/ferros
```

### ELF header

Observed:

- ELF type: `EXEC` (executable).
- Machine: AArch64.
- Entry point: `0x80000`.

The entry point agrees with the linker script's `ENTRY(_start)` and the linked address of `_start`.

### Program headers

The final ELF contains three `LOAD` segments and one `GNU_STACK` header:

| Segment | Virtual / physical address | File size | Memory size | Flags |
| --- | ---: | ---: | ---: | --- |
| `.text` | `0x80000` | `0x460` | `0x460` | R E |
| `.rodata` | `0x81000` | `0x2da` | `0x2da` | R |
| `.bss` | `0x812e0` | `0` | `0x4000` | R W |

All three `LOAD` segments report identical virtual and physical addresses. The ELF segment alignment reported by `readelf` is `0x10000`.

The BSS segment has no corresponding bytes in the ELF file (`FileSiz = 0`) but reserves `0x4000` bytes (16 KiB) in memory (`MemSiz = 0x4000`). This is the expected ELF representation for a memory-only BSS allocation. FerrOS startup also explicitly clears the BSS range before entering Rust; it does not rely solely on loader zero-fill behavior.

The `GNU_STACK` program header describes stack-related ELF metadata. It is **not** the actual 16 KiB runtime stack allocation; that allocation is in `.bss`.

### Linker symbols

Observed symbol addresses:

| Symbol | Address | Meaning |
| --- | ---: | --- |
| `_start` | `0x80000` | Assembly entry point |
| `__bss_start` | `0x812e0` | Beginning of BSS |
| `__stack_top` | `0x852e0` | Initial stack pointer value |
| `__bss_end` | `0x852e0` | End of BSS |

The BSS allocation is therefore:

```text
0x812e0  __bss_start   stack allocation begins
   |     16 KiB
   |
0x852e0  __stack_top == __bss_end
```

AArch64 stacks grow downward. FerrOS sets `sp = __stack_top`, so the reserved stack range is `[0x812e0, 0x852e0)`. At present, the stack is the only BSS allocation, which is why `__stack_top` and `__bss_end` coincide.

The BSS start and end are 16-byte aligned, and the current assembly clears the range in 8-byte stores. The stack top is 16-byte aligned as required by the AArch64 procedure-call standard.

## CPU state observed at `_start`

The primary core was stopped at the first instruction of `_start` using GDB. The register observations below were made before executing the corresponding startup instructions.

| Property | Observed value | Interpretation |
| --- | --- | --- |
| Entry PC | `0x80000` | Matches ELF entry point |
| `CurrentEL` | `0xC` | EL3; bits [3:2] encode exception level 3 |
| `SCTLR_EL3.M` (bit 0) | `0` | MMU disabled |
| `SCTLR_EL3.C` (bit 2) | `0` | Data cache disabled |
| `SCTLR_EL3.I` (bit 12) | `0` | Instruction cache disabled |
| `DAIF` | `0xF` | Debug, SError, IRQ, and FIQ masks set |
| `x0`–`x3` | all zero | No register argument observed in these registers |

The `DAIF` state was captured before the `msr daifset, #0xf` instruction in FerrOS startup. FerrOS subsequently sets all four masks again. The initial mask state is therefore an observation of the QEMU handoff, not an effect of that FerrOS instruction.

The general-purpose register values were captured at the entry breakpoint, before the first instruction (`mrs x0, mpidr_el1)) overwrites `x0`. In particular, this QEMU invocation did not provide a device-tree address in `x0`. The observation is limited to `x0`–`x3`: it does not prove that no device tree is available elsewhere or through another mechanism.

## Current FerrOS early-startup behavior

The current `boot/boot.S` performs the following operations:

1. Read `MPIDR_EL1` and mask the low affinity byte to identify the core.
2. Allow core 0 to continue; park a core with a nonzero masked value in a `wfe` loop.
3. Set all four `DAIF` exception masks.
4. Clear the linker-defined BSS range in 8-byte stores.
5. Set `sp` to `__stack_top`.
6. Call `kernel_main`.

The Rust entry point currently writes diagnostic text through the PL011 UART and then spins. UART initialization is not yet explicit, so the current output path still depends on the device's state in the emulated environment.

The current startup code's core-selection and secondary-core parking logic is present in the source, but a complete measurement of QEMU's secondary-core entry behavior has not yet been recorded.

## What this investigation establishes

For the measured QEMU direct-ELF configuration:

- The linked image is an AArch64 ELF executable with entry point `0x80000`.
- The entry point, linker entry declaration, and `_start` symbol agree.
- The final ELF includes RX text, read-only data, and a 16 KiB RW BSS segment.
- The BSS/stack linker symbols agree with the BSS program header.
- The primary core enters at EL3 with the MMU and instruction/data caches disabled.
- The exception masks are already set on entry.
- `x0`–`x3` are zero at the entry breakpoint.
- A clean build boots through the current startup path and reaches the Rust kernel, which produces serial output in QEMU.

These findings describe this QEMU setup only. They should not be generalized into assumptions about physical Raspberry Pi firmware.

## Outstanding investigation

The following items remain open:

1. **Physical Pi 4 handoff:** determine the actual firmware-to-kernel entry level, register convention, exception-mask state, MMU/cache state, and image-loading expectations.
2. **RAM and reserved-memory map:** establish usable RAM bounds and regions reserved by firmware or devices. The ELF segment addresses alone do not define the complete RAM map.
3. **Device tree:** determine whether and how QEMU supplies a device tree for this boot mode, and separately establish how the physical firmware provides it. Do not assume `x0` contains its address in the current QEMU configuration.
4. **Secondary cores:** observe how and when QEMU starts the other cores, what state they inherit, and verify the parking strategy.
5. **ELF loader behavior:** if FerrOS later relies on loader-provided zero-fill or other ELF loading details, verify those details directly. The current startup code explicitly clears BSS.
6. **UART initialization:** explicitly configure the PL011 rather than relying on emulator startup state.

## References and related project files

- [FerrOS README](../../README.md)
- [FerrOS roadmap](../../ROADMAP.md)
- [Issue #1: Document and verify the kernel boot contract](https://github.com/dad9r/FerrOS/issues/1)
- [QEMU Raspberry Pi boards documentation](https://www.qemu.org/docs/master/system/arm/raspi.html)
- [Linux AArch64 boot protocol](https://docs.kernel.org/arch/arm64/booting.html) — useful as a reference for one AArch64 handoff convention, but not evidence that QEMU's direct-ELF loader or Raspberry Pi firmware uses that convention for FerrOS.
