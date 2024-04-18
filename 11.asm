.include "macros.asm"
.include "file_functions.asm"

.macro malloc
syscall 9
.end_macro

.macro message_int %str, %register
.data
str2: .asciz %str
.text 
la a0, str2
li a7, 4
ecall
mv a0, %register
li a7, 1
ecall
.end_macro

.macro message_str %str, %register
.data
str2: .asciz %str
.text 
la a0, str2
li a7, 4
ecall
mv a0, %register
li a7, 4
ecall
.end_macro

.macro LSeek
syscall 62
li 	t0, -1
beq 	a0, t0, flength_error
.end_macro

.eqv SEEK_SET 0
.eqv SEEK_CUR 1
.eqv SEEK_END 2


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

flength: # int flength(int fd)
	mv 	t2, a0
	li 	a1, 0
	li 	a2, SEEK_CUR
	LSeek
	mv 	t1, a0
	mv 	a0, t2
	li 	a1, 0
	li 	a2, SEEK_END
	LSeek
	mv 	t3, a0
	mv 	a0, t2
	mv 	a1, t1
	li 	a2, SEEK_CUR
	LSeek
	mv 	a0, t3
	ret

flength_error:
	error "some kind of error with file"