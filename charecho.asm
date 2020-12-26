# title: echo typed characters

# get a char
:getchar
get
push @char
store

# echo char to output
push @char
read
emit

# jump back to get another char
push @getchar
push 1
jgz

# stop the vm
:end
halt

# variable: char, where most recent input is stored
:char
0


