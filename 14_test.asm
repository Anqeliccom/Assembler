j main

.include "test_lib_14.asm"
.include "strstr.asm"

main:
FUNK strstr, "strstr"
OK 0, "abcde", "a"
OK 3, "abcde", "d"
OK 2, "deabc", "abc"
OK 6, "abcabcde", "de"
OK 5, "abcde ", " "
OK 0, "aaaa", "aaa"
NONE "abcde", "aa"
NONE "  abc", "d"
NONE "", "d"
NONE "", ""
DONE
