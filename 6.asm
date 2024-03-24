.text

.macro exit
li a7, 93
ecall
.end_macro

main:
	li	a0, 89
	call func_procent
	exit
	
delenie: # int delenie (int a0)
	addi	sp,sp -8
	sw	s0, 0(sp)
	sw	ra, 4(sp)
		
	li	t0, 10
	blt	a0, t0, vixod_rec
	srli	s0, a0, 2
	srli	a1, a0, 1

	recursive:
	mv	a0, a1
	
	call delenie

	sub	a0, s0, a0
	srli	a0, a0, 1
	j vixod2
	
	vixod_rec:
	li	a0, 0
	
	vixod2:
	lw	ra, 4(sp)
	lw	s0, 0(sp)
	addi	sp,sp, 8
	ret
	
func_delenie:
	addi	sp,sp -8
	sw	s1, 0(sp)
	sw	ra, 4(sp)
	addi	sp,sp -4
	sw	s2, 0(sp)
	mv 	s1, a0
	call delenie
	li	a1, 10
	mv 	s2, a0
	
	call multiply_hex
	ble	s1, s2, verno
	addi	s2, s2, -1
	
	verno:
	mv a0, s2
	
	lw	s2, 0(sp)
	addi	sp,sp, 4
	
	lw	ra, 4(sp)
	lw	s1, 0(sp)
	addi	sp,sp, 8
	ret
	
multiply_hex: # int multiply_hex (int a0, int a1)
	li	t2, 0
	li	t3, 31
	li 	t4, 0   # result
	
	for3:
	blt	t3, t2, end_for3
	
	srl	t5, a1, t3  # move number to counter
	andi	t6, t5, 1
	beqz	t6, nol
	sll	t1, a0, t3
	add	t4, t4, t1
	
	nol:
	addi	t3, t3, -1
	j for3
	
	end_for3:
	mv	a0, t4
	ret
	
func_procent: #int func_procent (int a0)
	addi	sp,sp -8
	sw	s2, 0(sp)
	sw	ra, 4(sp)
	mv	s2, a0
	call func_delenie
	li	a1, 10
	call multiply_hex
	sub	s2, s2, a0
	mv	a0, s2
	lw	ra, 4(sp)
	lw	s2, 0(sp)
	addi	sp,sp, 8
	ret