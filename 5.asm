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
    mv	s1, a0
    call read_hexes
    mv 	s2, a0
    mv 	a0, s1
    mv 	a1, s2
    call multiply_hex
    call print_hexes
    exit

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
	ret
return:
ret

print_hexes: # int print_hexes (int a0)
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

