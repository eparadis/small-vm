# test of macros in assembler
.addmacro jump # ( addr -- ) jump unconditionally to address on TOS
push 1
jgz
.endmacro

:start
push 65
push @target
jump

:end
emit # should print 'B'
emit # should print 'A'
push 10
emit # newline
halt

:target
push 66
push @end
jump
