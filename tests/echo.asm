# title: input a line and echo it

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
push @not10
 push @char # subtract 10 from value
 read
 push 10
 sub
jgz  # jgz - jump to not10 if orig value was gt 10
push @is10
 push @char  # subtract 9 from orig value
 read
 push 9
 sub
jgz # jgz - jump to is10 if orig value was gt 9 (and lte 10 from above)

:not10
# put the char into the buffer
push @char
read
push @indexptr
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

# push parameters of putstr
push @buffer

# jump to print what was just input
push @putstr
push 1
jgz

# variable: char, where most recent input is stored
:char
0

# variable: index pointer
:indexptr
0

# space reserved for the string buffer
:buffer
-1 -1 -1 -1  -1 -1 -1 -1  -1 -1 -1 -1  -1 -1 -1 0 # 15 characters and a null


:putstr # ( addr -- )
# set the index to the start of the string
# push @s_hello
push @index
store

:top
# check if index points to a 0
push @emit_index
 push @index
 read # read index, which is a pointer
 read # read what index is pointing to
jgz

# jump to end
push @end
push 1
jgz

# emit byte pointed to by index
:emit_index
push @index
read
read
emit

# increment index
push @index
read
push 1
add
push @index
store

# jump to top of loop
push @top
push 1
jgz


# stop the vm
:end
halt

# index pointer 
:index
0

