# library to deal with strings

.addmacro call # ( addr -- ) pushes an address to return to on to the control stack and jumps to the address addr
# increment stack pointer
push @_strlib_SP
read
push 1
add
push @_strlib_SP
store
# push current IP
pip # TODO this is a new opcode: ( -- ip )
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

:_strlib_top
push @_strlib_init
push 1
jgz # jump over all the variables and impls to the init

# control stack
:_strlib_cs
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
:_strlib_SP
0

# --- puts impl ---
:_strlib_puts
# set index to start of string which is on TOS
push @_strlib_puts_index
store

:_strlib_puts_top
# check if index points to a 0
push @_strlib_puts_emit_index
 push @_strlib_puts_index
 read
 read
jgz

# jump to end
push @_strlib_puts_end
push 1
jgz

# emit bute pointed to by index
:_strlib_puts_emit_index
push @_strlib_puts_index
read
read
emit

# increment index
push @_strlib_puts_index
read
push 1
add
push @_strlib_puts_index
store

# jump to top of loop
push @_strlib_puts_top
push 1
jgz

# continue at where we came from
:_strlib_puts_end
return

# temporary variable for puts
:_strlib_puts_index
0

# --- putd impl ---
:_strlib_putd
# discussion: https://stackoverflow.com/questions/13166064/how-do-i-print-an-integer-in-assembly-level-programming-without-printf-from-the
# TODO putd impl
# push a null
# leftover = val
# :top
# push leftover mod 10
# offset by '0'
# leftover = leftover / 10
# if leftover is > 10 goto top
# while not null, pop and emit
return

# temp vars for putd
:_strlib_putd_leftover
0

:_strlib_init
# init the control stack
push @_strlib_cs
push @_strlib_SP
store # store the address of the control stack into the stack pointer
