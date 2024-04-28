j main

.include "macros.asm"
.include "file_functions.asm"


main: # void main(int arg_count, char** args)
mv 	s10, a0  #  count of arguments
mv 	s11, a1  #  arguments
li 	t0, 1
beq 	s10, t0, main_continue
error "incorrect number of arguments"


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
	
	call count_str
	print_int
	call close_file
	exit
	
insert:
	push ra
	mv	t0, a0
	mv	t1, a1
	mv	a0, a1
	addi	a0, a0, 1
	malloc
	mv	t2, a0
	add	t3, a0, t1
	sb	zero, 1(t3)
	mv	a1, a0
	mv	a0, t0
	mv	a2, t1
	call read_file
	mv	a0, t2
	pop ra
	ret		
	
count_str:
	push ra
	push s3
	li 	s3, 1
	
	count_str_while:
	li	a1, '\n'
	call strchr
	beqz 	a0, count_str_end
	addi	s3, s3, 1
	addi	a0, a0, 1
	j count_str_while
	
	count_str_end:
	mv a0, s3
	pop s3
	pop ra
	ret
