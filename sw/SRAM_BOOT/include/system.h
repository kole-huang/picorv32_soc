#ifndef _SYSTEM_H_
#define _SYSTEM_H_

#include "board.h"

#define readb(addr)		(*(volatile unsigned char *) (addr))
#define readw(addr)		(*(volatile unsigned short *) (addr))
#define readl(addr)		(*(volatile unsigned int *) (addr))

#define writeb(b,addr)		((*(volatile unsigned char *) (addr)) = (b))
#define writew(b,addr)		((*(volatile unsigned short *) (addr)) = (b))
#define writel(b,addr)		((*(volatile unsigned int *) (addr)) = (b))

/* Memory bariers */
#define barrier()		__asm__ __volatile__("": : :"memory")
#define mb()			barrier()
#define rmb()			mb()
#define wmb()			mb()
#define read_barrier_depends()	do { } while(0)
#define set_mb(var, value)	do { var = value; mb(); } while (0)
#define set_wmb(var, value)	do { var = value; wmb(); } while (0)

#define nop()			__asm__ __volatile__ ("":::"memory")

// disalbe irq and
// 1. return 1: irq is on before
// 2. return 0: irq is off before
extern unsigned int __irq_save(void);
// flags: 0 => disable irq
// flags: 1 => enable irq
extern void __irq_restore(unsigned int flags);

extern void __irq_disable(void);
extern void __irq_enable(void);

extern const unsigned int __malloc_start;
extern const unsigned int __malloc_end;
extern const unsigned int __stack_top;
extern const unsigned int sys_malloc_start;
extern const unsigned int sys_stack_top;

extern void hal_init(void);

extern void timer_enable(unsigned int);
extern unsigned int get_timer_tick(void);

#define BUG() \
do { \
	printf("BUG: failure at %s:%d/%s()!\n", __FILE__, __LINE__, __FUNCTION__); \
	panic("BUG!"); \
} while (0)

#define BUG_ON(condition) \
do { if (unlikely((condition)!=0)) BUG(); } while(0)

extern void panic(const char *fmt, ...);
extern void hang(void) __attribute__ ((noreturn));

#endif // _SYSTEM_H_
