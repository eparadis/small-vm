
push @_test_message
puts
push @_test_message
puts
push @_test_message
puts

push 234
putd
push 10
emit

push 432
putd
push 10
emit

# convert a string to a number and print it out
push @_number_string
atoi
putd
push 10
emit


halt

:_test_message
72
101
108
108
111
33
10
0

:_number_string
52 # '4'
48 # '0'
57 # '9'
0
