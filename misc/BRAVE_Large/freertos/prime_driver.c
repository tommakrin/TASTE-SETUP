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
#include "prime_driver.h"
#include "uart.h"
#include "util.h"

void prime_number_init()
{
    io_write(_hbeat, 0x1); // Make sure status led is off
    if (io_read(_hbeat))
    {
        io_write(_hbeat, 0x0); // Set status led on
        uart_print_string(UART_INST, "~BAMBU IP~\r\n");
    }
    else
    {
        uart_print_string(UART_INST, "BAMBU Failed\r\n");
    }
}


uint8_t prime_time(uint32_t num)
{
    uint32_t result = 0;
    uint8_t ret;

    // Load number
    io_write(_input, num); 

    // Start computing
    io_write(_start, 0x1);

    // Check whether there is a DONE signal
    while (io_read(_done) != 1)
    {
        
    }

    if(io_read(_done) == 1) 
    {    
        result = io_read(_output);
        // Cross-check result
        if(result == num) {
            ret = 1;
        } else {
            ret = 0;
        }
    }
    return ret;
}
