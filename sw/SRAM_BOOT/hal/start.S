// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

// Only save registers in IRQ wrapper that are to be saved by the caller in
// the RISC-V ABI, with the excpetion of the stack pointer. The IRQ handler
// will save the rest if necessary. I.e. skip x3, x4, x8, x9, and x18-x27.
#undef ENABLE_FASTIRQ

#include <board.h>
#include <exception.h>
#include "custom_ops.S"

/*
 * ENABLE:
 *   EBREAK, ECALL, ILLEGAL INSN
 *   BUS Error
 * DISABLE:
 * All other IRQs are disabled
 */
#define DEFAULT_IRQ_MASK_VALUE		0xfffffff9
#define TIMER_IRQ_UNMASK_VALUE		0xfffffffe

	.section .vectors
	.extern do_irq

	.global reset_vec
	.type	reset_vec, @function
reset_vec:
	// no more than 16 bytes here !
	j	__start
	.size reset_vec, . - reset_vec

	.balign 16
	.type irq_vec, @function
irq_vec:
	// alloc stack space for ctx_regs
	addi	sp, sp, -CTX_FRAME_SIZE

	// save x1 into ctx_regs[REG_X1/4]
	// for later use as temp register
	sw	x1, REG_X1(sp)

	// save orig sp into ctx_regs[REG_SP/4]
	mv	x1, sp
	add	x1, x1, CTX_FRAME_SIZE
	sw	x1, REG_SP(sp)

	// q0: return address
	// save into ctx_regs[REG_PC/4]
	picorv32_getq_insn(x1, q0)
	sw	x1, REG_PC(sp)

	// q1: irq status
	// save into ctx_regs[IRQ_STATUS/4]
	picorv32_getq_insn(x1, q1)
	sw	x1, IRQ_STATUS(sp)

#ifdef ENABLE_FASTIRQ
	sw      x5,  REG_X5(sp)
	sw      x6,  REG_X6(sp)
	sw      x7,  REG_X7(sp)
	sw      x10, REG_X10(sp)
	sw      x11, REG_X11(sp)
	sw      x12, REG_X12(sp)
	sw      x13, REG_X13(sp)
	sw      x14, REG_X14(sp)
	sw      x15, REG_X15(sp)
	sw      x16, REG_X16(sp)
	sw      x17, REG_X17(sp)
	sw      x28, REG_X28(sp)
	sw      x29, REG_X29(sp)
	sw      x30, REG_X30(sp)
	sw      x31, REG_X31(sp)
#else
	// save x3 ~ x31 into ctx_regs[3] ~ ctx_regs[31]
	sw      x3,  REG_X3(sp)
	sw      x4,  REG_X4(sp)
	sw      x5,  REG_X5(sp)
	sw      x6,  REG_X6(sp)
	sw      x7,  REG_X7(sp)
	sw      x8,  REG_X8(sp)
	sw      x9,  REG_X9(sp)
	sw      x10, REG_X10(sp)
	sw      x11, REG_X11(sp)
	sw      x12, REG_X12(sp)
	sw      x13, REG_X13(sp)
	sw      x14, REG_X14(sp)
	sw      x15, REG_X15(sp)
	sw      x16, REG_X16(sp)
	sw      x17, REG_X17(sp)
	sw      x18, REG_X18(sp)
	sw      x19, REG_X19(sp)
	sw      x20, REG_X20(sp)
	sw      x21, REG_X21(sp)
	sw      x22, REG_X22(sp)
	sw      x23, REG_X23(sp)
	sw      x24, REG_X24(sp)
	sw      x25, REG_X25(sp)
	sw      x26, REG_X26(sp)
	sw      x27, REG_X27(sp)
	sw      x28, REG_X28(sp)
	sw      x29, REG_X29(sp)
	sw      x30, REG_X30(sp)
	sw      x31, REG_X31(sp)
#endif

