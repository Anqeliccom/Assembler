.include "macros.asm"

main:
call read_decimal
mv s0, a0
mv s2, a1
call read_decimal
mv s1, a0
mv s3, a1

mv a0, s0
mv a1, s1
mv a2, s2
mv a3, s3
call sdiv

mv s1, a1
call print_decimal
li a0, '.'
print_ch
mv a0, s1
call print_decimal
exit

sdiv: #int sdiv(int a0, int a1, int a2, int a3)
	mv s2, a0
	mv s3, a1
	
	beqz	a2, first_is_pos
	neg	a0, a0
	beqz	a3, second_is_pos
	neg	a1, a1
	j second_is_pos
	
	first_is_pos:
	beqz	a3, second_is_pos
	neg	a1, a1
	j second_is_pos
	
	second_is_pos:
	bne	a2, a3, change_sign
	push ra
	call udiv
	pop ra
	ret
	
	change_sign:
	push ra
	call udiv
	pop ra
	neg	a0, a0
	ret
	
udiv: #int udiv(int a0, int a1) return:(int a0, int a1)
	addi	sp, sp -12
	sw	s0, 0(sp)
	sw	s1, 4(sp)
	sw	ra, 8(sp)
	
	li	t0, 0 # len of a1
	li	t1, 0 # counter
	li	t2, 31
	li	t4, 0
	li	t5, 0 # res of cur sub
	li	s0, 0 # answer(whole)
	li	s1, 0 # answer (remainder)
	li	a3, 0 # current dividend
	mv	a2, a1
	
	while3:
	beqz	a1, end_of_number
	srli	a1, a1, 1
	addi	t0, t0, 1
	j while3
	
	end_of_number:
	sub	t1, t2, t0
	sll	a2, a2, t1
	
	while4:
	li	t3, -1
	slli	s0, s0, 1
	sll	t3, t3, t1
	and	a3, a0, t3
	sub	t5, a3, a2
	blt	t5, t4, dodnt_sub
	sub	a0, a0, a2
	addi	s0, s0, 1
	
	dodnt_sub:
	srli	a2, a2, 1
	addi	t1, t1, -1
	blt	t1, t4, end_while4
	j while4
	
	end_while4:
	mv a1, a0
	mv a0, s0
	
	lw	ra, 8(sp)
	lw	s1, 4(sp)
	lw	s0, 0(sp)
	addi	sp, sp 12
	ret

read_decimal:
	addi	sp, sp -20
	sw	s0, 0(sp)
	sw	s1, 4(sp)
	sw	s3, 8(sp)
	sw	s4, 12(sp)
	sw	ra, 16(sp)

	li	s0, 0
	li	s1, 0 # previous
	li	s4, 0
	li	a0, 0
	li	a5, 0
	
	while:	
	read_ch
	li t0, 45
	beq	a0, t0, if1
	li	t0, 10
	beq	a0, t0, vixod
	li 	t0, 48
	bgtu 	t0, a0, is_not_number
	li 	t0, 57
	bgtu	a0, t0, is_not_number
	addi 	a0, a0, -48
	
	mv	s3, a0
	li	a0, 10
	mv	a1, s1
	call multiply_hex
	add	s0, a0, s3
	mv	s1, s0
	li	t5, 2147483647
	li	t6, -2147483647
	bgt	s1, t5, exit # overflow
	blt	s1, t6, exit # overflow
	j while
	
	if1:
	bnez	s0, is_not_number
	bnez	s4, is_not_number
	li s4, 1
	j while
	
	is_not_number:
	print_enter
	li 	t0, 10
	error "this is not a correct number"
	exit
	
	vixod:
	li	t1, 1
	beq	s4, t1, minus
	
	mv	a0, s0
	mv	a1, s4
	lw	ra, 16(sp)
	lw	s4, 12(sp)
	lw	s3, 8(sp)
	lw	s1, 4(sp)
	lw	s0, 0(sp)
	addi	sp, sp 20
	ret
	
	minus:
	xori	s0, s0, -1
	addi    s0, s0 1
	mv	a0, s0
	mv	a1, s4
	lw	ra, 16(sp)
	lw	s4, 12(sp)
	lw	s3, 8(sp)
	lw	s1, 4(sp)
	lw	s0, 0(sp)
	addi	sp, sp 20
	ret

	
print_decimal:

addi	sp, sp -12
sw	ra, 0(sp)
sw	s0, 4(sp)
sw	s1, 8(sp)
addi	sp, sp, -12
mv	s1, sp
mv	s0, a0
mv	t2, a0

srli	t2, t2, 31
beqz	t2, while2
li	a0, 45
print_ch
addi	s0,s0, -1
xori	a0, s0, -1

while2:
mv	s0, a0
call func_procent
addi	a0, a0, 48
sb	a0, 0(s1)
addi	s1, s1, 1
addi	a0, a0, -48

mv a0, s0
call	func_delenie
beq	a0, zero, vixod3
j while2

vixod3:
blt	s1, sp, vixod5
lb	a0, 0(s1)
print_ch
addi	s1, s1, -1
j vixod3

vixod5:
addi	sp, sp, 12
lw	s1, 8(sp)
lw	s0, 4(sp)
lw	ra, 0(sp)
addi	sp, sp, 12
ret

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
	bge	s1, a0, verno
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
	
exit:
syscall 93
