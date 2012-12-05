#!/bin/bash

set -e

info() {
    # echo -e "\033[32m$1\033[0m"
    echo -e "$1"
}
warn() {
    echo -e "\033[33m$1\033[0m"
}
error() {
    echo -e "\033[31m$1\033[0m"
}

xlink() {
    if [[ -n "$3" ]] && ! command -v "$3" >/dev/null 2>&1; then
        warn "$3 is not installed"
        return
    fi

    if [[ -n "$2" ]]; then
        TARGET=$2
    else
        TARGET=.$(basename "$1")
    fi

    if [[ -a "$TARGET" && ! -L "$TARGET" ]]; then
        error "$TARGET is not a symlink!"
        return
    else
        info "Linking $TARGET"
        rm -f "$TARGET"
        DIR=$(dirname "$TARGET")
        if ! [[ -d "$DIR" ]]; then
            mkdir -p "$DIR"
        fi
        ln -s "$HOME/$1" "$TARGET"
    fi
}

OLDPWD=$PWD
cd $HOME

ln -sf $HOME/.etc/.githooks/* .etc/.git/hooks

xlink .etc/Rprofile
xlink .etc/ackrc
xlink .etc/bibtoolrsc
xlink .etc/colorgccrc
xlink .etc/colordiffrc
xlink .etc/ctags
xlink .etc/gdbinit
xlink .etc/git/gitconfig
xlink .etc/indent.pro
xlink .etc/inputrc
xlink .etc/irbrc
xlink .etc/latexmkrc
xlink .etc/lessfilter
#xlink .etc/mailcap
xlink .etc/mercurial/hgrc
xlink .etc/moc
#xlink .etc/procmail/procmailrc
xlink .etc/screen/screenrc
xlink .etc/slrn/slrnrc
xlink .etc/taskrc
xlink .etc/tmux/tmux.conf
xlink .etc/urxvt
xlink .etc/xmonad
xlink .etc/zathurarc .config/zathura/zathurarc
xlink .etc/zsh/zshenv

xlink .etc/bash/bashrc
xlink .etc/bash/bash_profile
xlink .etc/bash/bash_logout

xlink .etc/emacs/emacs
xlink .etc/emacs/emacs.d

xlink .etc/mail/lbdb
xlink .etc/mail/msmtprc
xlink .etc/mail/offlineimaprc

xlink .etc/mutt/muttrc
xlink .etc/mutt/mutt

xlink .etc/pentadactyl/pentadactylrc
xlink .etc/pentadactyl/pentadactyl

xlink .etc/vim/vimrc
xlink .etc/vim/gvimrc
xlink .etc/vim/vim
xlink .etc/vim/vimplaterc

#xlink .etc/xorg/Xmodmap
#xlink .etc/xorg/Xresources
#xlink .etc/xorg/xinitrc
#xlink .etc/xorg/xinput.d
#xlink .etc/xorg/xinputrc
#xlink .etc/xorg/xsession
xlink .etc/xorg/xsessionrc


lesskey .etc/lesskey

FONTDIR=$HOME/.local/share/fonts
mkdir -p $FONTDIR
for fontf in .etc/xorg/fonts/*.bdf; do
    font=$(basename ${fontf})
    font=${font%.bdf}
    info "Installing font ${font}"
    bdftopcf -o $FONTDIR/${font}.pcf ${fontf}
    gzip -f $FONTDIR/${font}.pcf
done
cd $FONTDIR
mkfontdir
cd $HOME
xset -fp $FONTDIR 2> /dev/null
xset +fp $FONTDIR

for tinfof in .etc/terminfo/*; do
    tinfo=$(basename ${tinfof})
    tinfo=${tinfo%.terminfo}
    info "Compiling terminfo ${tinfo}"
    tic $tinfof

    # also install termcap data if the shell is linked against it
    if ldd $(which bash) | grep -q libtermcap; then
        info "termcap in use, appending ${tinfo} to ~/.termcap"
        if [[ -f .termcap ]] && ! grep -qE "^${tinfo}\|" .termcap; then
            tic -C -T ${tinfof} >> .termcap
        else
            tic -C -T ${tinfof} > .termcap
        fi
    fi
done

cd $OLDPWD
