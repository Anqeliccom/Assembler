.text
.macro exit
li a7, 93
ecall
.end_macro

.macro error %str
.data
str2: .asciz %str
.text 
 la a0, str2
 li a7, 4
 ecall
.end_macro


main:
call read_hexes
mv s1, a0
call read_hexes
mv s2, a0
mv a1, s1
mv a2, s2
call operation
call print_hexes
exit

read_hex: #int read_hex(int a1)
	mv a0, a1
	li 	t0, 48 
	blt 	a0, t0, is_not_hex
	li 	t0, 57
	bge 	a0, t0, is_not_number
	addi 	a2, a0, -48
	j endif
	
	is_not_number:
	li 	t0, 70 
	bgt 	a0, t0 is_not_hex
	addi 	a2, a0, -55
	j endif
	
	is_not_hex:
	li 	t0, 10
	error "this is'n a hex number"
	exit
	
	endif:	
	mv a0, a2
return:
ret

read_hexes: # int read_hexes()
	addi	sp,sp -20
	sw	s1, 0(sp)
	sw	s2, 4(sp)
	sw	s3, 8(sp)
	sw	s4, 12(sp)
	sw	ra, 16(sp)
		
	li	s1, 10
	li 	s2, 0
	li	s3, 0 # счётчик
	li	s4, 7 # количество блоков 
	for:
	bgt 	s3, s4, end_for
	li 	a7, 12
	ecall
	beq 	a0, s1, end_for
	mv	a1, a0
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
	addi	sp,sp 16
ret

operation: # void operation(int a1, int a2)
	li 	a7, 12
	ecall
	li 	t1, 43
	beq 	t1, a0, summa
	li 	t1, 45 
	beq 	t1, a0, sub
	li 	t1, 38 
	beq 	t1, a0, and
	li 	t1, 124 
	beq 	t1, a0, or
	error "invalid character"
	
	summa:
	add	a0, a1, a2
	ret
	sub:
	sub 	a0, a1, a2
	ret
	and:
	and 	a0, a1, a2
	ret
	or:
	or 	a0, a1, a2
	ret

print_hexes: # int read_hexes()
	
	li	s3, 28
	li	s4, 0
	mv 	s1, a0
	li 	t2, 10
	for2:
	blt 	s3, s4, end_for2
	mv 	t1, s1
	srl     t1, t1, s3
	andi	t1,t1, 15
	bge	t1 t2 print_char
	
	addi	t1, t1, 48
	mv 	a0, t1
	li 	a7, 11
	ecall
	addi 	s3, s3, -4
	j for2
	
	print_char:
	addi	t1, t1, 55
	mv 	a0, t1
	li 	a7, 11
	ecall
	addi 	s3, s3, -4
	j for2
	
	end_for2:
	
ret
