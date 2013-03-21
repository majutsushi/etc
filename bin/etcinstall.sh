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
    local conffile=.etc/$1
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
    echo "$comment [$(readlink -f $conffile)]" >> $target
    cat $conffile >> $target
    for part in $conffile.d/*; do
        if [[ "$(hostname)" == "$(basename $part)" ]]; then
            echo -e "\n$comment [$(readlink -f $part)]" >> $target
            cat $part >> $target
        fi
    done

    local localfile=$HOME/.local/etc/$(basename "$conffile")
    if [[ -f $localfile ]]; then
        echo -e "\n$comment [$localfile]" >> $target
        cat $localfile >> $target
    fi
}

xlink() {
    local conffile=.etc/$1
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

mkdir -p $HOME/.local/etc
mkdir -p $HOME/.cache/etc

ln -sf $HOME/.etc/.githooks/* .etc/.git/hooks

xlink Rprofile
merge ackrc
xlink ant/ant.conf target=.ant/ant.conf
xlink aptitude
xlink bibtoolrsc
xlink colorgccrc
xlink colordiffrc
xlink ctags
xlink gdbinit
xlink indent.pro
xlink inputrc
xlink irbrc
xlink latexmkrc
xlink lessfilter
#xlink mailcap
xlink mercurial/hgrc
xlink moc
xlink ranger target=.config/ranger
xlink redshift.conf target=.config/redshift.conf
xlink screen/screenrc
xlink slrn/slrnrc
xlink taskrc
xlink tmux/tmux.conf
xlink urxvt
xlink xmonad
xlink zathurarc target=.config/zathura/zathurarc
xlink zsh/zshenv

xlink bash/bashrc
xlink bash/bash_profile
xlink bash/bash_logout

xlink emacs/emacs
xlink emacs/emacs.d

xlink git/gitconfig
merge git/gitignore target=.cache/etc/gitignore

xlink mail/lbdb
xlink mail/msmtprc
xlink mail/offlineimaprc
xlink mail/t-prot target=.config/t-prot
#xlink procmail/procmailrc
mkdir -p $HOME/.cache/procmail

xlink mutt/muttrc
xlink mutt/mutt

xlink pentadactyl/pentadactylrc
xlink pentadactyl/pentadactyl

xlink vim/vimrc
xlink vim/gvimrc
xlink vim/vim
xlink vim/vimplaterc

xlink xorg/fonts.conf.d
#xlink xorg/Xresources
#xlink xorg/xinitrc
#xlink xorg/xinput.d
#xlink xorg/xinputrc
#xlink xorg/xsession
xlink xorg/xsessionrc
merge xorg/Xmodmap comment=!
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
