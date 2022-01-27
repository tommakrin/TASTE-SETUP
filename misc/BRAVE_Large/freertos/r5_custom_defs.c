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
/*
 * Provide temporary empty definitions so the linker doesn't cry
 */
#include "FreeRTOS.h"
#include "task.h"
#include "config.h"

uint32_t ulTimerExternalAddress = TIM_CTRL_REG_ADDR;
uint32_t min_sp_ptr = 0x7FFFFFFF;
uint32_t sanity_counter = 0;

void vMainAssertCalled(const char *pcFileName, int ulLineNumber)
{
	/* Add code here */
}
void vConfigureTickInterrupt(void)
{
	/* Add code here */
}

void vClearTickInterrupt(void)
{
	/* Add code here */
}

void vApplicationTickHook(void)
{
	/* Add code here */
}

void vApplicationIdleHook(void)
{
	// volatile int xFreeHeapSpace;

	/* This is just a trivial example of an idle hook.  It is called on each
	cycle of the idle task.  It must *NOT* attempt to block.  In this case the
	idle task just queries the amount of FreeRTOS heap that remains.  See the
	memory management section on the http://www.FreeRTOS.org web site for memory
	management options.  If there is a lot of heap memory free then the
	configTOTAL_HEAP_SIZE value in FreeRTOSConfig.h can be reduced to free up
	RAM. */
	// xFreeHeapSpace = xPortGetFreeHeapSize();

	/* Remove compiler warning about xFreeHeapSpace being set but never used. */
	// (void)xFreeHeapSpace;
}

void vApplicationStackOverflowHook(TaskHandle_t pxTask, char *pcTaskName)
{
	(void)pcTaskName;
	(void)pxTask;

	/* Run time stack overflow checking is performed if
	configCHECK_FOR_STACK_OVERFLOW is defined to 1 or 2.  This hook
	function is called if a stack overflow is detected. */
	taskDISABLE_INTERRUPTS();
	for( ;; );
}

void vApplicationGetIdleTaskMemory( StaticTask_t **ppxIdleTaskTCBBuffer, StackType_t **ppxIdleTaskStackBuffer, uint32_t *pulIdleTaskStackSize )
{
	/* If the buffers to be provided to the Idle task are declared inside this
	function then they must be declared static - otherwise they will be allocated on
	the stack and so not exists after this function exits. */
	static StaticTask_t xIdleTaskTCB;
	static StackType_t uxIdleTaskStack[configMINIMAL_STACK_SIZE];

	/* Pass out a pointer to the StaticTask_t structure in which the Idle task's
	state will be stored. */
	*ppxIdleTaskTCBBuffer = &xIdleTaskTCB;

	/* Pass out the array that will be used as the Idle task's stack. */
	*ppxIdleTaskStackBuffer = uxIdleTaskStack;

	/* Pass out the size of the array pointed to by *ppxIdleTaskStackBuffer.
	Note that, as the array is necessarily of type StackType_t,
	configMINIMAL_STACK_SIZE is specified in words, not bytes. */
	*pulIdleTaskStackSize = configMINIMAL_STACK_SIZE;
}

// void vApplicationGetTimerTaskMemory(StaticTask_t **ppxTimerTaskTCBBuffer, StackType_t **ppxTimerTaskStackBuffer, uint32_t *pulTimerTaskStackSize)
// {
// 	/* If the buffers to be provided to the Timer task are declared inside this
// 	function then they must be declared static - otherwise they will be allocated on
// 	the stack and so not exists after this function exits. */
// 	static StaticTask_t xTimerTaskTCB;
// 	static StackType_t uxTimerTaskStack[configTIMER_TASK_STACK_DEPTH];

// 	/* Pass out a pointer to the StaticTask_t structure in which the Timer
// 	task's state will be stored. */
// 	*ppxTimerTaskTCBBuffer = &xTimerTaskTCB;

// 	/* Pass out the array that will be used as the Timer task's stack. */
// 	*ppxTimerTaskStackBuffer = uxTimerTaskStack;

// 	/* Pass out the size of the array pointed to by *ppxTimerTaskStackBuffer.
// 	Note that, as the array is necessarily of type StackType_t,
// 	configMINIMAL_STACK_SIZE is specified in words, not bytes. */
// 	*pulTimerTaskStackSize = configTIMER_TASK_STACK_DEPTH;
// }

void vApplicationMallocFailedHook(void)
{
	/* Called if a call to pvPortMalloc() fails because there is insufficient
	free memory available in the FreeRTOS heap.  pvPortMalloc() is called
	internally by FreeRTOS API functions that create tasks, queues, software
	timers, and semaphores.  The size of the FreeRTOS heap is set by the
	configTOTAL_HEAP_SIZE configuration constant in FreeRTOSConfig.h. */
	taskDISABLE_INTERRUPTS();
	for (;;);
}

void _exit()
{
	for (;;);
}

void *memset(void *p, int c, size_t count)
{
	char *pc = (char*)p;
	while (count--)
	{
		*pc++ = c;
	}
}

__attribute__ ((persistent)) StaticTask_t xTimerTaskTCB = {0};
__attribute__ ((persistent)) StackType_t xTimerTaskStack[configMINIMAL_STACK_SIZE] = {0};

void vApplicationGetTimerTaskMemory(StaticTask_t** ppxTimerTaskPCBBuffer,
                                   StackType_t** ppxTimerTaskStackBuffer,
                                   uint32_t* pulTimerTaskStackSize)
{

    *ppxTimerTaskPCBBuffer = &xTimerTaskTCB;
    *ppxTimerTaskStackBuffer = xTimerTaskStack;
    *pulTimerTaskStackSize = configMINIMAL_STACK_SIZE;
}
