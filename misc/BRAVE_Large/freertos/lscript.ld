_STACK_SIZE = 0x1000;

ENTRY(_vector_table)

SECTIONS {
	. = 0x0;

	.text : { 
		KEEP (*(.vectors))
		. = ALIGN(0x220);
		KEEP (*(.text))
		*(.text.*)
	}

	.rodata : {
		*(.rodata)
		*(.rodata.*)
	}

	.data : {
		. = ALIGN(64);
		*(.data)
		*(.data.*)
	}

	.got2 : {
		*(.got2)
	}

	.ARM.attributes : {
		*(.ARM.attributes)
	}

	.sbss (NOLOAD) : {
		__sbss_start__ = .;
		*(.sbss)
		*(.sbss.*)
		__sbss_end__ = .;
	}

	.bss (NOLOAD) : {
		__bss_start__ = .;
		*(.bss)
		__bss_end__ = .;
	}

	.stack (NOLOAD) : {
		. = ALIGN(16);
		_stack_end = .;
		. += _STACK_SIZE;
		_stack = .;
		__stack = _stack;
		. = ALIGN(16);
		_irq_stack_end = .;
		. += _STACK_SIZE;
		__irq_stack = .;
	}
}
