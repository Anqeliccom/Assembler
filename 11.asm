j main

.include "macros.asm"
.include "file_functions.asm"


main: # void main(int arg_count, char** args)
mv 	s10, a0  #  count of arguments
mv 	s11, a1  #  arguments
li 	t0, 1
beq 	s10, t0, len
error "incorrect number of arguments"


len:
	lw 	s1, 0(s11)
	message_str "input file: ", s1
	print_enter
	
	mv 	a0, s1
	li 	a1, 0 # READ
	call open_file
	mv 	s1, a0 # s1: fd
	
	call flength
	mv 	s2, a0 # s2: size
	
	message_int "file length: ", s2
	print_enter
	
	mv	a0, s2
	malloc
	mv	s3, a0
	
	mv	a0, s1
	mv	a1, s3
	mv	a2, s2
	call read_file
	
	mv 	a0, s1
	call close_file
	exit