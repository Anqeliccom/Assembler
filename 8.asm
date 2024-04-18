.text

.macro error %str
.data
str2: .asciz %str
.text 
 la a0, str2
 li a7, 4
 ecall
.end_macro

.macro syscall %t
li	a7, %t
ecall
.end_macro

.macro read_ch
syscall 12
.end_macro

.macro print_ch
syscall 11
.end_macro

.macro exit
syscall 93
.end_macro

.macro print_enter
mv	a4, a0
li	a0, 10
syscall 11
mv	a0, a4
.end_macro

main:
call read_decimal
mv s1, a0
call read_decimal
mv s2, a0
mv a0, s1
mv a1, s2
call operation
call print_decimal
exit

operation: # void operation(int a0, int a1)
	mv 	a2, a0
	
	read_ch
	
	print_enter
	
	li 	t1, 43
	beq 	t1, a0, summa
	li 	t1, 45 
	beq 	t1, a0, sub_
	li 	t1, 38 
	error "invalid character"
	
	summa:
	add	a0, a2, a1
	ret
	sub_:
	sub 	a0, a2, a1
	ret

read_decimal: # int read_decimal()
	addi	sp, sp -12
	sw	s1, 0(sp)
	sw	s3, 4(sp)
	sw	ra, 8(sp)

	li	s1, 0 # предыдущее
	li	a0, 0
	li	a5, 0
	li	s0, 0
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
	lw	ra, 8(sp)
	lw	s3, 4(sp)
	lw	s1, 0(sp)
	addi	sp, sp 12
	ret
	
	minus:
	xori	s0, s0, -1
	addi    s0, s0 1
	mv	a0, s0
	lw	ra, 8(sp)
	lw	s3, 4(sp)
	lw	s1, 0(sp)
	addi	sp, sp 12
	ret

print_decimal: # int print_decimal(int a0)
	addi	sp, sp -12
	sw	ra, 0(sp)
	sw	s0, 4(sp)
	sw	s1, 8(sp)
	li	s1, 0
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
	addi sp, sp, -4
	sw	a0, 0(sp)
	addi	s1, s1, 1
	addi	a0, a0, -48

	mv a0, s0
	call	func_delenie
	beq	a0, zero, vixod3
	j while2

	vixod3:
	ble	s1, zero, vixod5
	lw	a0, 0(sp)
	addi sp, sp, 4
	print_ch
	addi	s1, s1, -1
	j vixod3

	vixod5:
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
