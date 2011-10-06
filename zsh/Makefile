SHELL=zsh

all: .zshrc.zwc
	cd zshrc.d; $(MAKE)

%.zwc: %
	zcompile $<
