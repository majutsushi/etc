#!/bin/bash

xlink() {
    if [[ -a "$2" && ! -L "$2" ]]; then
        echo -e "\033[31m$2 is not a symlink!\033[0m"
    else
        echo "Linking "$2""
        rm -f "$2"
        ln -s "$1" "$2"
    fi
}

OLDPWD=$PWD
cd $HOME

xlink .etc/bash/bashrc       .bashrc
xlink .etc/bash/bash_profile .bash_profile
xlink .etc/bash/bash_logout  .bash_logout

xlink .etc/emacs/emacs   .emacs
xlink .etc/emacs/emacs.d .emacs.d

xlink .etc/git/gitconfig .gitconfig

xlink .etc/mercurial/hgrc .hgrc

if command -v mocp >/dev/null 2>&1; then
    xlink .etc/moc .moc
fi

xlink .etc/mutt/muttrc .muttrc
xlink .etc/mutt/mutt   .mutt

xlink .etc/pentadactyl/pentadactylrc .pentadactylrc
xlink .etc/pentadactyl/pentadactyl   .pentadactyl

xlink .etc/screen/screenrc .screenrc

xlink .etc/slrn/slrnrc .slrnrc

xlink .etc/urxvt .urxvt

xlink .etc/vim/vimrc      .vimrc
xlink .etc/vim/vim        .vim
xlink .etc/vim/vimplaterc .vimplaterc

if command -v xmonad >/dev/null 2>&1; then
    xlink .etc/xmonad .xmonad
fi

#xlink .etc/xorg/Xmodmap    .Xmodmap
#xlink .etc/xorg/Xresources .Xresources
#xlink .etc/xorg/xinitrc    .xinitrc
#xlink .etc/xorg/xinput.d   .xinput.d
#xlink .etc/xorg/xinputrc   .xinputrc
#xlink .etc/xorg/xsession   .xsession
#xlink .etc/xorg/xsessionrc .xsessionrc

xlink .etc/zsh/zshenv .zshenv

xlink .etc/Rprofile   .Rprofile
xlink .etc/bibtoolrsc .bibtoolrsc
xlink .etc/colorgccrc .colorgccrc
xlink .etc/ctags      .ctags
xlink .etc/gdbinit    .gdbinit
xlink .etc/indent.pro .indent.pro
xlink .etc/inputrc    .inputrc
xlink .etc/irbrc      .irbrc
xlink .etc/lessfilter .lessfilter
#xlink .etc/mailcap    .mailcap
#xlink .etc/procmailrc .procmailrc

cd $OLDPWD
