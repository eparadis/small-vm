# printing a decimal number

# this will become a routine at some point
# it will accept a single param and return nothing
push 1  # > 4
# ( value -- )
push @value
store

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
push 1     # > 4 1
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


# emit the counter
:do_emit
push @char
read
emit

push 10 # newline
emit
halt

:value
0

:char
0
