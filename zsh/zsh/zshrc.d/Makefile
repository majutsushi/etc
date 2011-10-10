SHELL=zsh
RCFILES=$(wildcard [0-9][0-9]*[^~])
RCZWC=$(shell echo $(RCFILES) | grep -v .zwc | sed -e 's/\($| \)/.zwc\1/g')

all: $(RCZWC)

%.zwc: %
	zcompile $<
