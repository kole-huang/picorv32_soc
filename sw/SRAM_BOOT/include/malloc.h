#ifndef _MALLOC_H_
#define _MALLOC_H_

extern void malloc_init(unsigned int malloc_start_addr, unsigned int size);
extern void *malloc(size_t size);
extern void free(void *);
extern void *calloc(size_t nmemb, size_t size);
extern void *realloc(void *ptr, size_t size);

#endif
