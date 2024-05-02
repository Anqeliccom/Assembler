.include "macros.asm"
.include "file_functions.asm"

.macro FUNK %func, %name
.data
 func_name: .asciz %name
.text
 li	s4, 0
 li	s5, 0
 la 	s10, %func
 la 	s11, func_name
 message "Testing function "
 message %name
 message "...\n"
.end_macro

.macro OK %exp, %str, %substr
.data
 str: .asciz %str
 substr: .asciz %substr
.text
 la 	a0, str
 mv 	s0, a0
 li 	s1, %exp
 la 	a1, substr
 mv 	s2, a1
 li	a2, 0
 jalr 	s10
 mv 	s3, a0
 beqz 	a0, OK_falied_none
 sub 	s3, s3, s0
 bne 	s1, s3, OK_falied
 addi 	s4, s4, 1
 j OK_end
	
 OK_falied_none:
 	addi 	s5, s5, 1
 	message_str "Test falied: ", s11
	message "(“"
	mv 	a0, s0
	print_str
	message "”, '"
	mv	a0, s2
	print_str
	message "') results in NONE, "
	message "expected OK("
	mv	a0, s1
	print_int
	message ")\n"
	j OK_end
		
 OK_falied:
 	addi 	s5, s5, 1
 	message_str "Test falied: ", s11
	message "(“"
	mv 	a0, s0
	print_str
	message "”, '"
	mv	a0, s2
	print_str
	message "') results in OK("
	mv	a0, s3
	print_int
	message "), expected OK("
	mv	a0, s1
	print_int
	message ")\n"
		
 OK_end:
.end_macro
	
.macro NONE %str, %substr
.data
 str: .asciz %str
 substr: .asciz %substr
.text
 la 	a0, str
 mv 	s0, a0
 la 	a1, substr
 mv 	s2, a1
 li	a2, 0
 jalr 	s10
 mv 	s3, a0
 bnez 	a0, NONE_falied
 addi 	s4, s4, 1
 j NONE_end
 
NONE_falied:
 	addi 	s5, s5, 1
 	message_str "Test falied: ", s11
	message "(“"
	mv 	a0, s0
	print_str
	message "”, '"
	mv	a0, s2
	print_str
	message "') results in OK("
	sub 	s3, s3, s0
	mv	a0, s3
	print_int
	message "), "
	message "expected NONE\n"
 NONE_end:
.end_macro

.macro DONE
 message "Passed: "
 mv	a0, s4
 print_int
 message ", failed: "
 mv	a0, s5
 print_int
 message "\n"
 exit
.end_macro
