	.file	"fir_control.c"
	.option nopic
	.attribute arch, "rv32i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.type	flush_cpu_icache, @function
flush_cpu_icache:
	addi	sp,sp,-16
	sw	s0,12(sp)
	addi	s0,sp,16
	nop
	lw	s0,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	flush_cpu_icache, .-flush_cpu_icache
	.align	2
	.type	flush_cpu_dcache, @function
flush_cpu_dcache:
	addi	sp,sp,-16
	sw	s0,12(sp)
	addi	s0,sp,16
	nop
	lw	s0,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	flush_cpu_dcache, .-flush_cpu_dcache
	.align	2
	.globl	putchar
	.type	putchar, @function
putchar:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	mv	a5,a0
	sb	a5,-17(s0)
	lbu	a4,-17(s0)
	li	a5,10
	bne	a4,a5,.L6
	li	a0,13
	call	putchar
.L6:
	nop
.L5:
	li	a5,-268410880
	addi	a5,a5,-2044
	lw	a4,0(a5)
	li	a5,1
	beq	a4,a5,.L5
	li	a5,-268410880
	addi	a5,a5,-2048
	lbu	a4,-17(s0)
	sw	a4,0(a5)
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	putchar, .-putchar
	.align	2
	.globl	print
	.type	print, @function
print:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	j	.L8
.L9:
	lw	a5,-20(s0)
	addi	a4,a5,1
	sw	a4,-20(s0)
	lbu	a5,0(a5)
	mv	a0,a5
	call	putchar
.L8:
	lw	a5,-20(s0)
	lbu	a5,0(a5)
	bne	a5,zero,.L9
	nop
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	print, .-print
	.section	.mprjram,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	li	a5,637534208
	addi	a5,a5,160
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,156
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,152
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,148
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,144
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,140
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,136
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,132
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,128
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,124
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,120
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,116
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,112
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,108
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,104
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	addi	a5,a5,100
	li	a4,8192
	addi	a4,a4,-2039
	sw	a4,0(a5)
	li	a5,637534208
	li	a4,1
	sw	a4,0(a5)
	nop
.L11:
	li	a5,637534208
	lw	a4,0(a5)
	li	a5,1
	beq	a4,a5,.L11
	call	initfir
	sw	zero,-20(s0)
	j	.L12
.L13:
	call	initfir
	call	fir_excute
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L12:
	lw	a4,-20(s0)
	li	a5,2
	ble	a4,a5,.L13
	nop
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.ident	"GCC: (g1ea978e3066) 12.1.0"
