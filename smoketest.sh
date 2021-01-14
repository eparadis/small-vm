#!/bin/sh

CCARGS='-Wall -Werror'
VMNAME='foo'
ASMNAME='bar'
MACRONAME='baz'

# build the assembler if needed
if test asmblr.c -nt $ASMNAME ; then
  gcc $CCARGS -o $ASMNAME asmblr.c
fi

# run the test file
./$ASMNAME tests/asm.txt > temp/temp.txt

# build the vm if needed
if test main.c -nt $VMNAME ; then
  gcc $CCARGS -o $VMNAME main.c
fi

# run the vm
./$VMNAME temp/temp.txt

# compile and run the hello world
./$ASMNAME tests/hello.asm | ./$VMNAME -

# build the macro expander if needed
if test macro.c -nt $MACRONAME ; then
  gcc $CCARGS -o $MACRONAME macro.c
fi

# expand the example macro
./$MACRONAME tests/macros.asm > temp/temp2.txt

# assemble and execute the result
./$ASMNAME temp/temp2.txt | ./$VMNAME -
