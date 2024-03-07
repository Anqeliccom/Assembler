.text
main:


li t1, 10
while:
beq a0,t1 exit

li a7,12
ecall
li a7,11
ecall
addi a0,a0,1
ecall

j while

exit:
li a7, 93
ecall
