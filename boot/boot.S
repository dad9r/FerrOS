.section .text.boot, "ax"
.global _start
.type _start, %function

_start:
	// Identify the executing core.
	mrs x0, mpidr_el1
	and x0, x0, #0xff

	// Only core 0  initializes ferros for now
	cbz x0, .lprimary

.lpark:
	wfe
	b .lpark

.lprimary:
	// Mask IRG, FIQ, SError and debug exceptions for now.
	msr daifset, #0xf

	// Clear .bss in 8-byte chunks.
	ldr x0, =__bss_start
	ldr x1, =__bss_end

1:
	cmp x0, x1
	b.hs 2f
	str xzr, [x0], #8
	b 1b

2:
	// establish a 16-byte-aligned stack.
	ldr x0, =__stack_top
	mov sp, x0

	// Enter Rust. This function should never return.
	bl kernel_main

3:
	wfe
	b 3b

.size _start, . - _start

.section .bss.stack, "aw", %nobits
.align 4
.skip 16384
