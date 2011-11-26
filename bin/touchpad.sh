#!/bin/bash
# touchpad.sh -- created 2009-04-27, Jan Larres
# @Last Change: 24-Dez-2004.
# @Revision:    0.0

#syndaemon -d -i 2.0s
syndaemon -d -i 1.0s

synclient TapButton1=1
synclient TapButton2=8 # needed because of xmodmap remapping
synclient TapButton3=2
synclient VertEdgeScroll=1
synclient HorizEdgeScroll=1
synclient VertTwoFingerScroll=1
synclient HorizTwoFingerScroll=0

# vi: 
