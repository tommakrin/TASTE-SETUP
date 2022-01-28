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
// #include <bsp.h>
// #include <leon.h>
// #include <ambapp.h>
// #include <rtems/score/types.h>

#include "uart.h"
#include "dbg_printf.h"

#define SERIAL_PORT_INDEX_TO_PRINT_TO 0
#define _DEBUG

#ifdef _DEBUG
// typedef volatile LEON3_UART_Regs_Map UART;

// A version of putc I wrote for leon3's serial ports.
// I tested it on my ML509 - works fine.
// void uart_write_byte(UART_INST, unsigned char c)
// {
//     static int initialized = 0;
//     static int foundRequestedPort = 0;
//     static UART *pUART = NULL;

//     if (!initialized) {
//         struct ambapp_apb_info serialPortsInfo[LEON3_APBUARTS];

//         initialized = 1;
//         if (SERIAL_PORT_INDEX_TO_PRINT_TO >= ambapp_find_apbslvs_next( // LCOV_EXCL_LINE LCOV_EXCL_BR_LINE
//                 &ambapp_plb, VENDOR_GAISLER, GAISLER_APBUART, serialPortsInfo,
//                 0, LEON3_APBUARTS)) {
//             // Oops, our available serial ports don't go that high...
//             return; // LCOV_EXCL_LINE LCOV_EXCL_BR_LINE
//         }
//         foundRequestedPort = 1;
//         pUART = (UART *) serialPortsInfo[SERIAL_PORT_INDEX_TO_PRINT_TO].start;
//         uint32_t ctrlMask = pUART->ctrl;

//         // Enable TX, RX
//         ctrlMask |= LEON_REG_UART_CTRL_TE | LEON_REG_UART_CTRL_RE;
//         ctrlMask &=
//             LEON_REG_UART_CTRL_LB    // no loopback
//             | LEON_REG_UART_CTRL_FL  // no flow control
//             | LEON_REG_UART_CTRL_PS  // no parity selected...
//             | LEON_REG_UART_CTRL_PE; // ...because we don't want parity bits
//         pUART->ctrl |= ctrlMask;
//         pUART->status = 0;
//     }

//     if (!foundRequestedPort) // If we never managed to find the requested UART  // LCOV_EXCL_LINE LCOV_EXCL_BR_LINE
//         return; // (the SERIAL_PORT_INDEX_TO_PRINT_TO one) // LCOV_EXCL_LINE LCOV_EXCL_BR_LINE
//                 // then just return and print nothing.

//     if (c == '\n')
//         uart_write_byte(UART_INST, '\r');
//     while(!(pUART->status & LEON_REG_UART_STATUS_THE))
//         ;                           // wait until slot is empty...
//     pUART->data = (unsigned int) c; // ...and then transmit!
// }

// This is a BSD-licensed implementation of printf, supporting only %d, %u, %x,
// %X, %c and %s.  It is offered without guarantees of correctness - it works
// fine in my local tests, and since serial output is only meant to be used
// during debugging, this is anyway code that is not supposed to "fly" - it
// should not be compiled at all in the final version of the embedded code.
//
// Again, this is delivered with no guarantees - if you want such, you'll need
// to implement a printf of your own.
//
// Original code available in: https://github.com/mpredfearn/simple-printf
// (BSD Licensed).

enum flags {
    PAD_ZERO	= 1,
    PAD_RIGHT	= 2,
};

static int prints(const char *string, int width, int flags)
{
    int pc = 0, padchar = ' ';

    if (width > 0) {
        int len = 0;
        const char *ptr;
        for (ptr = string; *ptr; ++ptr) ++len;
        if (len >= width) width = 0;
        else width -= len;
        if (flags & PAD_ZERO)
            padchar = '0';
    }
    if (!(flags & PAD_RIGHT)) {
        for ( ; width > 0; --width) {
            uart_write_byte(UART_INST, padchar);
            ++pc;
        }
    }
    for ( ; *string ; ++string) {
        if (*string == '\n')
            uart_write_byte(UART_INST, '\r');
        uart_write_byte(UART_INST, *string);
        ++pc;
    }
    for ( ; width > 0; --width) {
        uart_write_byte(UART_INST, padchar);
        ++pc;
    }

    return pc;
}

