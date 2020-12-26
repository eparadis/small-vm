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

# if char was 'Q' then jump to end
# push @getchar
#  push @char
#  read
#  push 81
#  sub
# jgz # jump if (char - 81) > 0
# so 80 - 81 = -1. now here
#    81 - 81 = 0,  now here
#    82 - 81 = 1, jumped back up
# push @end
#  push @char
#  read
#  push 80
#  sub
# jgz # jump if (char - 80) > 0
# so 80 - 80 = 0, now here
#    81 - 80 = 1, jumped to end

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


