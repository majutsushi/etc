#!/bin/bash

set -e

xlink() {
    if [[ -n "$3" ]] && ! command -v "$3" >/dev/null 2>&1; then
        echo "$3 is not installed"
    elif [[ -a "$2" && ! -L "$2" ]]; then
        echo -e "\033[31m$2 is not a symlink!\033[0m"
    else
        echo "Linking "$2""
        rm -f "$2"
        DIR=$(dirname "$2")
        if ! [[ -d "$DIR" ]]; then
            mkdir -p "$DIR"
        fi
        ln -s "$HOME/$1" "$2"
    fi
}

OLDPWD=$PWD
cd $HOME

xlink .etc/ackrc .ackrc

xlink .etc/bash/bashrc       .bashrc       bash
xlink .etc/bash/bash_profile .bash_profile bash
xlink .etc/bash/bash_logout  .bash_logout  bash

xlink .etc/emacs/emacs   .emacs   emacs
xlink .etc/emacs/emacs.d .emacs.d emacs

xlink .etc/git/gitconfig .gitconfig git

xlink .etc/mercurial/hgrc .hgrc hg

xlink .etc/moc .moc mocp

xlink .etc/mutt/muttrc .muttrc mutt
xlink .etc/mutt/mutt   .mutt   mutt

xlink .etc/pentadactyl/pentadactylrc .pentadactylrc
xlink .etc/pentadactyl/pentadactyl   .pentadactyl

xlink .etc/screen/screenrc .screenrc screen

xlink .etc/slrn/slrnrc .slrnrc slrn

xlink .etc/tmux/tmux.conf .tmux.conf tmux

xlink .etc/urxvt .urxvt urxvt

xlink .etc/vim/vimrc      .vimrc      vim
xlink .etc/vim/vim        .vim        vim
xlink .etc/vim/vimplaterc .vimplaterc vim

xlink .etc/xmonad .xmonad xmonad

xlink .etc/zathurarc .config/zathura/zathurarc zathura

#xlink .etc/xorg/Xmodmap    .Xmodmap
#xlink .etc/xorg/Xresources .Xresources
#xlink .etc/xorg/xinitrc    .xinitrc
#xlink .etc/xorg/xinput.d   .xinput.d
#xlink .etc/xorg/xinputrc   .xinputrc
#xlink .etc/xorg/xsession   .xsession
#xlink .etc/xorg/xsessionrc .xsessionrc

xlink .etc/zsh/zshenv .zshenv zsh

xlink .etc/Rprofile    .Rprofile    R
xlink .etc/bibtoolrsc  .bibtoolrsc  bibtool
xlink .etc/colorgccrc  .colorgccrc  colorgcc
xlink .etc/colordiffrc .colordiffrc colordiff
xlink .etc/ctags       .ctags       ctags
xlink .etc/gdbinit     .gdbinit     gdb
xlink .etc/indent.pro  .indent.pro  indent
xlink .etc/inputrc     .inputrc
xlink .etc/irbrc       .irbrc       irb
xlink .etc/lessfilter  .lessfilter  less
#xlink .etc/mailcap     .mailcap
#xlink .etc/procmailrc  .procmailrc
xlink .etc/taskrc      .taskrc      task

lesskey .etc/lesskey

for tinfof in .etc/terminfo/*; do
    tinfo=$(basename ${tinfof})
    tinfo=${tinfo%.terminfo}
    echo "Compiling terminfo ${tinfo}"
    tic $tinfof

    # also install termcap data if the shell is linked against it
    if ldd $(which bash) | grep -q libtermcap; then
        echo "termcap in use, appending ${tinfo} to ~/.termcap"
        if [[ -f .termcap ]] && ! grep -qE "^${tinfo}\|" .termcap; then
            tic -C -T ${tinfof} >> .termcap
        else
            tic -C -T ${tinfof} > .termcap
        fi
    fi
done

cd $OLDPWD