#define PRINT_BUF_LEN 64

static int simple_outputi(
    int i, int base, int sign, int width, int flags, int letbase)
{
    char print_buf[PRINT_BUF_LEN];
    char *s;
    int t, neg = 0, pc = 0;
    unsigned int u = i;

    if (i == 0) {
        print_buf[0] = '0';
        print_buf[1] = '\0';
        return prints(print_buf, width, flags);
    }

    if (sign && base == 10 && i < 0) { // LCOV_EXCL_LINE LCOV_EXCL_BR_LINE
        // base is 10 in all cases where sign can be negative (see callers)
        neg = 1;
        u = -i;
    }

    s = print_buf + PRINT_BUF_LEN-1;
    *s = '\0';

    while (u) {
        t = u % base;
        if( t >= 10 )
            t += letbase - '0' - 10;
        *--s = t + '0';
        u /= base;
    }

    if (neg) {
        if( width && (flags & PAD_ZERO) ) {
            uart_write_byte(UART_INST, '-');
            ++pc;
            --width;
        }
        else {
            *--s = '-';
        }
    }

    return pc + prints (s, width, flags);
}

static int simple_vsprintf(const char *format, va_list ap)
{
    int width, flags;
    int pc = 0;
    char scr[2];
    union {
        char c;
        char *s;
        int i;
        unsigned int u;
        void *p;
    } u;

    for (; *format != 0; ++format) {
        if (*format == '%') {
            ++format;
            width = flags = 0;
            if (*format == '\0')
                break;
            if (*format == '%')
                goto out;
            if (*format == '-') {
                ++format;
                flags = PAD_RIGHT;
            }
            while (*format == '0') {
                ++format;
                flags |= PAD_ZERO;
            }
            if (*format == '*') {
                width = va_arg(ap, int);
                format++;
            } else {
                for ( ; *format >= '0' && *format <= '9'; ++format) {
                    width *= 10;
                    width += *format - '0';
                }
            }
            switch (*format) {
                case('d'):
                    u.i = va_arg(ap, int);
                    pc += simple_outputi(u.i, 10, 1, width, flags, 'a');
                    break;

                case('u'):
                    u.u = va_arg(ap, unsigned int);
                    pc += simple_outputi(u.u, 10, 0, width, flags, 'a');
                    break;

                case('x'):
                    u.u = va_arg(ap, unsigned int);
                    pc += simple_outputi(u.u, 16, 0, width, flags, 'a');
                    break;

                case('X'):
                    u.u = va_arg(ap, unsigned int);
                    pc += simple_outputi(u.u, 16, 0, width, flags, 'A');
                    break;

                case('c'):
                    u.c = va_arg(ap, int);
                    scr[0] = u.c;
                    scr[1] = '\0';
                    pc += prints(scr, width, flags);
                    break;

                case('s'):
                    u.s = va_arg(ap, char *);
                    pc += prints(u.s ? u.s : "(null)", width, flags);
                    break;
                default:
                    break;
            }
        }
        else {
out:
            if (*format == '\n')
                uart_write_byte(UART_INST, '\r');
            uart_write_byte(UART_INST, *format);
            ++pc;
        }
    }
    return pc;
}
#endif

int dbg_printf(const char *fmt, ...)
{
#if defined(_DEBUG) || defined(COVERAGE_ENABLED)
    va_list ap;
    va_start(ap, fmt);
    int ret = simple_vsprintf(fmt, ap);
    va_end(ap);
    return ret;
#else
    (void)fmt;
    return 0;
#endif
}
