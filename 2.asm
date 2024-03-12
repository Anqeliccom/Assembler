.text

main:

while:
	li a7, 12
	ecall

	li t1, 10
	beq a0, t1 exit

	li a7, 11
	ecall

	addi a0, a0, 1
	li a7, 11
	ecall

	j while

exit:
li a0, 1
li a7, 93
ecall
