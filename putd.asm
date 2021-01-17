# printing a decimal number

# this will become a routine at some point
# it will accept a single param and return nothing
push 9  # > 4


:_putd_impl
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

push 10 # newline
emit
halt

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
