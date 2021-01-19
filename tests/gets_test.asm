
# get a line up to 10 chars in length
push @buffer
push 10 
push 32 # space
gets # macro!

# print the value of the TOS
putd

# echo it back
push @buffer
puts # also a macro!

halt

:buffer
0 # actualy goes on, but since it's the last location, i'm not messing with it
