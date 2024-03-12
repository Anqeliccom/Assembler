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
call read_hexes
mv s1, a0
call read_hexes
mv s2, a0
mv a0, s1
mv a1, s2
call operation
call print_hexes
exit


print_hexes: # int read_hexes()
	li	t3, 28	# counter
	li	t4, 0	# number of blocks
	mv 	t5, a0
	li 	t2, 10
	
	for2:
	blt 	t3, t4, end_for2
	srl     t1, t5, t3
	andi	t1,t1, 15
	bge	t1, t2, print_char
	
	addi	a0, t1, 48
	print_ch
	addi 	t3, t3, -4
	j for2
	
	print_char:
	addi	a0, t1, 55
	print_ch
	addi 	t3, t3, -4
	j for2
	
	end_for2:
ret

operation: # void operation(int a0, int a1)
	mv 	a2, a0
	
	read_ch
	
	print_enter
	
	li 	t1, 43
	beq 	t1, a0, summa
	li 	t1, 45 
	beq 	t1, a0, sub_
	li 	t1, 38 
	beq 	t1, a0, and_
	li 	t1, 124 
	beq 	t1, a0, or_
	error "invalid character"
	
	summa:
	add	a0, a2, a1
	ret
	sub_:
	sub 	a0, a2, a1
	ret
	and_:
	and 	a0, a2, a1
	ret
	or_:
	or 	a0, a2, a1
	ret

read_hexes: # int read_hexes()
	addi	sp, sp -20
	sw	s1, 0(sp)
	sw	s2, 4(sp)
	sw	s3, 8(sp)
	sw	s4, 12(sp)
	sw	ra, 16(sp)
		
	li	s1, 10
	li 	s2, 0
	li	s3, 0 # counter
	li	s4, 7 # number of blocks
	
	for:
	bgt 	s3, s4, end_for
	read_ch
	beq 	a0, s1, end_for

	call 	read_hex
	slli	s2, s2, 4
	add	s2, s2, a0
	addi 	s3, s3, 1

	j for
	
	end_for:
	mv	a0, s2
	lw	ra, 16(sp)
	lw	s4, 12(sp)
	lw	s3, 8(sp)
	lw	s2, 4(sp)
	lw	s1, 0(sp)
	addi	sp, sp 20
ret

read_hex: #int read_hex(int a0)
	
	li 	t0, 48 
	blt 	a0, t0, is_not_hex
	li 	t0, 57
	bgt 	a0, t0, is_not_number
	addi 	a2, a0, -48
	j endif
	
	is_not_number:
	li 	t0, 97 
	blt 	a0, t0, is_capital_letter
	li 	t0, 102
	bgt 	a0, t0, is_not_hex
	addi 	a2, a0, -87
	j endif
	
	is_capital_letter:
	li 	t0, 65 
	blt 	a0, t0, is_not_hex
	li 	t0, 70
	bgt 	a0, t0, is_not_hex
	addi 	a2, a0, -55
	j endif
	
	is_not_hex:
	print_enter
	
	li 	t0, 10
	error "this is not a hex number"
	exit
	
	endif:	
	mv a0, a2

return:
ret
