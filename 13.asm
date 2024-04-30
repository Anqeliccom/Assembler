j main

.include "macros.asm"
.include "file_functions.asm"


main: # void main(int arg_count, char** args)
mv 	s10, a0  #  count of arguments
mv 	s11, a1  #  arguments
li 	t0, 1
li	t1, 2

beq 	s10, t0, main_continue
bne 	s10, t1, error_arg
lw 	a0, 4(s11)
call str_to_int
blez	a0, error_N
mv	s9, a0


main_continue:
	lw 	s1, 0(s11)
	mv 	a0, s1
	li 	a1, 0 # READ
	call open_file
	mv 	s1, a0 # s1: fd
	call flength
	mv 	a1, a0 # a1: size
	mv	a0, s1
	call insert
	call split_lines	
	mv 	a2, a1 # a2: number of str
	li	a1, 1
	li 	t0, 1
	beq 	t0, s10, print_table
	bge	s9, a2, error_N
	mv 	a1, s9 # a1: N
	sub 	a1, a2, a1
	addi 	a2, a2, 1
	
	print_table: # void print_table(char** array, int (num_str - N), int num_str)
	push ra
	push s0
	push s1
	mv 	t1, a1
	addi 	a1, a1, -1
	slli 	a1, a1, 2
	add 	s0, a0, a1
	mv 	s1, a2
	addi 	s1, s1, 1
	
	print_table_while:
	mv	a0, t1
	print_int
	lw 	t2, 0(s0)
	message_str "\t ", t2
	print_enter
	addi 	t1, t1, 1
	addi 	s0, s0, 4
	bne 	t1, s1, print_table_while
	print_enter
	mv a0, s1
	call close_file
	pop s1
	pop s0
	pop ra
	exit

str_to_int:
	push ra
	push s0
	push s1
	push s2
	mv 	s0, a0
	li 	s1, 0 # answer
	lb 	a0, 0(s0)
	
	str_to_int_while:
	beqz 	a0, str_to_int_end
	call ascii_to_val_int
	mv 	s2, a0
	mv 	a0, s1
	li 	a1, 10
	call multiply
	add 	s1, a0, s2
	addi 	s0, s0, 1
	lb 	a0, 0(s0)
	j str_to_int_while
	
	str_to_int_end:
	mv 	a0, s1
	call close_file
	pop s2
	pop s1
	pop s0
	pop ra
	ret	

split_lines:
	push ra
	push s0
	push s1
	push s2
	push s3
	mv 	s0, a0
	call count_str
	mv 	s1, a0  # number of str
	slli 	a0, a0, 2
	malloc
	mv 	s2, a0  # array of str
	mv 	s3, a0  # counter
	mv 	a0, s0
		
	split_lines_while:
	li 	a1, '\n'
	call strchr
	beqz 	a0, split_lines_end
	sb 	zero, 0(a0)
	sw 	s0, 0(s3)
	addi 	a0, a0, 1
	addi 	s3, s3, 4
	mv 	s0, a0
	j split_lines_while
	
	split_lines_end:
	sw 	s0, 0(s3)
	mv 	a1, s1
	mv 	a0, s2
	pop s3
	pop s2
	pop s1
	pop s0
	pop ra
	ret

multiply: # int multiply(int a0, int a1)
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
					
ascii_to_val_int: #int ascii_to_val_int(int a0)
	li 	t0, 48
	bgtu 	t0, a0, is_not_number
	li 	t0, 57
	bgtu	a0, t0, is_not_number
	addi 	a0, a0, -48
	ret
	
	is_not_number:
	print_enter
	error "this is not a correct symbol"
	exit

error_arg:
error "incorrect number of arguments"

error_N:
error "incorrect value of N"
