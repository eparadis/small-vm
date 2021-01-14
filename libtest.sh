#!/usr/bin/env bash

cat strlib_macros.asm strlib.asm > one
./baz one > two
cat strlib_macros.asm two > three
./baz three > four
./bar four > five
./foo five
