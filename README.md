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
