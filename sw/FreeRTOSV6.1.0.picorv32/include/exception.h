#ifndef _EXCEPTION_H_
#define _EXCEPTION_H_

#ifndef __ASSEMBLY__
struct ctx_regs_t {
	unsigned int regs[32];
	unsigned int crit_nesting;
	unsigned int irq_status;
	unsigned int dummy[2];
};
#endif /* __ASSEMBLY__ */

#define CTX_FRAME_SIZE (32+128) /* sizeof(struct ctx_regs_t) */

#define REG_PC  (0x0)
#define REG_X1  (0x4)
#define REG_X2  (0x8)
#define REG_X3  (0xc)
#define REG_X4  (0x10)
#define REG_X5  (0x14)
#define REG_X6  (0x18)
#define REG_X7  (0x1c)
#define REG_X8  (0x20)
#define REG_X9  (0x24)
#define REG_X10 (0x28)
#define REG_X11 (0x2c)
#define REG_X12 (0x30)
#define REG_X13 (0x34)
#define REG_X14 (0x38)
#define REG_X15 (0x3c)
#define REG_X16 (0x40)
#define REG_X17 (0x44)
#define REG_X18 (0x48)
#define REG_X19 (0x4c)
#define REG_X20 (0x50)
#define REG_X21 (0x54)
#define REG_X22 (0x58)
#define REG_X23 (0x5c)
#define REG_X24 (0x60)
#define REG_X25 (0x64)
#define REG_X26 (0x68)
#define REG_X27 (0x6c)
#define REG_X28 (0x70)
#define REG_X29 (0x74)
#define REG_X30 (0x78)
#define REG_X31 (0x7c)
#define CRIT_NESTING (0x80)
#define IRQ_STATUS (0x84)

#define REG_RA  REG_X1
#define REG_SP  REG_X2
#define REG_GP  REG_X3
#define REG_TP  REG_X4
#define REG_T0  REG_X5
#define REG_T1  REG_X6
#define REG_T2  REG_X7
#define REG_S0  REG_X8
#define REG_S1  REG_X9
#define REG_A0  REG_X10
#define REG_A1  REG_X11
#define REG_A2  REG_X12
#define REG_A3  REG_X13
#define REG_A4  REG_X14
#define REG_A5  REG_X15
#define REG_A6  REG_X16
#define REG_A7  REG_X17
#define REG_S2  REG_X18
#define REG_S3  REG_X19
#define REG_S4  REG_X20
#define REG_S5  REG_X21
#define REG_S6  REG_X22
#define REG_S7  REG_X23
#define REG_S8  REG_X24
#define REG_S9  REG_X25
#define REG_S10 REG_X26
#define REG_S11 REG_X27
#define REG_T3  REG_X28
#define REG_T4  REG_X29
#define REG_T5  REG_X30
#define REG_T6  REG_X31

#endif /* _EXCEPTION_H_ */
