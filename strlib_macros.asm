# library to deal with strings

.addmacro call # ( addr -- ) pushes an address to return to on to the control stack and jumps to the address addr
# increment stack pointer
push @_strlib_SP
read
read
push 1
add
push @_strlib_SP
store
# push current IP
pip # this is a new opcode: ( -- ip )
# add an offset to account for the following code
push 10 # should point to right after the end of this macro expansion
add
# copy it to where the stack pointer points
push @_strlib_SP
store
# jump to addr
push 1
jgz
.endmacro

.addmacro return # ( -- ) pops the control stack and jumps to it
# push whatever the stack pointer points to
push @_strlib_SP
read
read
# decrement the stack pointer
push @_strlib_SP
read
push 1
sub
push @_strlib_SP
store
# jump to what we pushed earlier
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