#if 1
	li	x1,  0
	// don't touch x2, it is SP
	li	x3,  0
	li	x4,  0
	li	x5,  0
	li	x6,  0
	li	x7,  0
	li	x8,  0
	li	x9,  0
	li	x10, 0
	li	x11, 0
	li	x12, 0
	li	x13, 0
	li	x14, 0
	li	x15, 0
	li	x16, 0
	li	x17, 0
	li	x18, 0
	li	x19, 0
	li	x20, 0
	li	x21, 0
	li	x22, 0
	li	x23, 0
	li	x24, 0
	li	x25, 0
	li	x26, 0
	li	x27, 0
	li	x28, 0
	li	x29, 0
	li	x30, 0
	li	x31, 0
#endif

	// arg0 = address of ctx_regs
	mv	a0, sp

	// call to do_irq
	jal	ra, do_irq

	// restore PC
	lw	x1, REG_PC(sp)
	// save the PC into q0
	picorv32_setq_insn(q0, x1)

	// restore x1
	lw	x1, REG_X1(sp)

#ifdef ENABLE_FASTIRQ
	lw      x5,  REG_X5(sp)
	lw      x6,  REG_X6(sp)
	lw      x7,  REG_X7(sp)
	lw      x10, REG_X10(sp)
	lw      x11, REG_X11(sp)
	lw      x12, REG_X12(sp)
	lw      x13, REG_X13(sp)
	lw      x14, REG_X14(sp)
	lw      x15, REG_X15(sp)
	lw      x16, REG_X16(sp)
	lw      x17, REG_X17(sp)
	lw      x28, REG_X28(sp)
	lw      x29, REG_X29(sp)
	lw      x30, REG_X30(sp)
	lw      x31, REG_X31(sp)
#else
	// restore x3 ~ x31 from ctx_regs[3] ~ ctx_regs[31]
	lw      x3,  REG_X3(sp)
	lw      x4,  REG_X4(sp)
	lw      x5,  REG_X5(sp)
	lw      x6,  REG_X6(sp)
	lw      x7,  REG_X7(sp)
	lw      x8,  REG_X8(sp)
	lw      x9,  REG_X9(sp)
	lw      x10, REG_X10(sp)
	lw      x11, REG_X11(sp)
	lw      x12, REG_X12(sp)
	lw      x13, REG_X13(sp)
	lw      x14, REG_X14(sp)
	lw      x15, REG_X15(sp)
	lw      x16, REG_X16(sp)
	lw      x17, REG_X17(sp)
	lw      x18, REG_X18(sp)
	lw      x19, REG_X19(sp)
	lw      x20, REG_X20(sp)
	lw      x21, REG_X21(sp)
	lw      x22, REG_X22(sp)
	lw      x23, REG_X23(sp)
	lw      x24, REG_X24(sp)
	lw      x25, REG_X25(sp)
	lw      x26, REG_X26(sp)
	lw      x27, REG_X27(sp)
	lw      x28, REG_X28(sp)
	lw      x29, REG_X29(sp)
	lw      x30, REG_X30(sp)
	lw      x31, REG_X31(sp)
#endif

	// restore SP
	lw	sp, REG_SP(sp)

	// return to task before interrupt
	picorv32_retirq_insn()

	.balign 16
	.section .text
	.type __start, @function
__start:
	li	x1,  0
	li	x2,  0
	li	x3,  0
	li	x4,  0
	li	x5,  0
	li	x6,  0
	li	x7,  0
	li	x8,  0
	li	x9,  0
	li	x10, 0
	li	x11, 0
	li	x12, 0
	li	x13, 0
	li	x14, 0
	li	x15, 0
	li	x16, 0
	li	x17, 0
	li	x18, 0
	li	x19, 0
	li	x20, 0
	li	x21, 0
	li	x22, 0
	li	x23, 0
	li	x24, 0
	li	x25, 0
	li	x26, 0
	li	x27, 0
	li	x28, 0
	li	x29, 0
	li	x30, 0
	li	x31, 0

	# initialize global pointer
	.option push
	.option norelax
	lui	gp, %hi(__gp)
	addi	gp, gp, %lo(__gp)
	addi	tp, gp, 0
	.option pop

