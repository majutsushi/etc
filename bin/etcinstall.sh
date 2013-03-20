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

merge() {
    local conffile=$1
    shift

    if [[ $# -ge 1 ]]; then
        local "$@"
    fi
    local target=${target:-.$(basename "$conffile")}
    local comment=${comment:-#}

    info "Merging $target"

    if [[ -f $target ]] && ! head -1 $target | grep -q "\*\*\* GENERATED FILE - DO NOT EDIT \*\*\*"; then
        error "$target is not a generated file!"
        return
    fi

    rm -f $target

    echo "$comment *** GENERATED FILE - DO NOT EDIT ***" > $target
    cat $conffile >> $target
    for part in $conffile.d/*; do
        if [[ "$(hostname)" == "$(basename $part)" ]]; then
            cat $part >> $target
        fi
    done

    local localfile=$HOME/.local/etc/$(basename "$conffile")
    if [[ -f $localfile ]]; then
        cat $localfile >> $target
    fi
}

xlink() {
    local conffile=$1
    shift

    if [[ $# -ge 1 ]]; then
        local "$@"
    fi
    local target=${target:-.$(basename "$conffile")}

    info "Linking $target"

    if [[ -a "$target" && ! -L "$target" ]]; then
        error "$target is not a symlink!"
        return
    fi

    rm -f "$target"
    local dir=$(dirname "$target")
    if ! [[ -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
    ln -s "$HOME/$conffile" "$target"
}

OLDPWD=$PWD
cd $HOME

ln -sf $HOME/.etc/.githooks/* .etc/.git/hooks

xlink .etc/Rprofile
xlink .etc/ackrc
xlink .etc/ant/ant.conf target=.ant/ant.conf
xlink .etc/aptitude
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
xlink .etc/ranger target=.config/ranger
xlink .etc/redshift.conf target=.config/redshift.conf
xlink .etc/screen/screenrc
xlink .etc/slrn/slrnrc
xlink .etc/taskrc
xlink .etc/tmux/tmux.conf
xlink .etc/urxvt
xlink .etc/xmonad
xlink .etc/zathurarc target=.config/zathura/zathurarc
xlink .etc/zsh/zshenv

xlink .etc/bash/bashrc
xlink .etc/bash/bash_profile
xlink .etc/bash/bash_logout

xlink .etc/emacs/emacs
xlink .etc/emacs/emacs.d

xlink .etc/mail/lbdb
xlink .etc/mail/msmtprc
xlink .etc/mail/offlineimaprc
xlink .etc/mail/t-prot target=.config/t-prot
#xlink .etc/procmail/procmailrc
mkdir -p $HOME/.cache/procmail

xlink .etc/mutt/muttrc
xlink .etc/mutt/mutt

xlink .etc/pentadactyl/pentadactylrc
xlink .etc/pentadactyl/pentadactyl

xlink .etc/vim/vimrc
xlink .etc/vim/gvimrc
xlink .etc/vim/vim
xlink .etc/vim/vimplaterc

xlink .etc/xorg/fonts.conf.d
#xlink .etc/xorg/Xresources
#xlink .etc/xorg/xinitrc
#xlink .etc/xorg/xinput.d
#xlink .etc/xorg/xinputrc
#xlink .etc/xorg/xsession
xlink .etc/xorg/xsessionrc
merge .etc/xorg/Xmodmap comment=!
xmodmap $HOME/.Xmodmap


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
