:_strlib_top
push @_strlib_init
push 1
jgz # jump over all the variables and impls to the init

# --- call impl ---
:_call_impl
_call_impl   # so 'call_impl' is actually a macro, so we're just expanding it here at a specific address

# --- return impl ---
:_return_impl
_return_impl # like call_impl, we're expanding this here and jumping to it from macros to save space

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
# ### algorithm inspiration: https://wikiti.brandonw.net/index.php?title=Z80_Routines:Other:DispHL
# ( value -- )
push @_putd_value
store

# advance decr_idx and set decr to what it points to
:_putd_next_decr
# increment the index
push @_putd_decr_idx
read
push 1
add
push @_putd_decr_idx
store

# store the indexed value of the list into decr
push @_putd_decr_list # > @decr_list
push @_putd_decr_idx  # > @decr_list @decr_idx
read            # > @decr_list 0
add             # > @decr_list+0
read            # > [0th item of decr list, 100]
push @_putd_decr      # > 100 @decr
store           # > (empty) # and decr is 100

# if decr gt 0, we've got more in our list
push @_putd_go
push @_putd_decr
read
jgz
# else we are done. jump to end
push @_putd_end
push 1
jgz

:_putd_go
# init the character
push 47 # > 47     # 48 is '0' 
push @_putd_char # > 47 @char
store   # > (empty)   # and char is 47

:_putd_top
# increment the character
push @_putd_char # > @char
read       # > 47
push 1     # > 47 1
add        # > 48
push @_putd_char # > 48 @char
store      # > (empty)    # and char is 48

# decrement through our value
push @_putd_value
read       # > 4
push @_putd_decr
read
sub        # > 3
push @_putd_value # > 3 @value
store      # > (empty) # and value is 3

# we now need to jump to top if value is gte 0
# jump if value is gt 0
push @_putd_top  # > @top
push @_putd_value # > @top @value
read       # > @top value
jgz        # > (empty)
# value is either 0 or negative
push @_putd_top
push @_putd_value
read
push 1
add   # if value was 0, then TOS is 1, else its 0 or below
jgz

# "undo" the last subtract of decr so value can be used again
push @_putd_decr
read
push @_putd_value
read
add
push @_putd_value
store

# emit the counter
:_putd_do_emit
push @_putd_char
read
emit

# if decr is gt 0, jump to get next decr
push @_putd_next_decr
push @_putd_decr
read
jgz

:_putd_end
return

# temp vars for putd
:_putd_value # we slowly subtract out powers of the radix until this is 0
0

:_putd_char # the current character to print
0

:_putd_decr # the current radix power we're decrementing by
0

:_putd_decr_list # the powers of the radix we're using, zero terminated
100 10 1 0

:_putd_decr_idx # index to above list.
-1


# --- gets impl ---
:_strlib_gets_impl
# ( buf_addr buf_len term_char -- str_len )
push @_gets_term
store
push 1
sub # decrement buf_len to make room for null terminator
push @_gets_buf_len
store
push @_gets_buf_addr
store

# if str_len == buf_len - 1, stop getting chars
# if str_len - (buf_len-1) > 0, stop getting chars
:_gets_top
push @_gets_input_done
push @_gets_str_len
read
push @_gets_buf_len
read
push 1
sub
sub
jgz

# get a char and copy it to the buffer
get
push @_gets_buf_addr
read
store

# if the char == terminating character, stop getting chars
# TODO jeq # macro - jump if equal ( target val1 val2 -- )
push @_gets_uneq
push @_gets_buf_addr
read
read
push @_gets_term
read
sub
jgz # jump to uneq if char - term > 0
push @_gets_uneq
push @_gets_term
read
push @_gets_buf_addr
read
read
sub
jgz # jump to uneq if term - char > 0

# the difference must be 0, so they're equal
push @_gets_input_done
push 1
jgz

:_gets_uneq

# increment string length & buf_addr
push @_gets_str_len
read
push 1
add
push @_gets_str_len
store

push @_gets_buf_addr
read
push 1
add
push @_gets_buf_addr
store

# go back to top
push @_gets_top
push 1
jgz

:_gets_input_done
# add null terminator
push 0
push @_gets_buf_addr
read
store

# retval of chars input
push @_gets_str_len
read
return

# working vars for gets
:_gets_term
0
:_gets_buf_len
0
:_gets_buf_addr
0
:_gets_str_len
0

# --- atoi impl ---
:_strlib_atoi_impl # (str_addr -- value)
# TODO atoi impl
return

:_strlib_init
# init the control stack
push @_strlib_cs
push @_strlib_SP
store # store the address of the control stack into the stack pointer

