#ifndef _SERIAL_H_
#define _SERIAL_H_

struct uart_port {
        unsigned int base;
        unsigned int regshift;
        unsigned int baud_rate;
        unsigned int divisor;
};

#define UART0_PORT_IDX	0
#define UART1_PORT_IDX	1
#define UART2_PORT_IDX	2

#define CONSOLE_UART_PORT_IDX UART0_PORT_IDX

extern void serial_init(void);
extern unsigned char serial_tstc(int port);
extern unsigned char serial_getc(int port);
extern void serial_putc(int port, const char c);
extern void serial_putdec(int port, unsigned int val);
extern void serial_puthex(int port, unsigned int val, int digits);
extern void serial_puts(int port, const char *s);

#endif // _SERIAL_H_

