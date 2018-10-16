#include <system.h>
#include <serial.h>
#include "uart.h"

struct uart_port uart_config[] = {
	{
		.base		= UART0_BASE,
		.regshift	= UART0_REGSHIFT,
		.baud_rate	= UART0_BAUD_RATE,
		.divisor	= UART0_DIVISOR,
	},
/*
	{
		.base		= UART1_BASE,
		.regshift	= UART1_REGSHIFT,
		.baud_rate	= UART1_BAUD_RATE,
		.divisor	= UART1_DIVISOR,
	},
	{
		.base		= UART2_BASE,
		.regshift	= UART2_REGSHIFT,
		.baud_rate	= UART2_BAUD_RATE,
		.divisor	= UART2_DIVISOR,
	},
*/
};

static inline unsigned char serial_in(struct uart_port *port, int offset)
{
	return readb(port->base + (offset << port->regshift));
}

static inline void serial_out(struct uart_port *port, int offset, unsigned char c)
{
	writeb(c, port->base + (offset << port->regshift));
}

static inline void uart_wait_for_xmit(struct uart_port *port)
{
	unsigned char status;

	for (;;) {
		status = serial_in(port, UART_LSR);
		if ((status & (UART_LSR_TEMT | UART_LSR_THRE)) == (UART_LSR_TEMT | UART_LSR_THRE)) {
			return;
		}
	}
}

static inline void uart_wait_for_recv(struct uart_port *port)
{
	unsigned char status;

	for (;;) {
		status = serial_in(port, UART_LSR);
		if ((status & (UART_LSR_DR)) == (UART_LSR_DR)) {
			return;
		}
	}
}

unsigned char serial_tstc(int port)
{
	struct uart_port *p;

	if (port > NUM_UART_PORT)
		return 0;
	p = &uart_config[port];
	return ((serial_in(p, UART_LSR) & (UART_LSR_DR)) == (UART_LSR_DR));
}

unsigned char serial_getc(int port)
{
	struct uart_port *p;
	unsigned char c;

	if (port > NUM_UART_PORT)
		return 0;
	p = &uart_config[port];
	uart_wait_for_recv(p);
	c = serial_in(p, UART_RX);
	return c;
}

void serial_putc(int port, const char c)
{
	struct uart_port *p;
	unsigned long flags;
	unsigned long ier;

	if (port > NUM_UART_PORT)
		return;
	p = &uart_config[port];
	//flags = __irq_save();
	ier = serial_in(p, UART_IER);
	serial_out(p, UART_IER, 0);
	uart_wait_for_xmit(p);
	serial_out(p, UART_TX, c);
	if (c == '\n') {
		uart_wait_for_xmit(p);
		serial_out(p, UART_TX, '\r');
	}
	serial_out(p, UART_IER, ier);
	//__irq_restore(flags);
}

void serial_putdec(int port, unsigned long val)
{
	struct uart_port *p;
	unsigned long flags;
	unsigned long ier;
	char buffer[32];
	char *ptr = buffer;
	unsigned char c;

	if (port > NUM_UART_PORT)
		return;
	while (val || ptr == buffer) {
		*(ptr++) = val % 10;
		val = val / 10;
	}
	p = &uart_config[port];
	//flags = __irq_save();
	ier = serial_in(p, UART_IER);
	serial_out(p, UART_IER, 0);
	while (ptr != buffer) {
		c = '0' + *(--ptr);
		uart_wait_for_xmit(p);
		serial_out(p, UART_TX, c);
	}
	serial_out(p, UART_IER, ier);
	//__irq_restore(flags);
}

void serial_puthex(int port, unsigned long val, int digits)
{
	struct uart_port *p;
	unsigned long flags;
	unsigned long ier;
	int shift;
	unsigned char c;

	if (port > NUM_UART_PORT)
		return;
	if (digits == 0)
		return;
	if (digits > (sizeof(unsigned long) * 2))
		digits = sizeof(unsigned long) * 2;
	shift = (4 * digits) - 4;
	p = &uart_config[port];
	//flags = __irq_save();
	ier = serial_in(p, UART_IER);
	serial_out(p, UART_IER, 0);
	uart_wait_for_xmit(p);
	serial_out(p, UART_TX, '0');
	uart_wait_for_xmit(p);
	serial_out(p, UART_TX, 'X');
	while (shift >= 0) {
		c = (val >> shift) & 0xf;
		if (c >= 10) {
			c += 7;
		}
		c += '0';
		uart_wait_for_xmit(p);
		serial_out(p, UART_TX, c);
		shift -= 4;
	}
	serial_out(p, UART_IER, ier);
	//__irq_restore(flags);
}

void serial_puts(int port, const char *s)
{
	struct uart_port *p;
	unsigned long flags;
	unsigned long ier;
	unsigned char c;

	if (port > NUM_UART_PORT)
		return;
	p = &uart_config[port];
	//flags = __irq_save();
	ier = serial_in(p, UART_IER);
	serial_out(p, UART_IER, 0);
	while (*s) {
		uart_wait_for_xmit(p);
		c = *s;
		serial_out(p, UART_TX, c);
		if (c == '\n') {
			uart_wait_for_xmit(p);
			serial_out(p, UART_TX, '\r');
		}
		s++;
	}
	serial_out(p, UART_IER, ier);
	//__irq_restore(flags);
}

void serial_init(void)
{
	struct uart_port *port;
	int i, v;

	for (i = 0; i < NUM_UART_PORT; i++) {
		port = &uart_config[i];
		serial_out(port, UART_FCR,
			UART_FCR_ENABLE_FIFO |
			UART_FCR_CLEAR_RCVR |
			UART_FCR_CLEAR_XMIT |
			UART_FCR_TRIGGER_14);
		serial_out(port, UART_IER, 0);
		serial_out(port, UART_LCR,
			UART_LCR_WLEN8 & ~(UART_LCR_STOP | UART_LCR_PARITY));
		v = serial_in(port, UART_LCR);
		v |= UART_LCR_DLAB;
		serial_out(port, UART_LCR, v);
		serial_out(port, UART_DLL, port->divisor&0xff);
		serial_out(port, UART_DLM, (port->divisor>>8)&0xff);
		v &= ~(UART_LCR_DLAB);
		serial_out(port, UART_LCR, v);
	}
}

