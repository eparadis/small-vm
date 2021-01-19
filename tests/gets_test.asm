
# get a line up to 25 chars in length
push @buffer
push 25
push 10 # term = newline?
gets # macro!

# echo it back
push @buffer
puts # also a macro!

halt

:buffer
0 # actualy goes on for another 24 locations
