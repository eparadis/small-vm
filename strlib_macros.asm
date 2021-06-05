# library to deal with strings

.addmacro call # ( addr -- ) pushes a return address to the stack and jumps somewhere that records that and jumps to addr
pip # push the value of the instruction pointer
push 9
add # point to right after the jgz at the end of this macro
push @_call_impl
push 1
jgz
.endmacro

.addmacro _call_impl # ( addr ret_addr -- ) pushes an address to return to on to the control stack and jumps to the address addr
# push current IP
# pip # this is a new opcode: ( -- ip )  
                 # > addr [ip of here]
# add an offset to account for the following code
# push 20 # should point to right after the end of this macro expansion 
                 # > addr [ip of there] 11
# add              # > addr ret_addr 
# increment stack pointer
push @_strlib_SP # > addr ret_addr SP_addr
read             # > addr ret_addr SP_val
push 1           # > addr ret_addr SP_val 1
add              # > addr ret_addr SP_val+1
push @_strlib_SP # > addr ret_addr SP_val+1 SP_addr
store            # > addr ret_addr  # and the SP is now pointing at the next address in the control stack
# copy ret_addr to where the stack pointer points
push @_strlib_SP # > addr ret_addr SP_addr
read             # > addr ret_addr SP_val
store            # > addr  # and where SP points is ret_addr
# jump to addr
push 1           # > addr 1
jgz              # > (empty) # and we jump to addr
.endmacro

.addmacro return # ( -- ) jumps to a place that pops the control stack and jumps to it
push @_return_impl
push 1
jgz
.endmacro

.addmacro _return_impl # ( -- ) pops the control stack and jumps to it
# push whatever the stack pointer points to
push @_strlib_SP # > SP_addr
read             # > SP_val
read             # > TOS_addr
# decrement the stack pointer
push @_strlib_SP # > TOS_addr SP_addr
read             # > TOS_addr SP_val
push 1           # > TOS_addr SP_val 1
sub              # > TOS_addr [SP_val-1]
push @_strlib_SP # > TOS_addr [SP_val-1] SP_addr
store            # > TOS_addr  # and the value at SP_addr is now SP_val-1
# jump to what we pushed earlier
push 1           # > TOS_addr 1
jgz              # > (empty)   # and jump to the address of TOS
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
