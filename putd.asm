# printing a decimal number

# this will become a routine at some point
# it will accept a single param and return nothing
push 9  # > 4
# ( value -- )
push @value
store

# advance decr_idx and set decr to what it points to
:next_decr
# increment the index
push @decr_idx
read
push 1
add
push @decr_idx
store

# store the indexed value of the list into decr
push @decr_list # > @decr_list
push @decr_idx  # > @decr_list @decr_idx
read            # > @decr_list 0
add             # > @decr_list+0
read            # > [0th item of decr list, 100]
push @decr      # > 100 @decr
store           # > (empty) # and decr is 100

# if decr gt 0, we've got more in our list
push @go
push @decr
read
jgz
# else we are done. jump to end
push @end
push 1
jgz

:go
# init the character
push 47 # > 47     # 48 is '0' 
push @char # > 47 @char
store   # > (empty)   # and char is 47

:top
# increment the character
push @char # > @char
read       # > 47
push 1     # > 47 1
add        # > 48
push @char # > 48 @char
store      # > (empty)    # and char is 48

# decrement through our value
push @value
read       # > 4
push @decr
read
sub        # > 3
push @value # > 3 @value
store      # > (empty) # and value is 3

# we now need to jump to top if value is gte 0
# jump if value is gt 0
push @top  # > @top
push @value # > @top @value
read       # > @top value
jgz        # > (empty)
# value is either 0 or negative
push @top
push @value
read
push 1
add   # if value was 0, then TOS is 1, else its 0 or below
jgz

# "undo" the last subtract of decr so value can be used again
push @decr
read
push @value
read
add
push @value
store

# emit the counter
:do_emit
push @char
read
emit

# if decr is gt 0, jump to get next decr
push @next_decr
push @decr
read
jgz

:end

push 10 # newline
emit
halt

:value # we slowly subtract out powers of the radix until this is 0
0

:char # the current character to print
0

:decr # the current radix power we're decrementing by
0

:decr_list # the powers of the radix we're using, zero terminated
100 10 1 0

:decr_idx # index to above list.
-1
