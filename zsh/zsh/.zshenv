# zsh profiling {{{
# just execute 'ZSH_PROFILE_RC=1 zsh' and run 'zprof' to get the details
if [[ -n $ZSH_PROFILE_RC ]] ; then
    zmodload zsh/zprof
fi
# }}}

# check for version/system {{{
# check for versions (compatibility reasons)

islinux() {
    [[ $OSTYPE == linux* ]] && return 0
    return 1
}
ismac() {
    [[ $OSTYPE == darwin* ]] && return 0
    return 1
}
issolaris() {
    [[ $OSTYPE == solaris* ]] && return 0
    return 1
}

isecs() {
   [[ -z "${HOST%%*ecs.vuw.ac.nz}" ]] && return 0
   return 1
}

issolaris && return 0

is42(){
    [[ $ZSH_VERSION == 4.<2->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}
is43(){
    [[ $ZSH_VERSION == 4.<3->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}
is438(){
    [[ $ZSH_VERSION == 4.3.<8->* || $ZSH_VERSION == <5->* ]] && return 0
    return 1
}

has_vcsinfo() {
    [[ -n $VCS_INFO_backends ]] && return 0
    return 1
}

# check for user, if not running as root set $SUDO to sudo
(( EUID != 0 )) && SUDO='sudo' || SUDO=''

# this function checks if a command exists and returns either true
# or false. This avoids using 'which' and 'whence', which will
# avoid problems with aliases for which on certain weird systems. :-)
# Usage: have [-c|-g] word
#   -c  only checks for external commands
#   -g  does the usual tests and also checks for global aliases
have() {
    emulate -L zsh
    local -i comonly gatoo

    if [[ $1 == '-c' ]] ; then
        (( comonly = 1 ))
        shift
    elif [[ $1 == '-g' ]] ; then
        (( gatoo = 1 ))
    else
        (( comonly = 0 ))
        (( gatoo = 0 ))
    fi

    if (( ${#argv} != 1 )) ; then
        printf 'usage: have [-c|-g] <command>\n' >&2
        return 1
    fi

    if (( comonly > 0 )) ; then
        [[ -n ${commands[$1]}  ]] && return 0
        return 1
    fi

    if   [[ -n ${commands[$1]}    ]] \
      || [[ -n ${functions[$1]}   ]] \
      || [[ -n ${aliases[$1]}     ]] \
      || [[ -n ${reswords[(r)$1]} ]] ; then

        return 0
    fi

    if (( gatoo > 0 )) && [[ -n ${galiases[$1]} ]] ; then
        return 0
    fi

    return 1
}

# }}}

# path settings {{{

# some ideas from http://www.memoryhole.net/kyle/2008/03/my_bashrc.html

add_to_path() {
    pos=$1
    oldpath=$2
    dir=$3

    if [[ -n "$dir" && "$dir" != "." && -d "$dir" && -x "$dir" ]]; then
        if ! ismac; then
            dir=$(readlink -f "$dir")
        fi

        if [[ -z $(eval "echo \"\$$oldpath\"") ]]; then
            eval "$oldpath=$dir"
        else
            case $pos in
                pre)  eval "$oldpath=$dir:\$$oldpath" ;;
                post) eval "$oldpath=\$$oldpath:$dir" ;;
            esac
        fi
    fi
}

verify_path() {
    TMPPATH=
    for i in $path; do
        add_to_path post TMPPATH $i
    done
    PATH=$TMPPATH
    unset TMPPATH
}

if [[ -d /opt/intel ]]; then
    source /opt/intel/cc/10.0.023/bin/iccvars.sh
    source /opt/intel/idb/10.0.023/bin/idbvars.sh
fi

verify_path

add_to_path post PATH /usr/local/sbin
add_to_path post PATH /sbin
add_to_path post PATH /usr/sbin

# Macports
add_to_path pre PATH /opt/local/bin
add_to_path pre PATH /opt/local/sbin

add_to_path pre PATH "/var/lib/gems/1.8/bin/"
add_to_path pre PATH $HOME/.local/bin
add_to_path pre PATH $HOME/usr/bin
add_to_path pre PATH $HOME/.etc/bin

# make sure $HOME/bin has the highest priority
add_to_path pre PATH $HOME/bin

export PATH

# cdpath=(.. ~)

fpath=($ZDOTDIR/func $fpath)
fpath=($ZDOTDIR/func/VCS_Info $fpath)
fpath=($ZDOTDIR/func/VCS_Info/Backends $fpath)

# automatically remove duplicates from these arrays
typeset -U path cdpath fpath manpath

add_to_path post LD_LIBRARY_PATH $HOME/lib
export LD_LIBRARY_PATH

export XDG_DATA_HOME=$HOME/.local/share
# export XDG_DATA_DIRS=/usr/local/share/:/usr/share/
export XDG_CONFIG_HOME=$HOME/.config
# export XDG_CONFIG_DIRS=/etc/xdg
export XDG_CACHE_HOME=$HOME/.cache

# make sure the cache dir exists
[[ ! -d $XDG_CACHE_HOME ]] && mkdir $XDG_CACHE_HOME
[[ ! -d $XDG_CACHE_HOME/zsh ]] && mkdir $XDG_CACHE_HOME/zsh

# }}}

# vim: foldenable foldmethod=marker
