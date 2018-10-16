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

/* Library includes. */

/* Scheduler includes. */
#include "FreeRTOS.h"
#include "task.h"

#include "exception.h"
#include "system.h"

/* Constants required to setup the initial stack. */

/* Constants required to handle critical sections. */
#define portNO_CRITICAL_NESTING 	( ( unsigned portLONG ) 0 )

/* Setup the TB to generate the tick interrupts. */
static void prvSetupTimerInterrupt( void );

/*
 * Initialise the stack of a task to look exactly as if a call to
 * portSAVE_CONTEXT had been called.
 *
 * See header file for description.
 */
// main() -> xTaskCreate() -> pxPortInitialiseStack()
// called from xTaskCreate()
// pxTopOfStack	- is a pointer to top of stack, stack space is allocated in xTaskCreate() via prvAllocateTCBAndStack()
// pxCode	- is an address of thread starting function
// pvParameters	- parameter passed to thread starting function
//
// the job of this function setups the initial stack frame before thread being run
// the thread is run by using l.rfe
portSTACK_TYPE *pxPortInitialiseStack( portSTACK_TYPE *pxTopOfStack, pdTASK_CODE pxCode, void *pvParameters )
{
	portSTACK_TYPE *orig_pxTopOfStack = pxTopOfStack;

	// fist, allocate a new stack frame
	pxTopOfStack -= CTX_FRAME_SIZE/4;

	// A0 is an argument register, use it to pass parameters
	*(pxTopOfStack + REG_A0/4) = ( portSTACK_TYPE ) pvParameters;

	// the address of thread starting function
	*(pxTopOfStack + REG_PC/4) = ( portSTACK_TYPE ) pxCode;

	// critical nesting variable
	*(pxTopOfStack + CRIT_NESTING/4) = ( portSTACK_TYPE ) portNO_CRITICAL_NESTING;

	// the task SP for the first time
	*(pxTopOfStack + REG_SP/4) = ( portSTACK_TYPE ) orig_pxTopOfStack;

	// return the new stack frame
	return pxTopOfStack;
}

// main() -> vTaskStartScheduler() -> xPortStartScheduler()
// called from vTaskStartScheduler()
portBASE_TYPE xPortStartScheduler( void )
{
	extern void vPortISRStartFirstTask( void );

	/* Start the timer that generates the tick ISR. Interrupts are disabled
	here already. */
	prvSetupTimerInterrupt();

	/* Start the first task. */
	vPortISRStartFirstTask();

	/* Should not get here! */
	return 0;
}

void vPortEndScheduler( void )
{
	/* It is unlikely that the picorv32 port will require this function as there
	is nothing to return to.  */
}

// main() -> vTaskStartScheduler() -> xPortStartScheduler() -> prvSetupTimerInterrupt()
static void prvSetupTimerInterrupt( void )
{
	// initialize tick timer
	timer_enable(configCPU_CLOCK_HZ/configTICK_RATE_HZ);
}
