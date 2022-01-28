/*
 * This is a part of the TASTE distribution (see https://taste.tools)
 *
 * Copyright (C) 2022 ESA
 * 
 * This is free software; you can redistribute it and/or modify under   
 * terms of the  GNU General Public License as published  by the Free Soft-
 * ware  Foundation;  either version 3,  or (at your option) any later ver-
 * sion. This is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * As a special exception under Section 7 of GPL version 3, you are granted
 * additional permissions described in the GCC Runtime Library Exception,
 * version 3.1, as published by the Free Software Foundation.
 *
 * You should have received a copy of the GNU General Public License and
 * a copy of the GCC Runtime Library Exception along with this program;
 * see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
.text
.global __cpu_init
.align 2

__cpu_init:

/* Clear cp15 regs with unknown reset values */
mov	r0, #0x0
mcr	p15, 0, r0, c5, c0, 0	/* DFSR */
mcr	p15, 0, r0, c5, c0, 1	/* IFSR */
mcr	p15, 0, r0, c6, c0, 0	/* DFAR */
mcr	p15, 0, r0, c6, c0, 2	/* IFAR */
mcr	p15, 0, r0, c9, c13, 2	/* PMXEVCNTR */
mcr	p15, 0, r0, c13, c0, 2	/* TPIDRURW */
mcr	p15, 0, r0, c13, c0, 3	/* TPIDRURO */


/* Reset and start Cycle Counter */
mov	r2, #0x80000000		/* clear overflow */
mcr	p15, 0, r2, c9, c12, 3
mov	r2, #0xd		/* D, C, E */
mcr	p15, 0, r2, c9, c12, 0
mov	r2, #0x80000000		/* enable cycle counter */
mcr	p15, 0, r2, c9, c12, 1

bx	lr

.end
