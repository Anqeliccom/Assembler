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