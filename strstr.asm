j strstr

.macro lower_case %reg
 li 	t0, 65 # 'A'
 blt 	%reg, t0, lower_case_end
 li 	t0, 90 # 'Z'
 bgt 	%reg, t0, lower_case_end
 addi 	%reg, %reg, 32
 lower_case_end:
.end_macro

strchr_i: # char* strchr(char* str, char ch, bool flag)
	lb	t0, 0(a0)
	beq	t0, zero, strchr_zero2
	
	beqz	a2, strchr_i_zero
	lower_case t0
	lower_case a1
	
	strchr_i_zero:
	beq	t0, a1, strchr_i_end
	addi	a0, a0, 1
	j	strchr_i
	
	strchr_zero2:
	li	a0, 0
	
	strchr_i_end:
	ret

strstr: # char* strstr(char* str, char* substr, bool flag)
	push ra
	push s0
	push s1
	push s2
	push s3
	mv 	s0, a0 # str
	mv 	s1, a1 # substr
	mv 	s2, a2 # flag
	li 	s3, 0 # answer
	
	strstr_while:
	lb 	a1, 0(s1)
	mv 	a0, s0
	mv 	a2, s2
	call strchr_i
	mv 	s0, a0
	addi 	s0, s0, 1
	beqz 	a0, strstr_null
	li 	t0, 0 # index
	
	strstr_while_inner:
	add 	t2, s1, t0
	lb 	t2, 0(t2)
	beqz 	t2, strstr_end
	add 	t3, a0, t0
	lb 	t3, 0(t3)
	beqz 	t3, strstr_null
	beqz    s3, strstr_while_inner_zero
	lower_case t2
	lower_case t3
	
	strstr_while_inner_zero:
	bne	t2, t3, strstr_while
	addi 	t0, t0, 1
	j strstr_while_inner

	strstr_null:
	li a0, 0
		
	strstr_end:
	pop s3
	pop s2
	pop s1
	pop s0
	ret
	