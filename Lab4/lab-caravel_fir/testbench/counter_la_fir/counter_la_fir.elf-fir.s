	.file	"fir.c"
	.option nopic
	.attribute arch, "rv32i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
.Ltext0:
	.cfi_sections	.debug_frame
	.file 0 "/home/ubuntu/Desktop/2024_Fall_NTU_AAHLS/course-lab_4/lab-caravel_fir/testbench/counter_la_fir" "fir.c"
	.globl	taps
	.data
	.align	2
	.type	taps, @object
	.size	taps, 44
taps:
	.word	0
	.word	-10
	.word	-9
	.word	23
	.word	56
	.word	63
	.word	56
	.word	23
	.word	-9
	.word	-10
	.word	0
	.globl	outputsignal
	.bss
	.align	2
	.type	outputsignal, @object
	.size	outputsignal, 256
outputsignal:
	.zero	256
	.section	.mprjram,"ax",@progbits
	.align	2
	.globl	initfir
	.type	initfir, @function
initfir:
.LFB0:
	.file 1 "fir.c"
	.loc 1 4 61
	.cfi_startproc
	addi	sp,sp,-32
	.cfi_def_cfa_offset 32
	sw	s0,28(sp)
	.cfi_offset 8, -4
	addi	s0,sp,32
	.cfi_def_cfa 8, 0
	.loc 1 7 3
	li	a5,805306368
	addi	a5,a5,16
	.loc 1 7 36
	li	a4,64
	sw	a4,0(a5)
.LBB2:
	.loc 1 10 16
	sw	zero,-20(s0)
	.loc 1 10 2
	j	.L2
.L3:
	.loc 1 11 51 discriminator 3
	lui	a5,%hi(taps)
	addi	a4,a5,%lo(taps)
	lw	a5,-20(s0)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a3,0(a5)
	.loc 1 11 37 discriminator 3
	lw	a4,-20(s0)
	li	a5,201326592
	addi	a5,a5,16
	add	a5,a4,a5
	slli	a5,a5,2
	.loc 1 11 51 discriminator 3
	mv	a4,a3
	.loc 1 11 45 discriminator 3
	sw	a4,0(a5)
	.loc 1 10 32 discriminator 3
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L2:
	.loc 1 10 25 discriminator 1
	lw	a4,-20(s0)
	li	a5,10
	bleu	a4,a5,.L3
