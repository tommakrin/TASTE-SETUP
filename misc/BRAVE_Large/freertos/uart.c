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
#include <stdbool.h>
#include <stdint.h>
#include "config.h"
#include "cbuf.h"
#include "irq.h"
#include "uart.h"
#include <FreeRTOS.h>
#include <semphr.h>

#define BIT(n) (1UL << n)

#define UART_IRQ 0

#define UART_DEFAULT_BAUD_RATE 115200

#define UART_REG_VERSION 0x0

#define UART_REG_CONTROL 0x1
#define UART_CONTROL_RESET BIT(0)
#define UART_CONTROL_ENA BIT(1)
#define UART_CONTROL_RX_ENA BIT(2)
#define UART_CONTROL_TX_ENA BIT(3)
#define UART_CONTROL_RX_FLUSH BIT(4)
#define UART_CONTROL_TX_FLUSH BIT(5)

#define UART_REG_CLK_DIV 0x2

#define UART_REG_CONFIG 0x3
#define UART_CONFIG_PARITY_EN BIT(0)
#define UART_CONFIG_PARITY_ODD BIT(1)
#define UART_CONFIG_SHIFT_MSB BIT(2)
#define UART_CONFIG_TWO_STOP_BITS BIT(3)
#define UART_CONFIG_SEVENT_BITS_DATA BIT(4)

#define UART_REG_IRQ_STATUS 0x4
#define UART_IRQ_STATUS_TX_READY BIT(0)
#define UART_IRQ_STATUS_TX_EMPTY BIT(1)
#define UART_IRQ_STATUS_TX_DONE BIT(2)
#define UART_IRQ_STATUS_TX_OVF BIT(3)
#define UART_IRQ_STATUS_RX_READY BIT(4)
#define UART_IRQ_STATUS_RX_OERR BIT(5)
#define UART_IRQ_STATUS_RX_PERR BIT(6)
#define UART_IRQ_STATUS_RX_FERR BIT(7)

#define UART_REG_IRQ_MASK 0x5
#define UART_IRQ_MASK_TX_READY BIT(0)
#define UART_IRQ_MASK_TX_EMPTY BIT(1)
#define UART_IRQ_MASK_TX_DONE BIT(2)
#define UART_IRQ_MASK_TX_OVF BIT(3)
#define UART_IRQ_MASK_RX_READY BIT(4)
#define UART_IRQ_MASK_RX_OERR BIT(5)
#define UART_IRQ_MASK_RX_PERR BIT(6)
#define UART_IRQ_MASK_RX_FERR BIT(7)

#define UART_REG_IRQ_ACK 0x6
#define UART_IRQ_ACK_TX_READY BIT(0)
#define UART_IRQ_ACK_TX_EMPTY BIT(1)
#define UART_IRQ_ACK_TX_DONE BIT(2)
#define UART_IRQ_ACK_TX_OVF BIT(3)
#define UART_IRQ_ACK_RX_READY BIT(4)
#define UART_IRQ_ACK_RX_OERR BIT(5)
#define UART_IRQ_ACK_RX_PERR BIT(6)
#define UART_IRQ_ACK_RX_FERR BIT(7)

#define UART_REG_RX_BUF 0x7

#define UART_REG_TX_BUF 0x8

#define UART_BUF_SIZE 256
#define UART_BUF_ELEM_SIZE 1

SemaphoreHandle_t xSemaphoreUART = NULL;

/**
 * UART driver instance
 */
struct uart
{
    void *base_addr;                   /**< physical base address */
    uint8_t tx_storage[UART_BUF_SIZE]; /**< TX storage buffer     */
    uint8_t rx_storage[UART_BUF_SIZE]; /**< RX storage buffer     */
    struct cbuf tx_buf;                /**< TX circular buffer    */
    struct cbuf rx_buf;                /**< RX circular buffer    */
};

static struct uart UART_INSTANCES[1];

struct uart *const UART_INST = &UART_INSTANCES[0];

static inline uint32_t uart_reg_read(struct uart *uart, uint32_t reg_offset)
{
    return *((volatile uint32_t *)uart->base_addr + reg_offset);
}

static inline void uart_reg_write(struct uart *uart, uint32_t reg_offset, uint32_t value)
{
    *((volatile uint32_t *)uart->base_addr + reg_offset) = value;
}

void uart_irq_handler()
{
    struct uart *uart = &UART_INSTANCES[0];
    uint32_t irq_sts, irq_ack, irq_mask;
    uint8_t data;

    irq_sts = irq_ack = 0;

    irq_sts = uart_reg_read(uart, UART_REG_IRQ_STATUS);

    /* handle tx send request */
    while (irq_sts & UART_IRQ_STATUS_TX_READY)
    {
        if (cbuf_pop(&uart->tx_buf, &data, UART_BUF_ELEM_SIZE))
        {
            uart_reg_write(uart, UART_REG_TX_BUF, data);
        }
        else
        {
            /* buffer is empty, mask irq until next write request */
            irq_mask = uart_reg_read(uart, UART_REG_IRQ_MASK);
            irq_mask &= ~UART_IRQ_MASK_TX_READY;
            uart_reg_write(uart, UART_REG_IRQ_MASK, irq_mask);
            break;
        }

        /* handle rx receive request */
        if (irq_sts & UART_IRQ_STATUS_RX_READY)
        {
            data = uart_reg_read(uart, UART_REG_RX_BUF);
            cbuf_push(&uart->rx_buf, &data, UART_BUF_ELEM_SIZE);
        }

        /* acknowledge interrupts */
        irq_ack = irq_sts;
        uart_reg_write(uart, UART_REG_IRQ_ACK, irq_ack);

        irq_sts = uart_reg_read(uart, UART_REG_IRQ_STATUS);
    }
}

