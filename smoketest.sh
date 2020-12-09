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