.LBE2:
	.loc 1 14 1
	nop
	nop
	lw	s0,28(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 32
	addi	sp,sp,32
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE0:
	.size	initfir, .-initfir
	.align	2
	.globl	fir_excute
	.type	fir_excute, @function
fir_excute:
.LFB1:
	.loc 1 16 64
	.cfi_startproc
	addi	sp,sp,-16
	.cfi_def_cfa_offset 16
	sw	s0,12(sp)
	sw	s1,8(sp)
	.cfi_offset 8, -4
	.cfi_offset 9, -8
	addi	s0,sp,16
	.cfi_def_cfa 8, 0
	.loc 1 20 3
	li	a5,637534208
	addi	a5,a5,12
	.loc 1 20 36
	li	a4,10813440
	sw	a4,0(a5)
	.loc 1 26 10
	li	a5,805306368
	.loc 1 26 43
	li	a4,1
	sw	a4,0(a5)
	.loc 1 28 26
	li	s1,0
	.loc 1 31 15
	j	.L5
.L6:
	.loc 1 32 12
	li	a5,805306368
	addi	a5,a5,128
	.loc 1 32 45
	mv	a4,s1
	sw	a4,0(a5)
	.loc 1 35 36
	li	a5,805306368
	addi	a5,a5,132
	lw	a5,0(a5)
	.loc 1 35 29
	mv	a2,s1
	.loc 1 35 36
	mv	a3,a5
	.loc 1 35 33
	lui	a5,%hi(outputsignal)
	addi	a4,a5,%lo(outputsignal)
	slli	a5,a2,2
	add	a5,a4,a5
	sw	a3,0(a5)
	.loc 1 36 19
	addi	a5,s1,1
	andi	s1,a5,0xff
.L5:
	.loc 1 31 18
	li	a5,63
	bleu	s1,a5,.L6
	.loc 1 42 10
	li	a5,805306368
	lw	a5,0(a5)
	.loc 1 45 57
	lui	a5,%hi(outputsignal)
	addi	a5,a5,%lo(outputsignal)
	lw	a5,252(a5)
	.loc 1 45 65
	slli	a4,a5,24
	.loc 1 45 71
	li	a5,5898240
	or	a4,a4,a5
	.loc 1 45 10
	li	a5,637534208
	addi	a5,a5,12
	.loc 1 45 43
	sw	a4,0(a5)
	.loc 1 47 9
	lui	a5,%hi(outputsignal)
	addi	a5,a5,%lo(outputsignal)
	.loc 1 48 1
	mv	a0,a5
	lw	s0,12(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 16
	lw	s1,8(sp)
	.cfi_restore 9
	addi	sp,sp,16
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE1:
	.size	fir_excute, .-fir_excute
	.text
.Letext0:
	.file 2 "fir.h"
	.file 3 "/opt/riscv/lib/gcc/riscv32-unknown-elf/12.1.0/include/stdint-gcc.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.4byte	0x114
	.2byte	0x5
	.byte	0x1
	.byte	0x4
	.4byte	.Ldebug_abbrev0
	.byte	0x7
	.4byte	.LASF15
	.byte	0x1d
	.4byte	.LASF0
	.4byte	.LASF1
	.4byte	.LLRL0
	.4byte	0
	.4byte	.Ldebug_line0
	.byte	0x2
	.4byte	0x3d
	.4byte	0x36
	.byte	0x3
	.4byte	0x36
	.byte	0xa
	.byte	0
	.byte	0x1
	.byte	0x4
	.byte	0x7
	.4byte	.LASF2
	.byte	0x8
	.byte	0x4
	.byte	0x5
	.string	"int"
	.byte	0x4
	.4byte	.LASF3
	.byte	0x14
	.4byte	0x26
	.byte	0x5
	.byte	0x3
	.4byte	taps
	.byte	0x2
	.4byte	0x3d
	.4byte	0x64
	.byte	0x3
	.4byte	0x36
	.byte	0x3f
	.byte	0
	.byte	0x4
	.4byte	.LASF4
	.byte	0x17
	.4byte	0x54
	.byte	0x5
	.byte	0x3
	.4byte	outputsignal
	.byte	0x1
	.byte	0x1
	.byte	0x6
	.4byte	.LASF5
	.byte	0x1
	.byte	0x2
	.byte	0x5
	.4byte	.LASF6
	.byte	0x1
	.byte	0x4
	.byte	0x5
	.4byte	.LASF7
	.byte	0x1
	.byte	0x8
	.byte	0x5
	.4byte	.LASF8
	.byte	0x5
	.4byte	.LASF11
	.byte	0x2e
	.byte	0x17
	.4byte	0x9b
	.byte	0x1
	.byte	0x1
	.byte	0x8
	.4byte	.LASF9
	.byte	0x1
	.byte	0x2
	.byte	0x7
	.4byte	.LASF10
	.byte	0x5
	.4byte	.LASF12
	.byte	0x34
	.byte	0x1b
	.4byte	0xb4
	.byte	0x1
	.byte	0x4
	.byte	0x7
	.4byte	.LASF13
	.byte	0x1
	.byte	0x8
	.byte	0x7
	.4byte	.LASF14
	.byte	0x9
	.4byte	.LASF16
	.byte	0x1
	.byte	0x10
	.byte	0x33
	.4byte	0xe8
	.4byte	.LFB1
	.4byte	.LFE1-.LFB1
	.byte	0x1
	.byte	0x9c
	.4byte	0xe8
	.byte	0x6
	.string	"t"
	.byte	0x1c
	.byte	0x1a
	.4byte	0x90
	.byte	0x1
	.byte	0x59
	.byte	0
	.byte	0xa
	.byte	0x4
	.4byte	0x3d
	.byte	0xb
	.4byte	.LASF17
	.byte	0x1
	.byte	0x4
	.byte	0x33
	.4byte	.LFB0
	.4byte	.LFE0-.LFB0
	.byte	0x1
	.byte	0x9c
	.byte	0xc
	.4byte	.LBB2
	.4byte	.LBE2-.LBB2
	.byte	0x6
	.string	"i"
	.byte	0xa
	.byte	0x10
	.4byte	0xa9
	.byte	0x2
	.byte	0x91
	.byte	0x6c
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.byte	0x1
	.byte	0x24
	.byte	0
	.byte	0xb
	.byte	0xb
	.byte	0x3e
	.byte	0xb
	.byte	0x3
	.byte	0xe
	.byte	0
	.byte	0
	.byte	0x2
	.byte	0x1
	.byte	0x1
	.byte	0x49
	.byte	0x13
	.byte	0x1
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0x3
	.byte	0x21
	.byte	0
	.byte	0x49
	.byte	0x13
	.byte	0x2f
	.byte	0xb
	.byte	0
	.byte	0
	.byte	0x4
	.byte	0x34
	.byte	0
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0x21
	.byte	0x2
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0x21
	.byte	0x5
	.byte	0x49
	.byte	0x13
	.byte	0x3f
	.byte	0x19
	.byte	0x2
	.byte	0x18
	.byte	0
	.byte	0
	.byte	0x5
	.byte	0x16
	.byte	0
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0x21
	.byte	0x3
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0x6
	.byte	0x34
	.byte	0
	.byte	0x3
	.byte	0x8
	.byte	0x3a
	.byte	0x21
	.byte	0x1
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0x2
	.byte	0x18
	.byte	0
	.byte	0
	.byte	0x7
	.byte	0x11
	.byte	0x1
	.byte	0x25
	.byte	0xe
	.byte	0x13
	.byte	0xb
	.byte	0x3
	.byte	0x1f
	.byte	0x1b
	.byte	0x1f
	.byte	0x55
	.byte	0x17
	.byte	0x11
	.byte	0x1
	.byte	0x10
	.byte	0x17
	.byte	0
	.byte	0
	.byte	0x8
	.byte	0x24
	.byte	0
	.byte	0xb
	.byte	0xb
	.byte	0x3e
	.byte	0xb
	.byte	0x3
	.byte	0x8
	.byte	0
	.byte	0
	.byte	0x9
	.byte	0x2e
	.byte	0x1
	.byte	0x3f
	.byte	0x19
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0x11
	.byte	0x1
	.byte	0x12
	.byte	0x6
	.byte	0x40
	.byte	0x18
	.byte	0x7a
	.byte	0x19
	.byte	0x1
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0xa
	.byte	0xf
	.byte	0
	.byte	0xb
	.byte	0xb
	.byte	0x49
	.byte	0x13
	.byte	0
	.byte	0
	.byte	0xb
	.byte	0x2e
	.byte	0x1
	.byte	0x3f
	.byte	0x19
	.byte	0x3
	.byte	0xe
	.byte	0x3a
	.byte	0xb
	.byte	0x3b
	.byte	0xb
	.byte	0x39
	.byte	0xb
	.byte	0x11
	.byte	0x1
	.byte	0x12
	.byte	0x6
	.byte	0x40
	.byte	0x18
	.byte	0x7a
	.byte	0x19
	.byte	0
	.byte	0
	.byte	0xc
	.byte	0xb
	.byte	0x1
	.byte	0x11
	.byte	0x1
	.byte	0x12
	.byte	0x6
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.4byte	0x24
	.2byte	0x2
	.4byte	.Ldebug_info0
	.byte	0x4
	.byte	0
	.2byte	0
	.2byte	0
	.4byte	.LFB0
	.4byte	.LFE0-.LFB0
	.4byte	.LFB1
	.4byte	.LFE1-.LFB1
	.4byte	0
	.4byte	0
	.section	.debug_rnglists,"",@progbits
.Ldebug_ranges0:
	.4byte	.Ldebug_ranges3-.Ldebug_ranges2
.Ldebug_ranges2:
	.2byte	0x5
	.byte	0x4
	.byte	0
	.4byte	0
.LLRL0:
	.byte	0x6
	.4byte	.LFB0
	.4byte	.LFE0
	.byte	0x6
	.4byte	.LFB1
	.4byte	.LFE1
	.byte	0
.Ldebug_ranges3:
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF8:
	.string	"long long int"
.LASF2:
	.string	"unsigned int"
.LASF3:
	.string	"taps"
.LASF4:
	.string	"outputsignal"
.LASF13:
	.string	"long unsigned int"
.LASF14:
	.string	"long long unsigned int"
.LASF11:
	.string	"uint8_t"
.LASF9:
	.string	"unsigned char"
.LASF17:
	.string	"initfir"
.LASF12:
	.string	"uint32_t"
.LASF7:
	.string	"long int"
.LASF10:
	.string	"short unsigned int"
.LASF5:
	.string	"signed char"
.LASF16:
	.string	"fir_excute"
.LASF6:
	.string	"short int"
.LASF15:
	.string	"GNU C17 12.1.0 -mabi=ilp32 -mtune=rocket -misa-spec=2.2 -march=rv32i -g -ffreestanding"
	.section	.debug_line_str,"MS",@progbits,1
.LASF0:
	.string	"fir.c"
.LASF1:
	.string	"/home/ubuntu/Desktop/2024_Fall_NTU_AAHLS/course-lab_4/lab-caravel_fir/testbench/counter_la_fir"
	.ident	"GCC: (g1ea978e3066) 12.1.0"
