open_file: # int open_file(char* file_name, int flags)
	syscall 1024
	li 	t0, -1
	beq 	a0, t0, open_error
	ret
	
open_error:
	error "can't open file"
	
read_file: # void read_file(int fd, char* buffer, int size)
	mv 	t1, a2
	syscall 63
	bne 	a0, t1, read_error
	ret
	
read_error:
	error "Cannot read file!"
	
close_file: # void close_file(int fd)
	syscall 57
	ret

.macro malloc
syscall 9
.end_macro

.macro LSeek
syscall 62
li 	t0, -1
beq 	a0, t0, flength_error
.end_macro

.eqv SEEK_SET 0
.eqv SEEK_CUR 1
.eqv SEEK_END 2

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
	li 	a1, 0
	li 	a2, SEEK_SET
	LSeek
	mv 	a0, t3
	ret

flength_error:
	error "some kind of error with file"

strchr: # char* strchr(char* str, char ch)
	lb	t0, 0(a0)
	beq	t0, zero, strchr_zero
	beq	t0, a1, strchr_end
	addi	a0, a0, 1
	j	strchr
	
	strchr_zero:
	li	a0, 0
	
	strchr_end:
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