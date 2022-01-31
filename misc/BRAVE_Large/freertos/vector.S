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
.org 0
.text

.global _boot
.global _vector_table

.global FIQInterrupt
.global IRQInterrupt
.global SWInterrupt
.global DataAbortInterrupt
.global PrefetchAbortInterrupt

.global irq_interrupt
.global prof_pc

.section .vectors, "a"
_vector_table:
b _boot
b Undefined
b SVCHandler
b PrefetchAbortHandler
b DataAbortHandler
nop                               @ reserved
b FreeRTOS_IRQ_Handler
b FIQHandler

.text
IRQHandler:                       @ IRQ vector handler
stmdb	sp!,{r0-r3,r12,lr}        @ save state from compiled code
@ bl 	irq_interrupt
bl FreeRTOS_IRQ_Handler
ldmia	sp!,{r0-r3,r12,lr}		  @ restore state from compiled code
subs	pc, lr, #4				  @ adjust return

FIQHandler: b .                   @ FIQ vector handler
Undefined: b .                    @ Undefined handler
SVCHandler: b FreeRTOS_SWI_Handler @ SWI handler

DataAbortHandler: 
mrc p15, #0, r12, c5, c0, #0
b .             @ Data abort handler

PrefetchAbortHandler: b .         @ Prefetch bbort handler

.end
