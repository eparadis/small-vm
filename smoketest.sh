#!/bin/sh

CCARGS='-Wall -Werror'

# build the assembler if needed
if test asmblr.c -nt bar ; then
  gcc $CCARGS -o bar asmblr.c
fi

# run the test file
./bar asm.txt > temp.txt

# build the vm if needed
if test main.c -nt foo ; then
  gcc $CCARGS -o foo main.c
fi

# run the vm
./foo temp.txt

# compile and run the hello world
./bar hello.asm | ./foo -

# build the macro expander if needed
if test macro.c -nt baz ; then
  gcc $CCARGS -o baz macro.c
fi

# expand the example macro
./baz macros.asm > temp2.txt

# assemble and execute the result
./bar temp2.txt | ./foo -
