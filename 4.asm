.include "macros.asm"

main:
call read_bcd
mv s1, a0
call read_bcd
mv s2, a0
call read_sign
beqz a0, call2_sum
mv a0, s1
mv a1, s2
call sub_
j empty

call2_sum:
mv a0, s1
mv a1, s2
call sum_

empty:
call print_bcd
exit

print_bcd: # int print_bcd(a0)
	li	t3, 24	# counter
	li	t0, 15  # mask
	and	t2, a0, t0  # sign
	srli 	t5, a0, 4  # модуль
	
	li t0, 0xA
	beq t2, t0, for2

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

read_sign: # int read_sign()
	li	t0, 43
	li	t1, 45
	
	read_ch
	beq	a0, t0, call_sum_
	beq	a0, t1, call_sub_
	error "invalid character"
	
	call_sum_:
	li a0, 0
	ret
	
	call_sub_:
	li a0, 1
	ret
	
sum_: #int sum_(int a0, int a1)
	mv a2, a0			
	li t0, 0xF #mask		
	and a3, a1, t0 #sign		
	and a4, a2, t0 #sign		
	bne a3, a4, not_equal_sum
	srli a1, a1, 4			
	srli a2, a2, 4			
	print_enter
	
	mv a5, a3
	
	li	t2, 0	# shift counter
	li	t3, 28	# max shift
	li	t4, 0
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
	sll	a3, a3, t2
	add	a6, a6, a3
	addi	a4, a4, 1
	addi	t2, t2, 4
	j for4
	
	end_for4:
	srli	a4, a6, 28
	bnez	a4, overflow
	slli	a6, a6, 4
	add	a0, a6, a5
	ret
	
	not_equal_sum:
	li	t2, 0xA
	bne	a3, t2, continue
	li	t2, 0xB
	continue:
	srli	a1, a1, 4
	slli	a1, a1, 4
	add	a1, a1, t2
	mv	a0, a2
	push ra
	call sub_
	pop ra
	ret
	
sub_: #int sub_(int a0, int a1)
	mv a2, a0			
	li	t0, 0xF #mask		
	and a3, a1, t0 #sign		
	and a4, a2, t0 #sign		
	bne a3, a4, not_equal_sub
	srli a1, a1, 4			
	srli a2, a2, 4			
	print_enter
	
	mv a5, a3
	
	li 	t1, 0
	li	t2, 0	# shift counter
	li	t3, 28	# max shift
	li	t6, 15
	li	a6, 0	# addition result
	li	a4, 0	# unit (un)occupied
	
	bge	a2, a1, for5
	
	li	t1, 0xA
	bne	a5, t1, continue3
	li	t1, 0xB
	
	continue3:
	mv a5, t1
	
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
	slli	a6, a6, 4
	add	a0, a6, a5 
	ret
	
	not_equal_sub:
	li	t2, 0xA
	bne	a3, t2, continue2
	li	t2, 0xB
	continue2:
	srli	a1, a1, 4
	slli	a1, a1, 4
	add	a1, a1, t2
	mv	a0, a2
	push ra
	call sum_
	pop ra
	ret

read_bcd: # int read_bcd()
	addi	sp, sp -16
	sw	s1, 0(sp)
	sw	s2, 4(sp)
	sw	s3, 8(sp)
	sw	ra, 12(sp)
		
	li	t2, 10
	li	t3, 7 # number of blocks
	li 	s1, 0 # digits
	li	s2, 0 # counter
	li	s3, 0xA # number with sign
	
	for:
	bgt 	s2, t3, end_for

	read_ch
	bnez	s2, not_first_symbol
	li	t0, '-'
	bne	a0, t0, not_first_symbol
	li	t0, 0xA
	bne	s3, t0, not_first_symbol
	li	s3, 0xB
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
	slli	a0, a0, 4
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

overflow:
error "overflow"