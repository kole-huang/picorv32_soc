#ifndef _BOARD_H_
#define _BOARD_H_

/*------------------------------------------------------------------------------*/
/*  CONSTANTS                                                                   */
/*------------------------------------------------------------------------------*/
/* type bit */
#define _BIT0			(0x0001)
#define _BIT1			(0x0002)
#define _BIT2			(0x0004)
#define _BIT3			(0x0008)
#define _BIT4			(0x0010)
#define _BIT5			(0x0020)
#define _BIT6			(0x0040)
#define _BIT7			(0x0080)
#define _BIT8			(0x0100)
#define _BIT9			(0x0200)
#define _BIT10			(0x0400)
#define _BIT11			(0x0800)
#define _BIT12			(0x1000)
#define _BIT13			(0x2000)
#define _BIT14			(0x4000)
#define _BIT15			(0x8000)

/* timer interrupts per second */
#define HZ			10

#define MHZ			1000000

#define IN_CLK  		(10*MHZ)

/* #define ICACHE_ENABLE */
/* #define DCACHE_ENABLE */

#define NUM_UART_PORT		1
#define UART0_BASE		0x90000000
#define UART0_REGSHIFT		0
#define UART0_BAUD_RATE		38400
#define UART0_DIVISOR		(IN_CLK/(16*UART0_BAUD_RATE))

#define BOOT_SRAM_PHYS_ADDR	0x00000000
#define BOOT_SRAM_SIZE		0x80000
#define STACK_SIZE		(32*1024)
#define MALLOC_SIZE		(128*1024)

#endif
