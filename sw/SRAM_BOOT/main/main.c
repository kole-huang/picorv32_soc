#include <stdio.h>
#include <malloc.h>
#include <system.h>
#include <string.h>
#include <serial.h>
#include <irq.h>

void main(void)
{
	unsigned int v;
	unsigned int flags;

	printf("picorv32 main()\n");
	__irq_enable();
	v = 1000;
	while (v--) {
		printf("picorv32 echo...\n");
	}
	printf("quit\n");
}

