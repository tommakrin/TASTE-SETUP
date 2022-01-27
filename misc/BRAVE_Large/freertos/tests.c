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

/* read/write register example from a AXI perpheral */
static void prime_number_ip_test()
{
    // printRegister(START_REG, START_REG_NAME);

    uart_print_string(UART_INST, "Firing BAMBU IP over AXI-APB bridge:\r\n\r\n");
    uart_print_string(UART_INST, "Waiting for LED...\r\n");

    io_write(APB_BASE_ADDR + APB_SLV_2_OFF + 0x18, 0x1);
    if (io_read(APB_BASE_ADDR + APB_SLV_2_OFF + 0x18))
    {
        io_write(APB_BASE_ADDR + APB_SLV_2_OFF + 0x18, 0x0);
        uart_print_string(UART_INST, "Yay! BAMBU IP should be up and running...\r\n");
    }
    else
    {
        uart_print_string(UART_INST, "No valid response received! Problem with BAMBU IP?\r\n");
        return;
    }

    uart_print_string(UART_INST, "Load num:\r\n");
    io_test(APB_BASE_ADDR + APB_SLV_2_OFF + 0x4, 0x7);

    uart_print_string(UART_INST, "Starting...\r\n");
    io_test(APB_BASE_ADDR + APB_SLV_2_OFF, 0x1);

    while (io_read(APB_BASE_ADDR + APB_SLV_2_OFF + 0x14) != 1)
    {
        uart_print_string(UART_INST, "Waiting for DONE...\r\n");
    }

    uart_print_string(UART_INST, "DONE! Reading result:\r\n");
    uint32_t result = io_read(APB_BASE_ADDR + APB_SLV_2_OFF + 0xC);
    uart_print_hex(UART_INST, result);

}

static void ahb_slv_rw_example()
{
    uart_print_string(UART_INST, "R/W through AXI-AHB bridge:\r\n");
    uart_print_string(UART_INST, "  AHB slave 0\r\n");
    if (io_test(AHB_BASE_ADDR + AHB_SLV_0_OFF, 0xDEADBEEF))
    {
        success(AHB_BASE_ADDR + AHB_SLV_0_OFF);
    }
    else
    {
        failure();
    }
   // uart_print_string(UART_INST, "\r\n  AHB slave 1\r\n");
    //if (io_test(AHB_BASE_ADDR + AHB_SLV_1_OFF, 0xDEADBEEF))
    //{
     //   success(AHB_BASE_ADDR + AHB_SLV_1_OFF);
    //}
    //else
    //{
     //   failure();
    //}
}

/*
 * Read-Write example on APB BRAM
 */
static void bram_rw_example()
{
    uart_print_string(UART_INST, "BRAM R/W : ");
    if (io_test(BRAM_ADDR, 0x25062009))
    {
        success(BRAM_ADDR);
    }
    else
    {
        failure();
    }
}

/*
 * Read-Write example on APB SRAM
 */
static void sram_rw_example()
{
    uart_print_string(UART_INST, "SRAM R/W : ");
    if (io_test(SRAM_ADDR, 0x24011987))
    {
        success(SRAM_ADDR);
    }
    else
    {
        failure();
    }
}

static void sram_test()
{
    uint32_t i;

    uart_print_string(UART_INST, "SRAM TEST \r\n");
    for (i = 0; i < SRAM_SIZE; i += 4)
    {
        io_write(SRAM_ADDR + i, ~(SRAM_ADDR + i));
    }
    for (i = 0; i < SRAM_SIZE; i += 4)
    {
        uint32_t val;
        val = io_read(SRAM_ADDR + i);
        if (val != ~(SRAM_ADDR + i))
        {
            uart_print_string(UART_INST, "SRAM ERROR \r\n");
            return;
        }
    }
}

void run_tests_all()
{
    prime_number_ip_test();
    //ahb_slv_rw_example();
    //bram_rw_example();
    //sram_rw_example();
    //sram_test();
}