static void uart_init_instance(struct uart *uart, uintptr_t base_addr)
{
    uint32_t ctrl, clk_div, irq_mask;

    uart->base_addr = (void *)base_addr;

    /* initialize circular buffers */
    cbuf_init(&uart->tx_buf, uart->tx_storage, UART_BUF_SIZE - 1);
    cbuf_init(&uart->rx_buf, uart->rx_storage, UART_BUF_SIZE - 1);

    /* reset uart while setting flags */
    ctrl = UART_CONTROL_RESET | UART_CONTROL_ENA | UART_CONTROL_TX_ENA | UART_CONTROL_RX_ENA;
    uart_reg_write(uart, UART_REG_CONTROL, ctrl);

    /* set baud rate */
    clk_div = (APB_CLK_HZ / UART_DEFAULT_BAUD_RATE);
    uart_reg_write(uart, UART_REG_CLK_DIV, clk_div);

    /* setup irq mask */
    irq_mask = UART_IRQ_MASK_RX_READY;
    uart_reg_write(uart, UART_REG_IRQ_MASK, irq_mask);

    /* unset reset flag */
    ctrl = uart_reg_read(uart, UART_REG_CONTROL) & ~UART_CONTROL_RESET;
    uart_reg_write(uart, UART_REG_CONTROL, ctrl);
}

void uart_init()
{
    uart_init_instance(UART_INST, APB_BASE_ADDR + APB_UART_OFF);

    irq_register_handler(1, uart_irq_handler, UART_INST);

    /* Create a binary semaphore without using any dynamic memory
    allocation.  The semaphore's data structures will be saved into
    the xSemaphoreBuffer variable. */
    static StaticSemaphore_t xSemaphoreBufferUART;
    xSemaphoreUART = xSemaphoreCreateBinaryStatic(&xSemaphoreBufferUART);
    xSemaphoreGive(xSemaphoreUART);
}

bool uart_read_byte(struct uart *uart, uint8_t *byte)
{
    return cbuf_pop(&uart->rx_buf, byte, UART_BUF_ELEM_SIZE);
}

bool uart_write_byte(struct uart *uart, uint8_t byte)
{
    uint32_t irq_mask;

    if (cbuf_push(&uart->tx_buf, &byte, UART_BUF_ELEM_SIZE))
    {
        irq_mask = uart_reg_read(uart, UART_REG_IRQ_MASK);
        irq_mask |= UART_IRQ_MASK_TX_READY;
        uart_reg_write(uart, UART_REG_IRQ_MASK, irq_mask);

        return true;
    }

    return false;
}

size_t uart_write(struct uart *uart, const void *data, size_t n)
{
    uint32_t irq_mask;
    size_t req;

    req = n;

    /* slow (bytes pushed one at a time...) */
    while (n && cbuf_push(&uart->tx_buf, data, UART_BUF_ELEM_SIZE))
    {
        --n;
        ++data;
    }

    /* enable `TX_READY` interrupt, bytes will be pushed to UART TX from irq handler */
    irq_mask = uart_reg_read(uart, UART_REG_IRQ_MASK);
    irq_mask |= UART_IRQ_MASK_TX_READY;
    uart_reg_write(uart, UART_REG_IRQ_MASK, irq_mask);

    return (req - n);
}

void uart_print_byte(uart_t *uart, uint8_t byte)
{
    while (!uart_write_byte(uart, byte))
    {
        xSemaphoreGive(xSemaphoreUART);
        xSemaphoreTake(xSemaphoreUART, 0);
    }
}

void uart_print_string(uart_t *uart, const char *s)
{

    if (xSemaphoreTake(xSemaphoreUART, 0))
    {
        while (s && *s != '\0')
        {
            uart_print_byte(uart, *s);
            ++s;
        }
        xSemaphoreGive(xSemaphoreUART);
    }
}

void uart_print_int(uint32_t value)
{
    char tmp[10];
    int idx = 9;
    tmp[idx--] = 0;
    while (value != 0)
    {
        tmp[idx] = '0' + (value % 10);
        idx--;
        value = value / 10;
    }
    uart_print_string(UART_INST, &tmp[idx + 1]);
}

void uart_print_hex(uart_t *uart, uint32_t num)
{
    char buf[8] = {0};
    uart_print_string(uart, "0x");

    uint8_t digit = 0;
    for (size_t i = 0; i < 8; ++i)
    {
        digit = (num & 15);
        if (digit < 10)
        {
            buf[i] = '0' + digit;
        }
        else
        {
            buf[i] = 'A' + (digit - 10);
        }
        num >>= 4;
    }

    for (size_t i = 8; i;)
    {
        uart_print_byte(uart, buf[--i]);
    }
}
