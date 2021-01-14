# library to deal with strings

.addmacro call # ( addr -- ) pushes an address to return to on to the control stack and jumps to the address addr
# push current IP
pip # this is a new opcode: ( -- ip )  
                 # > addr [ip of here]
# add an offset to account for the following code
push 20 # should point to right after the end of this macro expansion 
                 # > addr [ip of there] 11
add              # > addr ret_addr 
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

.addmacro return # ( -- ) pops the control stack and jumps to it
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