clear_bss:
	lui	t0, %hi(__bss_start)
	addi	t0, t0, %lo(__bss_start)
	lui	t1, %hi(__bss_end)
	addi	t1, t1, %lo(__bss_end)
#if 1
	// t0 >= t1, jump to setup_stack
	bgeu	t0, t1, setup_stack
#else
	// t1 <= t0, jump to setup_stack
	bleu	t1, t0, setup_stack
#endif
	li	t2, 0
1:
	sw	t2, 0x0(t0)
	addi	t0, t0, 4
	bne	t0, t1, 1b

setup_stack:
	lui	sp, %hi(__stack_top)
	addi	sp, sp, %lo(__stack_top)

	lui	t0, %hi(DEFAULT_IRQ_MASK_VALUE)
	addi	t0, t0, %lo(DEFAULT_IRQ_MASK_VALUE)
	picorv32_maskirq_insn(zero, t0)

	picorv32_setq_insn(q0, zero)
	picorv32_setq_insn(q1, zero)
	picorv32_setq_insn(q2, zero)
	picorv32_setq_insn(q3, zero)

	jal	ra, hal_init

	// jump to C main
	j	main

	.global __irq_save
	.type	__irq_save, @function
__irq_save:
	li	a0, 0
	picorv32_ctlirq_insn(a0, a0)
	ret
	.size	__irq_save, . - __irq_save

	.global __irq_restore
	.type	__irq_restore, @function
__irq_restore:
	picorv32_ctlirq_insn(zero, a0)
	ret
	.size	__irq_restore, . - __irq_restore

	.global __irq_enable
	.type	__irq_enable, @function
__irq_enable:
	li	t0, 1
	picorv32_ctlirq_insn(zero, t0)
	ret
	.size	__irq_enable, . - __irq_enable

	.global __irq_disable
	.type	__irq_disable, @function
__irq_disable:
	li	t0, 0
	picorv32_ctlirq_insn(zero, t0)
	ret
	.size	__irq_disable, . - __irq_disable

	.global __irq_mask
	.type	__irq_mask, @function
__irq_mask:
	picorv32_maskirq_insn(a0, a0)
	ret
	.size	__irq_mask, . - __irq_mask

	.global __get_irq_mask
	.type	__get_irq_mask, @function
__get_irq_mask:
	lui	t0, %hi(DEFAULT_IRQ_MASK_VALUE)
	addi	t0, t0, %lo(DEFAULT_IRQ_MASK_VALUE)
	picorv32_maskirq_insn(a0, t0)
	mv	t0, a0
	picorv32_maskirq_insn(zero, t0)
	ret
	.size	__get_irq_mask, . - __get_irq_mask

	.global timer_enable
	.type	timer_enable, @function
timer_enable:
	// disable irq
	li	t0, 0
	picorv32_ctlirq_insn(t0, t0)
        // get the current irq mask value
        lui     t1, %hi(DEFAULT_IRQ_MASK_VALUE)
        addi    t1, t1, %lo(DEFAULT_IRQ_MASK_VALUE)
        picorv32_maskirq_insn(t1, t1)
	// config timer, a0 contains timer tick value
	picorv32_timer_insn(zero, a0)
	// enable timer irq
	lui	t2, %hi(TIMER_IRQ_UNMASK_VALUE)
	addi	t2, t2, %lo(TIMER_IRQ_UNMASK_VALUE)
	and	t1, t1, t2
	picorv32_maskirq_insn(zero, t1)
	picorv32_ctlirq_insn(zero, t0)
	ret
	.size timer_enable, . - timer_enable

