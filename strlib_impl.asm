:_strlib_top
push @_strlib_init
push 1
jgz # jump over all the variables and impls to the init

# --- call impl ---
:_call_impl
_call_impl   # so 'call_impl' is actually a macro, so we're just expanding it here at a specific address

# --- return impl ---
:_return_impl
_return_impl # like call_impl, we're expanding this here and jumping to it from macros to save space

# control stack
:_strlib_cs
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
:_strlib_SP
0

# --- puts impl ---
:_strlib_puts
# set index to start of string which is on TOS
push @_strlib_puts_index
store

:_strlib_puts_top
# check if index points to a 0
push @_strlib_puts_emit_index
 push @_strlib_puts_index
 read
 read
jgz

# jump to end
push @_strlib_puts_end
push 1
jgz

# emit bute pointed to by index
:_strlib_puts_emit_index
push @_strlib_puts_index
read
read
emit

# increment index
push @_strlib_puts_index
read
push 1
add
push @_strlib_puts_index
store

# jump to top of loop
push @_strlib_puts_top
push 1
jgz

# continue at where we came from
:_strlib_puts_end
return

# temporary variable for puts
:_strlib_puts_index
0

# --- putd impl ---
:_strlib_putd
# discussion: https://stackoverflow.com/questions/13166064/how-do-i-print-an-integer-in-assembly-level-programming-without-printf-from-the
# TODO putd impl
# push a null
# leftover = val
# :top
# push leftover mod 10
# offset by '0'
# leftover = leftover / 10
# if leftover is > 10 goto top
# while not null, pop and emit
# ### alternate algorithm https://wikiti.brandonw.net/index.php?title=Z80_Routines:Other:DispHL
# param: value - the thing we're printing
# base = -1000
# call _reset_count
# base = -100
# call _reset_count
# base = -10
# call _reset_count
# base = -1
# :_reset_count
# count = '0' - 1 (47 decimal)
# :_loop
# count = count + 1
# value = value + base (note: base is negative so we're actually subtracting)
# jump to loop if value is positive
# value = value - base (note: base is negative so we're actually adding)
# emit count (it should be ascii '0' through '9')
# return (to get the next value of base, and then finally to return from our call into this subroutine)
# ### a third algorithm from jonesforth https://github.com/nornagon/jonesforth/blob/4f853252f715132e7716cbd44e5306cefb6a6fec/jonesforth.f#L276-L320

return

# temp vars for putd
:_strlib_putd_leftover
0

:_strlib_init
# init the control stack
push @_strlib_cs
push @_strlib_SP
store # store the address of the control stack into the stack pointer

