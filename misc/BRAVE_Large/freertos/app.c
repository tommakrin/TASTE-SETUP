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
#include "brave.h"
#include "config.h"
// #include "tests.c"
#include "timer.c"
#include "uart.h"
#include "prime_driver.h"
#include "dbg_printf.h"

// Here start the FreeRTOS kernel includes
#include "FreeRTOS.h"
#include "semphr.h"
#include "task.h"

extern SemaphoreHandle_t xSemaphoreUART;

// Globals

uint32_t tom = 0;
uint32_t jerry = 0;
uint32_t droopy = 0;
uint32_t primecnt = 0;

/*
 * Code body for first task - Pinky
 */
void pinky(void *pvParameters)
{
    uint32_t cnt = 0;
    (void)pvParameters;

    while (1)
    {
        tom++;
        if ((tom & 524287) == 524287)
        {
            dbg_printf("Hi from Tom: %d \r\n", cnt++);
            primecnt++;
            vTaskDelay(50);
        }
    }
}

/*
 * Code body for second task - Brain
 */
void brain(void *pvParameters)
{
    uint32_t cnt = 0;

    (void)pvParameters;
    while (1)
    {
        jerry++;
        if ((jerry & 524287) == 524287)
        {
            dbg_printf("Hi from Jerry: %d \r\n", cnt++);
            vTaskDelay(50);
        }
    }
}

/*
 * Code body for the prime number check task
 * */

void prime(void *pvParameters)
{
    (void)pvParameters;
    while(1)
    {
        droopy++;
        if((droopy & 524287) == 524287)
        {
            dbg_printf("Hi from Prime: %d \r\n", primecnt);
            uint8_t res = prime_time(primecnt);

            if(res == 1)
            {
                uart_print_string(UART_INST, "Prime: ");
                uart_print_int(primecnt);
                uart_print_string(UART_INST, "\r\n");
            }
            vTaskDelay(50);
        }
    }
}

/*
 * Declare stacks and buffers for the task creation.
 */
static StaticTask_t xBufPinky, xBufBrain, xBufPrime;
StackType_t xStackPinky[configMINIMAL_STACK_SIZE];
StackType_t xStackBrain[configMINIMAL_STACK_SIZE];
StackType_t xStackPrime[configMINIMAL_STACK_SIZE];

int main()
{
    // Initialize UART
    uart_init();

    // Setup timer IRQ to properly deal with BRAVE HW details
    brave_init();

    // Initialize prime IP
    prime_number_init();

    // Run tests
    //run_tests_all();

    dbg_printf("BRAVE Init completed successfully! \r\n");
    dbg_printf("Initializing FreeRTOS... \r\n");

    /* Create the task without using any dynamic memory allocation. */
    xTaskCreateStatic(
        pinky,                    /* Function that implements the task. */
        "Pinky",                  /* Text name for the task. */
        configMINIMAL_STACK_SIZE, /* Number of indexes in the xStack array. */
        (void *)NULL,             /* Parameter passed into the task. */
        1,                        /* Priority at which the task is created. */
        &xStackPinky[0],               /* Array to use as the task's stack. */
        &xBufPinky);            /* Variable to hold the task's data structure. */

    xTaskCreateStatic(
        brain,                    /* Function that implements the task. */
        "Brain",                  /* Text name for the task. */
        configMINIMAL_STACK_SIZE, /* Number of indexes in the xStack array. */
        (void *)NULL,             /* Parameter passed into the task. */
        1,                        /* Priority at which the task is created. */
        &xStackBrain[0],              /* Array to use as the task's stack. */
        &xBufBrain);           /* Variable to hold the task's data structure. */

    xTaskCreateStatic(
        prime,                    /* Function that implements the task. */
        "TASTEPrime",                  /* Text name for the task. */
        configMINIMAL_STACK_SIZE, /* Number of indexes in the xStack array. */
        (void *)NULL,             /* Parameter passed into the task. */
        1,                        /* Priority at which the task is created. */
        &xStackPrime[0],              /* Array to use as the task's stack. */
        &xBufPrime);           /* Variable to hold the task's data structure. */

    // Start the scheduler
    vTaskStartScheduler();

    // Should never reach here
    while (1)
    {
    }
    return 0;
}
