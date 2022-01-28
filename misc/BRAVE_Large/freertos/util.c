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
#include "config.h"
#include "uart.h"
#include "util.h"

/*
 * Prints the name and the value holded by a specific register
 */
void printRegister(uint32_t address, const char *s)
{
    uint32_t result = io_read(address);
    uart_print_string(UART_INST, "\r\n");
    uart_print_string(UART_INST, s);
    uart_print_string(UART_INST, ": ");
    uart_print_hex(UART_INST, result);
    uart_print_string(UART_INST, "\r\n");
}

uint32_t io_read(uint32_t addr)
{
    return *(volatile uint32_t *)(addr);
}

void io_write(uint32_t addr, uint32_t val)
{
    *(volatile uint32_t *)(addr) = (val);
}

int io_test(uint32_t addr, uint32_t val)
{
    int res = 0;
    // First write to register
    io_write(addr, val);
    // Then read from the same register
    uint32_t rb = io_read(addr);
    if (val != rb)
    {
        res = 0;
    }
    else
    {
        res = 1;
    }

    return res;
}

//void success(uint32_t address)
void success()
{
    uart_print_string(UART_INST, "Success! \r\n");
    // Only for debug
    // printRegister(address, "A");
}

void failure()
{
    uart_print_string(UART_INST, "Failure! \r\n");
}
