#ifndef _IRQ_H_
#define _IRQ_H_

#define NR_IRQS 32

#define IRQ_FLAGS_VALID		0x00000001
#define IRQ_FLAGS_ENABLE	0x00000002

struct irq_handler_t
{
	unsigned int flags;
	unsigned int irq;
	void (*handler)(void *);
	void *arg;
};

extern unsigned int __get_irq_mask(void);
extern unsigned int __irq_mask(unsigned int);
extern int irq_handler_add(unsigned int irq, void (*handler)(void *), void *arg);
extern int irq_handler_del(unsigned int irq);
extern int irq_enable(unsigned int irq);
extern int irq_disable(unsigned int irq);
extern void irq_init(void);

#endif /* _IRQ_H_ */
