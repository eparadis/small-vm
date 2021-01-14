
# set the index to the start of the string
push @s_hello
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

# the string "Hello!"
:s_hello
10 # Line feed
72
101
108
108
111
33
10 # Line feed
0

# index pointer 
:index
0

