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
call check_sign
mv s3, t6
call read_hexes
mv s1, a0
call check_sign
mv s4, t6
call read_hexes
mv s2, a0
mv a0, s1
mv a1, s2
mv a3, s3
mv a4, s4
call operation
call print_hexes
exit

plus_minus:
	mv	a1, a0
	li	a0, 45
	print_ch
	mv	a0, a1
	ret

check_sign:# int check_sign ()
	read_ch
	li	t6, 0
	li	t0, 45
	beq	t0, a0, read_minus
	ret
	read_minus:
	li	t6, 1
	ret

print_hexes: # int read_hexes()
	li	t3, 28	# counter
	li	t4, 0	# number of blocks
	mv 	t5, a0
	
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
		sltu	a6, a2, a1
		li	t6, 1
		beq	a6, t6, per_men
		call	sub_
		call 	plus_minus
		ret
		per_men:
		mv	t3, a2
		mv	a2, a1
		mv	a1, t3
		call	sum_
		ret
		if1_1:
		call sum_ # (a2, a10)
		call plus_minus
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
		sltu	a6, a2, a1
		li	t6, 1
		beq	a6, t6, per_men2
		call	sub_
		ret
		per_men2:
		mv	t3, a2
		mv	a2, a1
		mv	a1, t3
		call	sum_
		call 	plus_minus
		ret
		if2_1:
		call sum_
		ret
	
	nol_nol:
		beq	a0, t1, sum_
		beq	a0, t2, sub_
		error "invalid character"
		ret
		
	# если а3 единица и а4 единица 
	#	и знак плюс, то отправлем в сложение а2,а1 и при выводе добавляем минус
	#	и знак минус, то сравниваю беззнаково а2,а1 и если а2 меньше а1, то меняю их местаи и зову вычитание, иначе, из а2 вычитаю а1 и приписываю минус
	# если а3 единица и а4 ноль	
	#	и знак плюс, то сравниваю беззнаково а2,а1 и если а2 меньше а1, то меняю их местаи и зову вычитание, иначе, из а2 вычитаю а1 и приписываю минус
	#	и знак минус, то подаю а2,а1 в сложение и при выводе добавляю минус
	# если а3 и а4 нули
	#	и знак плюс, то отправляем их в сложение
	#	и знак минус, то отправляем их в вычитание

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
	li	t2, 0	# shift counter
	li	t3, 28	# max shift
	li	t6, 15
	li	a6, 0	# addition result
	li	a4, 0	# unit (un)occupied
	
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
	bgtu 	t0, a0, is_not_hex
	li 	t0, 57
	bgtu	a0, t0, is_not_hex
	addi 	a2, a0, -48
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
