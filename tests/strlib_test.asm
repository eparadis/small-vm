# exercise puts by printing a test message three times
push @_test_message
puts
push @_test_message
puts
push @_test_message
puts

# exercise putd by printing the number 234 (and then a newline)
push 234
putd
push 10
emit

# exercise putd again with the number 432
push 432
putd
push 10
emit

# convert a string "409" to a number and print it out
push @_number_string
atoi
putd
push 10
emit

# end of tests
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
