# small-vm
A small VM idea while thinking about FORTH

# building
`gcc -o small-vm main.c`
`gcc -o asmblr asmblr.c

# programming
`file.txt` decimal memory contents for the VM
`asm.txt`  mneumonics get turned into decimals
Both support rest-of-line comments with `#`. 

# running
`vim asm.txt`
`./asmblr > file.txt`
`./small-vm`
