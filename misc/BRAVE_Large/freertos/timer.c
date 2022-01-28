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
#include "irq.h"
#include "timer.h"

/**
 * APB Timer global interrupt counter
 */
uint32_t icnt;

void clearTimerInterrupt()
{
    *((volatile uint32_t *)TIM_CTRL_REG_ADDR) |= TIM_CLEAR_IRQ_BIT;
}

uint32_t getSWCounter()
{
    return icnt;
}

static inline void setTimerCtrlReg(uint32_t value)
{
    *((volatile uint32_t *)TIM_CTRL_REG_ADDR) = value;
}

static inline uint32_t getTimerCtrlReg()
{
    return *((volatile uint32_t *)TIM_CTRL_REG_ADDR);
}

static void timerISR()
{
    extern void FreeRTOS_SWI_Handler();
    FreeRTOS_SWI_Handler();
    clearTimerInterrupt();  // Clear IRQ
}

static void timerInitInstance()
{
    uint32_t ctrl_value;

    /* reset timer while setting flags */
    ctrl_value = TIM_RESET_BIT | TIM_ENABLE_BIT | TIM_CLEAR_IRQ_BIT;
    setTimerCtrlReg(ctrl_value);

    /* unset reset flag */
    ctrl_value = getTimerCtrlReg() & ~TIM_RESET_BIT;
    setTimerCtrlReg(ctrl_value);
}

void timerInit()
{
    irq_register_handler(0, timerISR, NULL);
    timerInitInstance();
}
