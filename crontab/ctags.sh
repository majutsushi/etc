#!/bin/bash

TAGDIR=$HOME/.cache/tags

mkdir -p $TAGDIR

ctags --recurse --excmd=number -f $TAGDIR/systags --extra=+q /usr/include 2> /dev/null

for dir in /usr/lib/python*; do
    base=$(basename $dir)
    ctags --recurse --excmd=number -f $TAGDIR/${base}tags $dir 2> /dev/null
done
