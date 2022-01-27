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
#ifndef H_CONFIG_H
#define H_CONFIG_H

#include <stdint.h>

#define CPU_FCLK_HZ    (300000000)
#define FCLK_HZ        (60000000)
#define APB_CLK_HZ     (9000000)

#define APB_BASE_ADDR  (0x00010000)
#define APB_UART_OFF   (0x00001000)
#define APB_SLV_1_OFF  (0x00002000) // Used for hardware timer interrupt
#define APB_SLV_2_OFF  (0x00006000) // Used for TASTE custom peripheral

#define BRAM_ADDR      (0x20000000)

#define SRAM_ADDR      (0x20010000)
#define SRAM_SIZE      (0x10000)

#define AHB_BASE_ADDR  (0x30000000)
#define AHB_SLV_0_OFF  (0x00010000)
#define AHB_SLV_1_OFF  (0x00020000)

// Timer stuff

#define TIM_BASE_ADDR (APB_BASE_ADDR + APB_SLV_1_OFF)
#define TIM_CTRL_REG_ADDR (TIM_BASE_ADDR + 0x04)
#define TIM_COUNTER_ADDR (TIM_BASE_ADDR + 0x08)

#define BIT(n) (1UL << n)

#define TIM_ENABLE_BIT BIT(0)
#define TIM_RESET_BIT BIT(1)
#define TIM_CLEAR_IRQ_BIT BIT(2)
#define TIM_MASK_IRQ_BIT BIT(5)


#endif /* H_CONFIG_H */