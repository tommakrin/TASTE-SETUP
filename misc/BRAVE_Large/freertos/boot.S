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
.global _prestart
.global _boot
.global __stack
.global __irq_stack
.global _vector_table
.global _startup

@ Initialization of the various processor modes

_prestart:
_boot:

@ Initialize processor registers to 0
mov r0,#0
mov r1,#0
mov r2,#0
mov r3,#0
mov r4,#0
mov r5,#0
mov r6,#0
mov r7,#0
mov r8,#0
mov r9,#0
mov r10,#0
mov r11,#0
mov r12,#0

@ setup IRQ stack pointer
mrs r0, cpsr                      @ get the current PSR
mvn r1, #0x1F                     @ set up the irq stack pointer
and r2, r1, r0
orr r2, r2, #0x12                 @ IRQ mode
msr cpsr, r2
ldr sp, =__irq_stack              @ set IRQ stack pointer
mov lr, #0

@ Setup SYS stack pointer
mrs r0, cpsr                      @ switch to SYS mode M = 0x1F
mvn r1, #0x1F
and r2, r1, r0
orr r2, r2, #0x1F
msr cpsr, r2
ldr sp,=__stack                   @ set SYS stack pointer
mov lr, #0

@ Setup MPU
dsb
mrc p15, 0, r1, c1, c0, 0         @ Read Control Register
bic r1, r1, #0x1                  @ Disable MPU
bic r1, r1, #(0x1 << 12)          @ Disable I Cache
bic r1, r1, #(0x1 << 2)           @ Disable D Cache
mcr p15, 0, r1, c1, c0, 0         @ Write Control Register

@ Invalidate BTAC
mcr p15, 0, r0, c7, c5, 6

@ Program Flow Prediction Enable
@ mov r1, #0
@ mrc p15, 0, r1, c1, c0, 0         @ Read Control Register configuration data
@ orr r1, r1, #(0x1 << 11)          @ Branch Prediction Enable bit
@ mcr p15, 0, r1, c1, c0, 0         @ Write Control Register configuration data

@ Invalidate L1 Cache
@ Invalidate Instruction cache
mov r1, #0
mcr p15, 0, r1, c7, c5, 0

@ Instruction cache Enable prior to Data Cache Invalidation
@ dsb
@ mrc    p15, 0, r1, c1, c0, 0      @ Read Control Register configuration data
@ orr    r1, r1, #(0x1 << 12)       @ Enable I Cache
@ mcr    p15, 0, r1, c1, c0, 0      @ Write Control Register configuration data

@ Invalidate Data Cache
mrc p15, 1, r0, c0, c0, 0         @ Read Cache Size ID
movw r3, #0x1FF

and     r0, r3, r0, LSR #13       @ r0 = no. of sets - 1
mov     r1, #0                    @ r1 = way counter way_loop
way_loop:
mov r3, #0                        @ r3 = set counter set_loop
set_loop:
mov     r2, r1, LSL #30
orr     r2, r3, LSL #5            @ r2 = set/way cache operation format
format:
mcr p15, 0, r2, c7, c6, 2         @ Invalidate line described by r2
add r3, r3, #1                    @ Increment set counter
cmp r0, r3                        @ Last set reached yet?
bgt set_loop                      @ if not, iterate set_loop
add r1, r1, #1                    @ else, next
cmp r1, #4                        @ Last way reached yet?
bne way_loop                      @ if not, iterate way_loop

@ region 0: TCM
mov r0,#0
mcr p15,0,r0,c6,c2,0              @ region number
mov r0,#0x0                       @ base address
mcr p15,0,r0,c6,c1,0              @ base addr
mov r0,#0b11111                   @ 64KB, all memory
mcr p15,0,r0,c6,c1,2              @ size & enable
movw r0,#(0x3|(0x3<<8))           @ write-back cacheable, shareable full access
mcr p15,0,r0,c6,c1,4              @ access control

