/*
	FreeRTOS.org V5.1.2 - Copyright (C) 2003-2009 Richard Barry.

	This file is part of the FreeRTOS.org distribution.

	FreeRTOS.org is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	FreeRTOS.org is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with FreeRTOS.org; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

	A special exception to the GPL can be applied should you wish to distribute
	a combined work that includes FreeRTOS.org, without being obliged to provide
	the source code for any proprietary components.  See the licensing section 
	of http://www.FreeRTOS.org for full details of how and when the exception
	can be applied.

    ***************************************************************************
    ***************************************************************************
    *                                                                         *
    * Get the FreeRTOS eBook!  See http://www.FreeRTOS.org/Documentation      *
	*                                                                         *
	* This is a concise, step by step, 'hands on' guide that describes both   *
	* general multitasking concepts and FreeRTOS specifics. It presents and   *
	* explains numerous examples that are written using the FreeRTOS API.     *
	* Full source code for all the examples is provided in an accompanying    *
	* .zip file.                                                              *
    *                                                                         *
    ***************************************************************************
    ***************************************************************************

	Please ensure to read the configuration and relevant port sections of the
	online documentation.

	http://www.FreeRTOS.org - Documentation, latest information, license and 
	contact details.

	http://www.SafeRTOS.com - A version that is certified for use in safety 
	critical systems.

	http://www.OpenRTOS.com - Commercial support, development, porting, 
	licensing and training services.
*/

/* 
	NOTE : Tasks run in system mode and the scheduler runs in Supervisor mode.
	The processor MUST be in supervisor mode when vTaskStartScheduler is 
	called.  The demo applications included in the FreeRTOS.org download switch
	to supervisor mode prior to main being called.  If you are not using one of
	these demo application projects then ensure Supervisor mode is used.
*/


/*
 * Creates all the demo application tasks, then starts the scheduler.  The WEB
 * documentation provides more details of the demo application tasks.
 * 
 * Main.c also creates a task called "Check".  This only executes every three 
 * seconds but has the highest priority so is guaranteed to get processor time.  
 * Its main function is to check that all the other tasks are still operational.
 * Each task (other than the "flash" tasks) maintains a unique count that is 
 * incremented each time the task successfully completes its function.  Should 
 * any error occur within such a task the count is permanently halted.  The 
 * check task inspects the count of each task to ensure it has changed since
 * the last time the check task executed.  If all the count variables have 
 * changed all the tasks are still executing error free, and the check task
 * toggles the onboard LED.  Should any task contain an error at any time 
 * the LED toggle rate will change from 3 seconds to 500ms.
 *
 * To check the operation of the memory allocator the check task also 
 * dynamically creates a task before delaying, and deletes it again when it 
 * wakes.  If memory cannot be allocated for the new task the call to xTaskCreate
 * will fail and an error is signalled.  The dynamically created task itself
 * allocates and frees memory just to give the allocator a bit more exercise.
 *
 */

/* Standard includes. */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* Scheduler includes. */
#include "FreeRTOS.h"
#include "task.h"

/* Hardware specific definitions. */
#include "system.h"


/*-----------------------------------------------------------*/

/*
 * Configure the processor for use with the Olimex demo board.  This includes
 * setup for the I/O, system clock, and access timings.
 */
static void prvSetupHardware( void );

/*-----------------------------------------------------------*/

#if ( configUSE_TICK_HOOK == 1 )
void vApplicationTickHook( void )
{

}
#endif

static void vTestFun1( void *pvParameters )
{
	int counter = 0;
	int v;

	/* Stop warnings. */
	( void ) pvParameters;

	asm volatile("mv %0,x2" : "=r"(v));

	printf("Start thread1 vTestFun1(), SP:0x%x\n", v);

	for( ;; )
	{
		counter++;
#if 1
		printf("thread1 vTestFun1: counter = %d\n", counter);
#else
		if ((counter % 100) == 0) {
			printf("thread1 vTestFun1: counter = %d\n", counter);
		}
#endif
		vTaskDelay(1);
	}
	return;
}

static void vTestFun2( void *pvParameters )
{
	int counter = 0;
	int v;

	/* Stop warnings. */
	( void ) pvParameters;

	asm volatile("mv %0,x2" : "=r"(v));

	printf("Start thread2 vTestFun2(), SP:0x%x\n", v);

	for( ;; )
	{
		counter++;
#if 1
		printf("thread2 vTestFun2: counter = %d\n", counter);
#else
		if ((counter % 100) == 0) {
			printf("thread2 vTestFun2: counter = %d\n", counter);
		}
#endif
		vTaskDelay(1);
	}
	return;
}

static void vTestFun3( void *pvParameters )
{
	int counter = 0;
	int v;

	/* Stop warnings. */
	( void ) pvParameters;

	asm volatile("mv %0,x2" : "=r"(v));

	printf("Start thread3 vTestFun3(), SP:0x%x\n", v);

	for( ;; )
	{
		counter++;
#if 1
		printf("thread3 vTestFun3: counter = %d\n", counter);
#else
		if ((counter % 100) == 0) {
			printf("thread3 vTestFun3: counter = %d\n", counter);
		}
#endif
		vTaskDelay(1);
	}
	return;
}

static void vTestFun4( void *pvParameters )
{
	int counter = 0;
	int v;

	/* Stop warnings. */
	( void ) pvParameters;

	asm volatile("mv %0,x2" : "=r"(v));

	printf("Start thread4 vTestFun4(), SP:0x%x\n", v);

	for( ;; )
	{
		counter++;
#if 1
		printf("thread4 vTestFun4: counter = %d\n", counter);
#else
		if ((counter % 100) == 0) {
			printf("thread4 vTestFun4: counter = %d\n", counter);
		}
#endif
		vTaskDelay(1);
	}
	return;
}

/*
 * Starts all the other tasks, then starts the scheduler. 
 */
int main( void )
{
	printf("main()\n");

	/* Setup the hardware for use with the Olimex demo board. */
	prvSetupHardware();

	/* Create Tasks */
	xTaskCreate( vTestFun1, ( signed portCHAR * ) "TestFun1", configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY + 1, NULL );
	xTaskCreate( vTestFun2, ( signed portCHAR * ) "TestFun2", configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY + 1, NULL );
	xTaskCreate( vTestFun3, ( signed portCHAR * ) "TestFun3", configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY + 1, NULL );
	xTaskCreate( vTestFun4, ( signed portCHAR * ) "TestFun4", configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY + 1, NULL );

	/* Now all the tasks have been started - start the scheduler.

	NOTE : Tasks run in system mode and the scheduler runs in Supervisor mode.
	The processor MUST be in supervisor mode when vTaskStartScheduler is 
	called.  The demo applications included in the FreeRTOS.org download switch
	to supervisor mode prior to main being called.  If you are not using one of
	these demo application projects then ensure Supervisor mode is used here. */
	vTaskStartScheduler();
	panic("OS failed!!\n");

	/* Should never reach here! */
	return 0;
}

/*-----------------------------------------------------------*/

static void prvSetupHardware( void )
{

}

