#ifndef _STDIO_H_
#define _STDIO_H_

#include <stdarg.h>
#include <sys/types.h>

#ifdef TINY_PRINTF
extern int sprintf(char *out, const char *format, ...);
extern int __vprintf(const char *fmt, va_list args);
#else
extern int snprintf (char *str, size_t count, const char *fmt, ...);
extern int vsnprintf (char *str, size_t count, const char *fmt, va_list arg);
#endif

/* stdin */
extern int console_getc(void);
extern int console_tstc(void);

/* stdout */
extern void console_putc(const char c);
extern void console_puts(const char *s);
extern void printf(const char *fmt, ...);
extern void vprintf(const char *fmt, va_list args);

extern void hang(void) __attribute__ ((noreturn));

#endif // _COMMON_H_
