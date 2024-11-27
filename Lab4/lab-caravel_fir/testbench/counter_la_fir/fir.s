	.file	"fir.c"
	.option nopic
	.attribute arch, "rv32i2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
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
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	li	a5,805306368
	addi	a5,a5,16
	li	a4,64
	sw	a4,0(a5)
	sw	zero,-20(s0)
	j	.L2
.L3:
	lui	a5,%hi(taps)
	addi	a4,a5,%lo(taps)
	lw	a5,-20(s0)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a3,0(a5)
	lw	a4,-20(s0)
	li	a5,201326592
	addi	a5,a5,16
	add	a5,a4,a5
	slli	a5,a5,2
	mv	a4,a3
	sw	a4,0(a5)
	lw	a5,-20(s0)
	addi	a5,a5,1
	sw	a5,-20(s0)
.L2:
	lw	a4,-20(s0)
	li	a5,10
	bleu	a4,a5,.L3
	nop
	nop
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	initfir, .-initfir
	.align	2
	.globl	fir_excute
	.type	fir_excute, @function
fir_excute:
    addi    sp, sp, -16
    sw      s0, 12(sp)
    sw      s1, 8(sp)
    addi    s0, sp, 16

    # 初始化數據，避免重複訪問
    li      a5, 637534220        # 計算 reg_fir_coeff 的偏移地址
    li      a4, 10813440
    sw      a4, 0(a5)

    li      a5, 805306368
    li      a4, 1
    sw      a4, 0(a5)            # 啟動 FIR 模組

    # 初始化 s1 作為計數器
    li      s1, 0

    # 計算 outputsignal 的基地址並保存
    lui     a6, %hi(outputsignal)
    addi    a6, a6, %lo(outputsignal)

.L6:
    # 寫入數據到 DataRAM，並從寄存器中讀取數據
    li      a5, 805306496        # 計算 reg_fir_x_in 地址
    mv      a4, s1
    sw      a4, 0(a5)

    # 等待 sm_valid 確認數據已就緒
    li      a5, 805306500        # 計算 reg_fir_y_out 地址
    lw      a3, 0(a5)            # 讀取 FIR 模組的輸出

    # 計算 outputsignal 中的目標地址
    slli    a4, s1, 2            # 計算輸出數組的偏移地址
    add     a5, a6, a4
    sw      a3, 0(a5)

    # 增加計數器並檢查是否超過邊界
    addi    a5, s1, 1
    andi    s1, a5, 0xff
    li      a5, 63
    bleu    s1, a5, .L6

    # 結束處理
    li      a5, 805306368        # 計算 reg_fir_ap_ctrl 地址
    lw      a5, 0(a5)

    # 讀取最終輸出信號
    lw      a5, 252(a6)          # 讀取最後的輸出信號
    slli    a4, a5, 24           # 左移以生成最終數據
    li      a5, 5898240
    or      a4, a4, a5

    li      a5, 637534220
    sw      a4, 0(a5)            # 存儲最終結果

    # 結束函數
    mv      a0, a6               # 將 outputsignal 的基地址返回

    lw      s0, 12(sp)
    lw      s1, 8(sp)
    addi    sp, sp, 16
    jr      ra

	jr	ra
	.size	fir_excute, .-fir_excute
	.ident	"GCC: (g1ea978e3066) 12.1.0"
