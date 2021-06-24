:_strlib_top
push @_strlib_init
push 1
jgz # jump over all the variables and impls to the init

# --- call impl ---
:_call_impl
# ( addr ret_addr -- ) pushes an address to return to on to the control stack and jumps to the address addr
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


# --- return impl ---
:_return_impl
# ( -- ) pops the control stack and jumps to it
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


# control stack
:_strlib_cs
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
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

# reset temp vars
push 0
push @_putd_char
store
push 0
push @_putd_decr
store
push -1
push @_putd_decr_idx
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
# store the string address
push @_strlib_atoi_str_addr
store

# jump to done if string address points to a \0
push @_strlib_atoi_top
push @_strlib_atoi_str_addr
read
read
jgz
push @_strlib_atoi_done # it wasn't GT 0
push 1
jgz

:_strlib_atoi_top
# get the character the address points to
push @_strlib_atoi_str_addr
read
read

# subtract '0' from it
push 48 # '0'
sub

# TODO bail out if we didn't get a value in range

# add it to the result
push @_strlib_atoi_result
read
add
push @_strlib_atoi_result
store

# increment the pointer
push @_strlib_atoi_str_addr
read
push 1
add
push @_strlib_atoi_str_addr
store

# jump to done if address points to a \0
push @_strlib_atoi_over
push @_strlib_atoi_str_addr
read
read
jgz
push @_strlib_atoi_done # it wasn't GT 0
push 1
jgz

:_strlib_atoi_over
# multiply result by 10 w/ an unrolled loop
push @_strlib_atoi_result read # push result # > result
push @_strlib_atoi_result read # push result # > result result
add # > [2*result]
push @_strlib_atoi_result store # store result # > (empty) # and result=2*result
push @_strlib_atoi_result read # push result  # > [2*result]
push @_strlib_atoi_result read # push result  # > [2*result] [2*result]
push @_strlib_atoi_result read # push result  # > [2*result] [2*result] [2*result]
add # > [2*result] [4*result]
push @_strlib_atoi_result store # store result # > [2*result] # and result=4*result
push @_strlib_atoi_result read # push result  # > [2*result] [4*result]
push @_strlib_atoi_result read # push result  # > [2*result] [4*result] [4*result]
add          # > [2*result] [8*result]
add          # > [10*result]
push @_strlib_atoi_result store # store result # > (empty) # and result=10*result

# jump to top
push @_strlib_atoi_top
push 1
jgz

:_strlib_atoi_done
# push the result
push @_strlib_atoi_result
read
return

# atoi temp variables
:_strlib_atoi_str_addr
0

:_strlib_atoi_result
0

:_strlib_getline_impl # ( buffaddr - length ) gets chars, echos them, puts them in the buffer, until a newline 
# store a pointer to the buffer
push @_strlib_getline_headaddr
store
:_strlib_getline_top
# read a character from input
get
push @_strlib_getline_input
store
# if the character is a newline
push @_strlib_getline_continue
push @_strlib_getline_input
read
push 10 # 10 is NL, 13 is CR
sub
jnz 
#  store a null into the buffer
push 0
push @_strlib_getline_headaddr
read
store
#  TODO decrement the buffer size
#  jump out of loop
push @_strlib_getline_end
push 1
jnz
# otherwise
:_strlib_getline_continue
# put read character in the buffer
push @_strlib_getline_input
read
push @_strlib_getline_headaddr
# read
store
# echo the character
emit
# increment buffer head
push @_strlib_getline_headaddr
read
push 1
add
push @_strlib_getline_headaddr
store
# TODO if any buffer remains, jump to top
push @_strlib_getline_top
push 1
jnz

:_strlib_getline_end
# TODO subtract to find the string length and leave it TOS
push 0

return

# getline temp variables
:_strlib_getline_headaddr
0

:_strlib_getline_input
0

# dup temp variables
:_strlib_dup_temp
0

:_strlib_init
# init the control stack
push @_strlib_cs
push @_strlib_SP
store # store the address of the control stack into the stack pointer

