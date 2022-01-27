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
#ifndef H_CBUF_H
#define H_CBUF_H

#include <stddef.h>
#include <stdatomic.h>
#include <stdbool.h>
#include "mem_utils.h"

struct cbuf {
    char *data;
    size_t mask;
    atomic_size_t head;
    atomic_size_t tail;
};

/**
 * Initialize the circular buffer
 */
static inline void cbuf_init(struct cbuf *cbuf, void *data, size_t mask)
{
    cbuf->data = data;
    cbuf->mask = mask;
    cbuf->head = cbuf->tail = 0;
}

/**
 * Returns the number of elements contained in the circular buffer
 */
static inline size_t cbuf_size(const struct cbuf *cbuf)
{
    size_t head, tail;

    head = atomic_load_explicit(&cbuf->head, memory_order_relaxed);
    tail = atomic_load_explicit(&cbuf->tail, memory_order_relaxed);

    return (head - tail);
}

/**
 * Returns the capacity of the circular buffer
 */
static inline size_t cbuf_capacity(const struct cbuf *cbuf)
{
    return (cbuf->mask + 1);
}

/**
 * Returns the remaining space in the ring buffer
 */
static inline size_t cbuf_space(const struct cbuf *cbuf)
{
    return cbuf_capacity(cbuf) - cbuf_size(cbuf);
}

/**
 * Checks if the circular buffer contains no elements
 */
static inline bool cbuf_empty(const struct cbuf *cbuf)
{
    size_t head, tail;

    head = atomic_load_explicit(&cbuf->head, memory_order_relaxed);
    tail = atomic_load_explicit(&cbuf->tail, memory_order_relaxed);

    return (head == tail);
}

/**
 * Checks if the circular buffer storage is full
 */
static inline bool cbuf_full(const struct cbuf *cbuf)
{
    size_t head, tail;

    head = atomic_load_explicit(&cbuf->head, memory_order_relaxed);
    tail = atomic_load_explicit(&cbuf->tail, memory_order_relaxed);

    return (tail + cbuf_capacity(cbuf) == head);
}

/**
 * Pushes an element in the circular buffer
 */
static inline bool cbuf_push(struct cbuf *cbuf, const void *elem, size_t elem_size)
{
    size_t offset, head, tail;

    head = atomic_load_explicit(&cbuf->head, memory_order_relaxed);
    tail = atomic_load_explicit(&cbuf->tail, memory_order_acquire);

    if (head - tail <= cbuf->mask) {
        offset = (head & cbuf->mask) * elem_size;
        memcpy(cbuf->data + offset, elem, elem_size);
        atomic_store_explicit(&cbuf->head, head + 1, memory_order_release);
        return true;
    }

    return false;
}

/**
 * Pops an element from the circular buffer
 */
static inline bool cbuf_pop(struct cbuf *cbuf, void *elem, size_t elem_size)
{
    size_t offset, head, tail;

    head = atomic_load_explicit(&cbuf->head, memory_order_acquire);
    tail = atomic_load_explicit(&cbuf->tail, memory_order_relaxed);

    if ((head - tail) > 0) {
        offset = (tail & cbuf->mask) * elem_size;
        memcpy(elem, cbuf->data + offset, elem_size);
        atomic_store_explicit(&cbuf->tail, tail + 1, memory_order_release);
        return true;
    }

    return false;
}

#endif /* H_CBUF_H */