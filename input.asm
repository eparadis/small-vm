# title: input a line

# set indexptr to the start of the buffer
push @buffer
push @indexptr
store

# get a char
:getchar
get
push @char
store

# if the char is newline, jump to adding zero terminator
# subtract 10 from value
# jgz ie: jump to not10 if orig value was gt 10
# subtract 9 from orig value
# jgz ie: jump to is10 if orig value was gt 9 (and lte 10 from above)

:not10
# put the char into the buffer
push @char
read
push @indexptr
read
read
store

# increment buffer pointer
push @indexptr
read
push 1
add
push @indexptr
store

# jump back to get another char
push @getchar
push 1
jgz

# add a zero terminator
:is10
push 0
push @indexptr
read
store

# push number of characters stored
push @indexptr
push @buffer
sub

# halt (this is where we'd return)
halt

# variable: char, where most recent input is stored
:char
0

# variable: index pointer
:indexptr
0

# space reserved for the string buffer
:buffer
0 0 0 0   0 0 0 0   0 0 0 0   0 0 0 0 # 15 characters and a null