@ region 1: APB-UART
mov r0, #1
mcr p15,0,r0,c6,c2,0              @ region number
mov r0,#0x00011000                @ base address
mcr p15,0,r0,c6,c1,0              @ base addr
mov r0,#0b1111                    @ 256B
mcr p15,0,r0,c6,c1,2              @ size & enable
movw r0,#(0b10000|(0x3<<8))       @ Shareable Device Memory, XN, full access
mcr p15,0,r0,c6,c1,4              @ access control

@ region 2: APB Port 2
mov r0, #2
mcr p15,0,r0,c6,c2,0              @ region number
mov r0,#0x00012000                @ base address
mcr p15,0,r0,c6,c1,0              @ base addr
mov r0,#0b10111                   @ 4kB
mcr p15,0,r0,c6,c1,2              @ size & enable
movw r0,#(0b10000|(0x3<<8))       @ Shareable Device Memory, XN, full access
mcr p15,0,r0,c6,c1,4              @ access control

@ region 3: APB Port 3
mov r0, #3
mcr p15,0,r0,c6,c2,0              @ region number
mov r0,#0x00016000                @ base address
mcr p15,0,r0,c6,c1,0              @ base addr
mov r0,#0b11001                   @ 8kB
mcr p15,0,r0,c6,c1,2              @ size & enable
movw r0,#(0b10000|(0x3<<8))       @ Shareable Device Memory, XN, full access
mcr p15,0,r0,c6,c1,4              @ access control

@ region 4: BRAM
mov r0, #4
mcr p15,0,r0,c6,c2,0              @ region number
mov r0,#0x20000000                @ base address
mcr p15,0,r0,c6,c1,0              @ base addr
mov r0,#0b11111                   @ 64kB
mcr p15,0,r0,c6,c1,2              @ size & enable
movw r0,#(0b10000|(0x3<<8))       @ Shareable Device Memory, XN, full access
mcr p15,0,r0,c6,c1,4              @ access control

@ region 5: SRAM
mov r0, #5
mcr p15,0,r0,c6,c2,0              @ region number
ldr r0,=#0x20010000               @ base address
mcr p15,0,r0,c6,c1,0              @ base addr
mov r0,#0b11111                   @ 64kB
mcr p15,0,r0,c6,c1,2              @ size & enable
movw r0,#(0xB | (0x3<<8))         @ Non shareable, write-back, write allocate, full access
mcr p15,0,r0,c6,c1,4              @ access control

@ region 6: AHB port 0
mov r0, #6
mcr p15,0,r0,c6,c2,0              @ region number
ldr r0,=#0x30010000               @ base address
mcr p15,0,r0,c6,c1,0              @ base addr
mov r0,#0b1111                    @ 256B
mcr p15,0,r0,c6,c1,2              @ size & enable
movw r0,#(0b10000|(0x3<<8))       @ Shareable Device Memory, XN, full access
mcr p15,0,r0,c6,c1,4              @ access control

@ region 7: AHB port 1
mov r0, #7
mcr p15,0,r0,c6,c2,0              @ region number
ldr r0,=#0x30020000               @ base address
mcr p15,0,r0,c6,c1,0              @ base addr
mov r0,#0b1111                    @ 256B
mcr p15,0,r0,c6,c1,2              @ size & enable
movw r0,#(0b10000|(0x3<<8))       @ Shareable Device Memory, XN, full access
mcr p15,0,r0,c6,c1,4              @ access control

@ Enable MPU and Data Cache
dsb
mrc p15, 0, r1, c1, c0, 0         @ Read Control Register configuration data
orr r1, r1, #(0x1 << 0)           @ Enable MPU
@ orr r1, r1, #(0x1 << 2)           @ Enable D Cache
mcr p15, 0, r1, c1, c0, 0         @ Write Control Register configuration data
isb

cpsie if @Enable interrupts

mrs r0, cpsr
bic r0, r0, #0x100
msr cpsr_xsf, r0

b    _startup                     @  jump to C startup code

.Ldone: b .                       @ for safety

.end
