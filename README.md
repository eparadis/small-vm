# small-vm
A small VM idea while thinking about FORTH

# building
`gcc -o small-vm main.c`

`gcc -o asmblr asmblr.c`

# programming
`file.txt` decimal memory contents for the VM

`asm.txt`  mneumonics get turned into decimals

Both support rest-of-line comments with `#`. 

# running
`vim asm.txt`

`./asmblr asm.txt > file.txt`

`./small-vm file.txt`

# smoke test
`./smoketest.sh` compiles and runs some examples

# reading from `stdin`
Use the filename `-` like `./small-vm -` to have the VM read from `stdin`. Using this you can assemble and run in a single line with `./asmblr asm.txt | ./small-vm -`. See `smoketest.sh` for an example.

# using the macro preprocessor
The macro preprocessor expands (very) simple replacement macros in a two-pass process. Because the two-pass assembler can't `rewind(stdin)` when `stdin` is piped from another command, you will need to use a temporary file. An example of how to do this is:
```
gcc -o macroprep macro.c
./macroprep somefile.masm > somefile.asm
./asmblr somefile.asm | ./small-vm -
```

# TODO
- create a macro library of "missing" opcodes like various conditional jumps, call/return, indirect memory addressing, etc. These would be good candidates for adding to the VM to improve code density.
- create a macro library of terminal IO: printing strings, inputting strings, printing number, inputting numbers, print hex, etc
- create a macro library of string operations useful for an interactive monitor: extracting tokens, splitting strings, searching strings, printing areas of memory, etc
- write a small interactive monitor to run in the VM
- write a small assembler to run in the VM
- write a FORTH to run in the VM
- proposal: implement a control (call/return) stack in VM
- unify opcode definitions between VM and assembler so changing the ISA is simpler
- unify the macro processor with the assembler
- remove the need for temporary files (make the assembler single-pass, make an in-memory representation of the object file that can be operated on non-linearly, assume everything is defined before it is needed and do a lazy/lazier calculation on addresses, or ... etc)
- do a better job of preserving comments from one step to the next. Maybe this is a flag?
