
.macro error %str
.data
str2: .asciz %str
.text 
 la a0, str2
 li a7, 4
 ecall
 exit
.end_macro

.macro push %register
 addi sp, sp, -4
 sw %register, 0(sp)
.end_macro

.macro pop %register
 lw %register, 0(sp)
 addi sp, sp, 4
.end_macro

.macro syscall %t
li	a7, %t
ecall
.end_macro

.macro read_ch
syscall 12
.end_macro

.macro print_ch
syscall 11
.end_macro

.macro exit
syscall 93
.end_macro

.macro print_enter
mv	a6, a0
li	a0, 10
syscall 11
mv	a0, a6
.end_macro
