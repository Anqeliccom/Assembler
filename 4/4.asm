.include "macros.asm"

main:
call read_bcd
mv s1, a0
call read_bcd
mv s2, a0
mv a0, s1
mv a1, s2
call select_operation
call print_bcd
exit


print_bcd: # int print_bcd(a0)
	li	t3, 24	# counter
	mv 	t5, a0
	srli	t2, a0, 28
	beqz	t2, for2

	li a0, '-'
	print_ch

	for2:
	blt 	t3, zero, end_for2 
	srl     t1, t5, t3
	andi	t1,t1, 15
	
	addi	a0, t1, 48
	print_ch
	addi 	t3, t3, -4
	j for2
	
	end_for2:
ret

select_operation: # int select_operation(int a0, a1)
	mv a2, a0
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


sum_: #int sum_(int a2!!!, a1)
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
	
sub_: #int sub_(int a2!!!, a1)
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
	addi	sp, sp -16
	sw	s1, 0(sp)
	sw	s2, 4(sp)
	sw	s3, 8(sp)
	sw	ra, 12(sp)
		
	li	t2, 10 #s1
	li	t3, 6 # number of blocks s4
	li 	s1, 0 #s2
	li	s2, 0 # counter s3
	li	s3, 0 #s5
	
	for:
	bgt 	s2, t3, end_for

	read_ch
	bnez	s2, not_first_symbol
	li	t0, '-'
	bne	a0, t0, not_first_symbol
	bnez	s3, not_first_symbol
	li	s3, 1
	slli	s3, s3, 28
	j for
	
	not_first_symbol:
	beq 	a0, t2, end_for

	call 	ascii_to_value
	slli	s1, s1, 4
	add	s1, s1, a0
	addi 	s2, s2, 1

	j for
	
	end_for:
	mv	a0, s1
	add	a0, a0, s3
	lw	ra, 12(sp)
	lw	s3, 8(sp)
	lw	s2, 4(sp)
	lw	s1, 0(sp)
	addi	sp, sp 16
ret
error "More than 7 characters"

ascii_to_value: #int ascii_to_value(int a0)
	li 	t0, 48
	bgtu 	t0, a0, is_not_number
	li 	t0, 57
	bgtu	a0, t0, is_not_number
	addi 	a0, a0, -48
	ret
	
	is_not_number:
	print_enter
	error "this is not a correct number"
	exit
return:
ret
