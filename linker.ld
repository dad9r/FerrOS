ENTRY(_start)

SECTIONS
{
	. = 0x80000;

	.text : ALIGN(4096)
	{
		KEEP(*(.text.boot))
		*(.text .text.*)
	}

	.rodata : ALIGN(4096)
	{
		*(.rodata .rodata.*)
	}

	.data : ALIGN(4096)
	{
		*(.data .data.*)
	}

	.bss (NOLOAD) : ALIGN(16)
	{
		__bss_start = .;

		*(.bss.stack)
		__stack_top = .;

		*(.bss .bss.*)
		*(COMMON)

		. = ALIGN(16);
		__bss_end = .;
	}

	/DISCARD/ :
	{
		*(.eh_frame*)
		*(.comment*)
	}
}
