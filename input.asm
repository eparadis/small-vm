# title: input a line

# get a char
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

# increment buffer pointer

# jump back to get another char

# add a zero terminator
:is10

# push number of characters stored

# halt (this is where we'd return)

# variable: char, where most recent input is stored
:char
0

# variable: length

# variable: index pointer

# space reserved for the string buffer
:buffer
0
