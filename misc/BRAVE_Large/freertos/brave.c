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
#include <FreeRTOS.h>
#include "task.h"

void setupBraveTimerIRQ(void *pvParameters)
{
    extern void timerInit();
    timerInit();
    while(1) {
       vTaskDelay(4023123123);
    }
}

void brave_init()
{
    static StaticTask_t xTaskBuffer;
    static StackType_t xStack[configMINIMAL_STACK_SIZE];
    xTaskCreateStatic(
        setupBraveTimerIRQ,       /* Function that implements the task. */
        "SetupBRAVETimerIRQ",     /* Text name for the task. */
        configMINIMAL_STACK_SIZE, /* Number of indexes in the xStack array. */
        (void *)0,                /* Parameter passed into the task. */
        configMAX_PRIORITIES-1,   /* Priority at which the task is created. */
        &xStack[0],               /* Array to use as the task's stack. */
        &xTaskBuffer);            /* Variable to hold the task's data structure. */
}
