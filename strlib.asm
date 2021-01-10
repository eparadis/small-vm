# library to deal with strings

.addmacro puts # ( addr -- ) emits a null-terminated string at addr
# this might be what is called a 'trampoline'
push @_strlib_puts
push 1
jgz
# TODO i need a way to jump back to this point, but because this is a macro, it will occur in my places. The obvous answer is a call stack
.endmacro

.addmacro putd # ( val -- ) emits val as a decimal
# TODO putd impl
.endmacro

:_strlib_top
push @_strlib_start
push 1
jgz

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
push @_strlib_puts_continue
push 1
jgz

# temporary variable for puts
:_strlib_puts_index
0


:_strlib_start
# init could go here
