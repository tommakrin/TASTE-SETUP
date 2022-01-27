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
#ifndef H_UART_H
#define H_UART_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

typedef struct uart uart_t;

extern uart_t * const UART_INST;

/**
 * Initialize UART driver instance
 * Configuration used:
 *     - baud rate 115200
 */
void uart_init();

/** ---- Non-blocking API ----------------------------------------------------------------------- */

/**
 * Read byte from RX buffer (non-blocking)
 * Returns true if a byte was poped from the rx buffer, false otherwise
 */
bool uart_read_byte(uart_t *uart, uint8_t *byte);

/**
 * Read n bytes from RX buffer (non-blocking)
 * Returns the number of bytes popped from the RX buffer
 */
size_t uart_read(uart_t *uart, void *buf, size_t n);

/**
 * Write a byte to TX buffer (non-blocking)
 * Returns true if successful, false if the TX buffer is full
 */
bool uart_write_byte(uart_t *uart, uint8_t byte);

/**
 * Write n bytes to TX buffer (non-blocking)
 * Returns the number of bytes written to the TX buffer
 */
size_t uart_write(uart_t *uart, const void *data, size_t n);

/** ---- Blocking API --------------------------------------------------------------------------- */

/**
 * Write byte to TX buffer
 * Note: the function blocks if the TX buffer is full
 */
void uart_print_byte(uart_t *uart, uint8_t byte);

/**
 * Write null-terminated string to TX buffer
 * Note: the function blocks if the TX buffer is full
 */
void uart_print_string(uart_t *uart, const char *s);

/**
 * Write hex formatted number to TX buffer
 * Note: the function blocks if the TX buffer is full
 */
void uart_print_hex(uart_t *uart, uint32_t num);


void uart_print_int(uint32_t num);

#endif /* H_UART_H */
