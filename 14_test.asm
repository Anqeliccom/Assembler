j main

.include "test_lib_14.asm"
.include "strstr.asm"

main:
FUNK strstr, "strstr"
OK 0, "abcde", "a"
OK 2, "abcde", "d"
OK 0, "deabc", "abc"
OK 5, "abcabcde", "de"
OK 5, "abcde ", " "
OK 0, "", ""
OK 2, "aaaa", "aaa"
NONE "abcde", "aa"
NONE "  abc", "d"
NONE "", "d"
NONE " ", " "
DONE
