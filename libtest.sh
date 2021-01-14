#!/usr/bin/env bash

export DIR='temp/libtest'

mkdir -p $DIR

cat strlib_macros.asm strlib_impl.asm tests/strlib_test.asm > $DIR/one
./baz $DIR/one > $DIR/two
cat strlib_macros.asm $DIR/two > $DIR/three
./baz $DIR/three > $DIR/four
./bar $DIR/four > $DIR/five
./foo $DIR/five
