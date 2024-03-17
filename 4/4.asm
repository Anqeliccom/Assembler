.include "macros.asm"

main:
call read_bcd
mv s1, a0
call read_bcd
mv s2, a0
mv a0, s1
mv a1, s2
call operation
call print_bcd
exit

plus_minus:
	mv	a1, a0
	li	a0, 45
	print_ch
	mv	a0, a1
	ret

print_bcd: # int print_bcd(a0)
	li	t3, 24	# counter
	li	t4, 0	# number of blocks
	mv 	t5, a0
	srli	t2, a0, 28
	beqz	t2, for2
	mv t0, a0
	li a0, '-'
	print_ch
	mv a0, t0
	for2:
	blt 	t3, t4, end_for2
	srl     t1, t5, t3
	andi	t1,t1, 15
	
	addi	a0, t1, 48
	print_ch
	addi 	t3, t3, -4
	j for2
	
	end_for2:
ret

operation: # void operation(int a0, int a1, int a3, a4)
	mv 	a2, a0
	srli a3, a0, 28
	srli a4, a1, 28
	slli a1, a1, 4
	slli a2, a2, 4
	srli a1, a1, 4
	srli a2, a2, 4
	push ra
	read_ch
	print_enter
	li	t1, 43
	li	t2, 45
	
	# odin_odin
	beqz	a3, nol_odin # nol_nol
	beqz	a4, odin_nol
	
		beq	a0, t1, if1_1
		beq	a0, t2, if1_2
		error "invalid character"
		if1_2:
		mv	t3, a2
		mv	a2, a1
		mv	a1, t3
		call	sub_
		pop ra
		ret

		if1_1:
		call sum_ # (a2, a10)
		li t1, 1
		slli t1, t1, 28
		add a0, a0, t1
		pop ra
		ret
	
	odin_nol:
		beq	a0, t1, if1_2
		beq	a0, t2, if1_1
		error "invalid character"
		exit
			
	nol_odin:
		beqz	a4, nol_nol
		beq	a0, t1, if2_2
		beq	a0, t2, if2_1
		error "invalid character"
		if2_2:
		call sub_
		pop ra
		ret
		if2_1:
		call sum_
		pop ra
		ret
	
	nol_nol:
		beq	a0, t1, sum_
		beq	a0, t2, sub_
		error "invalid character"
		ret

	error "invalid character"

	sum_:
	li	t2, 0	# shift counter
	li	t3, 28	# max shift
	li	t6, 10
	li	a6, 0	# addition result
	li	a4, 0	# (un)added unit
	
	for4:
	bgt	t2, t3, end_for4
	srl	t4, a2, t2
	andi 	t4, t4, 15
	
	srl	t5, a1, t2
	andi 	t5, t5, 15	
	
	add 	a3, t4, t5
	add	a3, a3, a4
	li 	a4, 0
	bleu	t6, a3, bol_des
	
	sll	a3, a3, t2
	add	a6, a6, a3
	addi	t2, t2, 4
	j for4
	
	bol_des:
	addi	a3, a3, -10
	sll	a3,a3,t2
	add	a6, a6, a3
	addi	a4, a4, 1
	addi	t2, t2, 4
	j for4
	
	end_for4:
	mv a0, a6
	ret
	
	sub_:
	li 	t1, 0
	li	t2, 0	# shift counter
	li	t3, 28	# max shift
	li	t6, 15
	li	a6, 0	# addition result
	li	a4, 0	# unit (un)occupied
	
	bge	a2, a1, for5
	mv	t1, a1
	mv	a1, a2
	mv	a2, t1
	li	t1, 1
	slli	t1, t1, 28
	
	for5:
	bgt	t2, t3, end_for5
	srl	t4, a2, t2
	andi 	t4, t4, 15
	
	srl	t5, a1, t2
	andi 	t5, t5, 15	
	
	sub 	a3, t4, t5
	sub	a3, a3, a4
	li 	a4, 0
	bgtu	a3, t6, bol_pyat
	
	sll	a3, a3, t2
	add	a6, a6, a3
	addi	t2, t2, 4
	j for5
	
	bol_pyat:
	addi	a3, a3, 10
	sll	a3, a3, t2
	add	a6, a6, a3
	addi	a4, a4, 1
	addi	t2, t2, 4
	j for5
	
	end_for5:
	mv a0, a6
	add	a0, a0, t1
	ret

read_bcd: # int read_bcd()
	addi	sp, sp -20
	sw	s1, 0(sp)
	sw	s2, 4(sp)
	sw	s3, 8(sp)
	sw	s4, 12(sp)
	sw	ra, 16(sp)
		
	li	s1, 10
	li 	s2, 0
	li	s3, 0 # counter
	li	s4, 6 # number of blocks
	li	t6, 0
	
	for:
	bgt 	s3, s4, end_for

	read_ch
	bnez	s3, not_first_symbol
	li	t0, '-'
	bne	a0, t0, not_first_symbol
	bnez	t6, not_first_symbol
	li	t6, 1
	slli	t6, t6, 28
	j for
	
	
	
	not_first_symbol:
	beq 	a0, s1, end_for

	call 	read
	slli	s2, s2, 4
	add	s2, s2, a0
	addi 	s3, s3, 1

	j for
	
	end_for:
	mv	a0, s2
	add	a0, a0, t6
	lw	ra, 16(sp)
	lw	s4, 12(sp)
	lw	s3, 8(sp)
	lw	s2, 4(sp)
	lw	s1, 0(sp)
	addi	sp, sp 20
ret
error "More than 7 characters"

read: #int read(int a0)
	li 	t0, 48
	bgtu 	t0, a0, is_not_number
	li 	t0, 57
	bgtu	a0, t0, is_not_number
	addi 	a2, a0, -48
	j endif
	
	is_not_number:
	print_enter
	li 	t0, 10
	error "this is not a correct number"
	exit
	
	endif:	
	mv a0, a2
return:
ret
