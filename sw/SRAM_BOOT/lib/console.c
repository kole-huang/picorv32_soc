#include <stdarg.h>
#include <stdio.h>
#include <system.h>
#include <serial.h>

int console_getc(void)
{
	return serial_getc(CONSOLE_UART_PORT_IDX);
}

int console_tstc(void)
{
	return serial_tstc(CONSOLE_UART_PORT_IDX);
}

void console_putc(const char c)
{
	serial_putc(CONSOLE_UART_PORT_IDX, c);
}

void console_puts(const char *s)
{
	serial_puts(CONSOLE_UART_PORT_IDX, s);
}

#if 0
void vprintf(const char *fmt, va_list args)
{
	__vprintf(fmt, args);
}
#endif
