#include <stdio.h>
#include <system.h>
#include <malloc.h>
#include <serial.h>
#include <irq.h>
#include <util.h>

const unsigned int sys_malloc_start = (const unsigned int)&__malloc_start;
const unsigned int sys_malloc_end = (const unsigned int)&__malloc_end;
const unsigned int sys_stack_top = (const unsigned int)&__stack_top;

void hal_init(void)
{
	serial_init();
        irq_init();
	malloc_init(sys_malloc_start, (sys_malloc_end - sys_malloc_start));
}

void hang(void)
{
	__irq_disable();
	console_puts("### ERROR ### Please RESET the board ###\n");
	for (;;);
}

void panic(const char *fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	vprintf(fmt, args);
	console_putc('\n');
	va_end(args);
        hang();
}

void __div0(void)
{
	console_puts("### WARNING ### Divide by Zero ###\n");
}

void abort(void)
{
	console_puts("### WARNING ### abort() ###\n");
}
