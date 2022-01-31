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
.section ".got2","aw"
.align    2

.text
.Lsbss_start:
.long __sbss_start__

.Lsbss_end:
.long __sbss_end__

.Lbss_start:
.long __bss_start__

.Lbss_end:
.long __bss_end__

.Lstack:
.long __stack

.global _startup

_startup:
bl      __cpu_init

mov    r0, #0

@ clear sbss
ldr r1,.Lsbss_start               @ calculate beginning of the SBSS
ldr r2,.Lsbss_end                 @ calculate end of the SBSS

.Lloop_sbss:
cmp r1,r2
bge .Lenclsbss                    @ If no SBSS, no clearing required
str r0, [r1], #4
b .Lloop_sbss

.Lenclsbss:

@ clear bss
ldr r1,.Lbss_start                @ calculate beginning of the BSS
ldr r2,.Lbss_end                  @ calculate end of the BSS

.Lloop_bss:
cmp r1,r2
bge .Lenclbss                     @ If no BSS, no clearing required
str r0, [r1], #4
b .Lloop_bss

.Lenclbss:

@ set stack pointer
ldr    r13,.Lstack                @ stack address

@ set the counter for the loop
mov r0, #0
mov r1, #8

@ push 8 regs with zeros to mitigate GDB/OpenOCD data abort issues. Use r0, r1
.Lloop_zeros:
cmp r0,r1
bge .Lstart_main                     @ If we have pushed 8 zero-words, continue
PUSH {r0}
add r0, r0, #1
b .Lloop_zeros

.Lstart_main:

@ make sure argc and argv are valid
mov r0, #0
mov r1, #0

bl main                           @ Jump to main C code

.Lexit: b .                       @ for safety

.Lstart:
.size _startup,.Lstart-_startup
