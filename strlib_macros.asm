# library to deal with strings

.addmacro call # ( addr -- ) pushes a return address to the stack and jumps somewhere that records that and jumps to addr
pip # push the value of the instruction pointer
push 9
add # point to right after the jgz at the end of this macro
push @_call_impl
push 1
jgz
.endmacro

.addmacro return # ( -- ) jumps to a place that pops the control stack and jumps to it
push @_return_impl
push 1
jgz
.endmacro

.addmacro puts # ( addr -- ) emits a null-terminated string that starts at addr
# this might be what is called a 'trampoline'
# when macros support parameters, this could be 'puts @someString'
# i need a way to jump back to this point, but because this is a macro, it will occur in many places. The obvious answer is a call stack
push @_strlib_puts
call
.endmacro

.addmacro putd # ( val -- ) emits val as a decimal
push @_strlib_putd
call
.endmacro

.addmacro gets # ( buf_addr buf_len term_char -- str_len ) copies characters from the input until buf_len-1 are copied or term_char is encountered. Null-terminates the input and returns the string length
push @_strlib_gets_impl
call
.endmacro

.addmacro atoi # ( str_addr -- value ) converts a string to a decimal
push @_strlib_atoi_impl
call
.endmacro

.addmacro getline # ( buf_addr -- str_len ) lke gets but echos input, assumes 255 char buffer, and a newline terminator
push @_strlib_getline_impl
call
.endmacro
