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
#include "irq.h"

#define IRQ_NR_HANDLERS 8

struct irq_handler {
    irq_handler_fn_t fn;
    void *ctx;
};

static struct irq_handler IRQ_HANDLERS[IRQ_NR_HANDLERS] = {};

void irq_register_handler(size_t index, irq_handler_fn_t handler, void *ctx)
{
    if (index < IRQ_NR_HANDLERS) {
        IRQ_HANDLERS[index].fn = handler;
        IRQ_HANDLERS[index].ctx = ctx;
    }
}

static inline void irq_handler_invoke(size_t index)
{
    struct irq_handler *handler;

    handler = &IRQ_HANDLERS[index];
    if (handler->fn) {
        handler->fn(handler->ctx);
    }
}

void irq_interrupt()
{
    irq_handler_invoke(0); // Invokes Timer ISR
}