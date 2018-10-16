// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include <stddef.h>
#include <stdio.h>
#include <system.h>
#include <exception.h>
#include <irq.h>

static struct irq_handler_t irq_handler_tbl[NR_IRQS];
static uint32_t timer_tick_cnt;
extern void vPortTickISR(void);

static void timer_isr(void *arg)
{
	timer_tick_cnt++;
	printf("[TIMER ISR] timer tick count:0x%x\n", timer_tick_cnt);
	vPortTickISR();
}

static void pic_unmask_irq(unsigned int irq)
{
	uint32_t regv;
	unsigned int flags;

	if ((irq & 0x7) || (irq >= NR_IRQS))
		return;
	flags = __irq_save();
	regv = __get_irq_mask();
	regv &= ~(0x00000001L << irq);
	__irq_mask(regv);
	__irq_restore(flags);
}

static void pic_mask_irq(unsigned int irq)
{
	uint32_t regv;
	unsigned int flags;

	if ((irq & 0x7) || (irq >=32))
		return;
	flags = __irq_save();
	regv = __get_irq_mask();
	regv |= (0x00000001L << irq);
	__irq_mask(regv);
	__irq_restore(flags);
}

static void pic_ack_irq(unsigned int irq)
{

}

static void pic_init(void)
{

}

static void handle_irq(struct irq_handler_t *h)
{
	h->handler(h->arg);
}

void do_irq(uint32_t *regs)
{
	uint32_t irq_status;
	int i;

	irq_status = regs[IRQ_STATUS/4];

	printf("[do_irq] IRQ STATUS: 0x%08x\n", irq_status);
	printf("[do_irq] RETURN PC:  0x%08x\n", regs[REG_PC/4]);

	if ((irq_status & 6) != 0) {
		uint32_t pc = (regs[0] & 1) ? regs[0] - 3 : regs[0] - 4;
		uint32_t instr = *(uint16_t*)pc;

		if ((instr & 3) == 3)
			instr = instr | (*(uint16_t*)(pc + 2)) << 16;

		// checking compressed isa q0 reg handling
		if (((instr & 3) != 3) != (regs[0] & 1)) {
			if ((instr & 3) == 3) {
				printf("Mismatch between q0 LSB and decoded instruction word! PC=0x%08x, q0=0x%08x, INSTR=0x%08x\n",
					pc, regs[0], instr);
			} else {
				printf("Mismatch between q0 LSB and decoded instruction word! PC=0x%08x, q0=0x%08x, INSTR=0x%04x\n",
					pc, regs[0], instr);
			}
			__asm__ volatile ("ebreak");
		}

		if ((irq_status & 2) != 0) {
			if (instr == 0x00100073 || instr == 0x9002) {
				printf("EBREAK instruction at 0x%08x\n", pc);
			} else {
				if ((instr & 3) == 3) {
					printf("Illegal Instruction at PC=0x%08x, INSTR=0x%08x\n", pc, instr);
				} else {
					printf("Illegal Instruction at PC=0x%08x, INSTR=0x%04x\n", pc, instr);
				}
			}
		}

		if ((irq_status & 4) != 0) {
			if ((instr & 3) == 3) {
				printf("Bus error in Instruction at PC=0x%08x, INSTR=0x%08x\n", pc, instr);
			} else {
				printf("Bus error in Instruction at PC=0x%08x, INSTR=0x%04x\n", pc, instr);
			}
		}

		for (int i = 0; i < 32; i++) {
			printf("REG[%d] = 0x%08x\n", i, regs[i]);
		}

		__asm__ volatile ("ebreak");
	}

	if ((irq_status & 1) != 0) {
		timer_isr(NULL);
	}

	i = 3;
	irq_status >>= 3;
	while (irq_status) {
		if (irq_status & 0x1UL) {
			if (irq_handler_tbl[i].flags & IRQ_FLAGS_ENABLE) {
				handle_irq(&irq_handler_tbl[i]);
			}
		}
		i++;
		irq_status >>= 1;
	}

	return;
}

static void dummy_irq_handler(void *arg)
{
	struct irq_handler_t *h = (struct irq_handler_t *)arg;
	printf("Unexpected irq: 0x%x\n", h->irq);
	hang();
}

int irq_handler_add(unsigned int irq, void (*handler)(void *), void *arg)
{
	if ((irq & 0x7) || (irq >= NR_IRQS)) {
		return -1;
	}
	if (handler == NULL) {
		return -1;
	}
	if (irq_handler_tbl[irq].handler != NULL) {
		return -1;
	}
	irq_handler_tbl[irq].flags |= IRQ_FLAGS_VALID;
	irq_handler_tbl[irq].irq = irq;
	irq_handler_tbl[irq].handler = handler;
	irq_handler_tbl[irq].arg = arg;
	return 0;
}

int irq_handler_del(unsigned int irq)
{
	if ((irq & 0x7) || (irq >= NR_IRQS)) {
		return -1;
	}
	irq_handler_tbl[irq].flags |= IRQ_FLAGS_VALID;
	irq_handler_tbl[irq].handler = dummy_irq_handler;
	irq_handler_tbl[irq].arg = &irq_handler_tbl[irq];
	return 0;
}

int irq_enable(unsigned int irq)
{
	if ((irq & 0x7) || (irq >= NR_IRQS)) {
		return -1;
	}
	if (irq_handler_tbl[irq].flags == 0x0) {
		return -1;
	}
	if (irq_handler_tbl[irq].flags & IRQ_FLAGS_VALID) {
		irq_handler_tbl[irq].flags |= IRQ_FLAGS_ENABLE;
	}
	pic_unmask_irq(irq);
	return 0;
}

int irq_disable(unsigned int irq)
{
	if ((irq & 0x7) || (irq >= NR_IRQS)) {
		return -1;
	}
	if (irq_handler_tbl[irq].flags == 0x0) {
		return -1;
	}
	if (irq_handler_tbl[irq].flags & IRQ_FLAGS_VALID) {
		irq_handler_tbl[irq].flags &= ~IRQ_FLAGS_ENABLE;
	}
	pic_mask_irq(irq);
	return 0;
}

void irq_init(void)
{
	int i;

	pic_init();

	for (i = 0; i < NR_IRQS; i++) {
		irq_handler_add(i, dummy_irq_handler, &irq_handler_tbl[i]);
	}
}

