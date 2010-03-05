# zshrc, originally based on the configs from grml.org and Joey Hess
# (http://svn.kitenet.net/trunk/home-full/.zshrc?view=markup&pathrev=11710)

# check for version/system {{{
# check for versions (compatibility reasons)

ismac() {
    [[ $OSTYPE == darwin* ]] && return 0
    return 1
}
issolaris() {
    [[ $OSTYPE == solaris* ]] && return 0
    return 1
}

issolaris && return 0

if autoload is-at-least && is-at-least 2>/dev/null ; then
    is42() { is-at-least 4.2 }
    is43() { is-at-least 4.3 }
else
    is42(){
        [[ $ZSH_VERSION == 4.<2->* ]] && return 0
        return 1
    }
    is43(){
        [[ $ZSH_VERSION == 4.<3->* ]] && return 0
        return 1
    }
fi

if ismac; then
    [[ -r /sw/bin/init.sh ]] && . /sw/bin/init.sh
    export TERM=xterm-color
fi

# check for user, if not running as root set $SUDO to sudo
(( EUID != 0 )) && SUDO='sudo' || SUDO=''
# }}}

# variables {{{

path=(
    /usr/local/games
    /var/lib/gems/1.8/bin
    /usr/local/{,s}bin
    /{,s}bin
    /usr/{,s}bin
    /usr/games
)

if [[ -d $HOME/apps/loopo ]] ; then
    path=( $HOME/apps/loopo/loopobin/bin $path )
fi

if [[ -d /opt/intel ]] ; then
    source /opt/intel/cc/10.0.023/bin/iccvars.sh
    source /opt/intel/idb/10.0.023/bin/idbvars.sh
fi

# make sure $HOME/bin has the highest priority
path=( ${HOME}/bin $path )

export PATH

# cdpath=(.. ~)

# automatically remove duplicates from these arrays
typeset -U path cdpath fpath manpath

export TIMEFMT="%*E real  %*U user  %*S system  %P  %J"

export EDITOR=${EDITOR:-vim}
export MAIL=${MAIL:-/var/mail/$USER}

export PAGER=${PAGER:-less}

export LESS="-Ri-P%f ?m(file %i/%m) .lines %lt-%lb?L/%L. ?e(END)?x - Next\: %x.:?PB%PB\%..%t"

# http://nion.modprobe.de/blog/archives/572-less-colors-for-man-pages.html
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(lesspipe)"

# set default browser
if [[ -z "$BROWSER" ]] ; then
    if [[ -n "$DISPLAY" ]] ; then
        export BROWSER=x-www-browser
    else
        export BROWSER=www-browser
    fi
fi

export DEBEMAIL="jan@majutsushi.net"
export DEBFULLNAME="Jan Larres"
export BTS_CACHE=no

export CVS_RSH=ssh
export GDK_USE_XFT=1
export QT_XFT=1
#export GTK_IM_MODULE="scim"
if [[ "$(hostname)" == "gally" ]]; then
    export ALSA_OUTPUT_PORTS="65:0"
    export SCUMMVM_PORT=$ALSA_OUTPUT_PORTS
elif [[ "$(hostname)" == "urd" ]]; then
    export ALSA_OUTPUT_PORTS="128:0"
    export SCUMMVM_PORT=$ALSA_OUTPUT_PORTS
fi

export SDL_AUDIODRIVER=alsa
# export SDL_AUDIODRIVER=dsp # oss

export XDG_DATA_HOME=$HOME/.local/share
export XDG_DATA_DIRS=/usr/local/share/:/usr/share/
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_CACHE_HOME=$HOME/.cache

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/lib

export TEXMFHOME=$HOME/.texmf

export RUBYOPT="-w $RUBYOPT"
export RI="-f ansi"

export TERMINFO=$HOME/.terminfo

export NNTPSERVER=news.gmane.org

# proxy for Uni Passau Network
# export http_proxy=http://www-cache.rz.uni-passau.de:3128
# export HTTP_PROXY=http://www-cache.rz.uni-passau.de:3128
# export ftp_proxy=http://www-cache.rz.uni-passau.de:3128

# ulimit -c unlimited

# }}}

# 'hash' some often used directories {{{
  hash -d deb=/var/cache/apt/archives
  hash -d doc=/usr/share/doc
  hash -d linux=/lib/modules/$(command uname -r)/build/
  hash -d log=/var/log
  hash -d music=/var/lib/mpd/music
  hash -d share=/media/SHARE/share
  hash -d src=/usr/src
  hash -d tt=/usr/share/doc/texttools-doc
  hash -d www=/var/www
  hash -d vuw=~/work/university/VUW/Classes
  hash -d win="/mnt/winxp/Documents and Settings/Jan/Desktop/share"
# }}}

# aliases {{{

typeset -a _ls_opts; _ls_opts=(-F)
# if ls --help 2>/dev/null |grep -- --color= >/dev/null \
if command ls --color=auto >/dev/null 2>&1 \
    && [[ "$TERM" != "dumb" ]]; then
    [[ -f ~/.dir_colors ]] && eval "$(dircolors -b ~/.dir_colors)"
    _ls_opts+="--color=auto"
fi
if command ls --group-directories-first >/dev/null 2>&1; then
    _ls_opts+=--group-directories-first
fi
if ismac; then
    _ls_opts+="-G"
fi
alias ls="LC_COLLATE=POSIX ls $_ls_opts"
alias ll="ls -l"
alias l="ls -lA"
alias lad='ls -d .*(/)'                # only show dot-directories
alias lsa='ls -a .*(.)'                # only show dot-files
alias lss='ls -l *(s,S,t)'             # only files with setgid/setuid/sticky flag
alias lsl='ls -l *(@[1,10])'           # only symlinks
alias lsx='ls -l *(*[1,10])'           # only executables
alias lsw='ls -ld *(R,W,X.^ND/)'       # world-{readable,writable,executable} files
alias lsd='ls -d *(/)'                 # only show directories
alias lse='ls -d *(/^F)'               # only show empty directories

alias t='tree -F'

if [[ $UID == 0 ]]; then
    INTERACTIVE="-i"
fi
alias cp="nocorrect cp --preserve=timestamps $INTERACTIVE" # no spelling correction on cp
alias mv="nocorrect mv $INTERACTIVE"                       # no spelling correction on mv
alias rm="nocorrect rm --one-file-system $INTERACTIVE"     # no spelling correction on rm
alias mkdir="nocorrect mkdir"                              # no spelling correction on mkdir

# defaults for some programs
alias grep='grep -E --color=auto'
alias gdb="gdb -q"
alias mtr="mtr -t"

# general
alias a='ack-grep'
alias da='du -sch'
alias j='jobs -l'
alias pa='ps aux | less'
alias pu='ps ux | less'
alias le='/usr/share/vim/vimcurrent/macros/less.sh'

# shortcuts
alias rd='rmdir'
alias md='mkdir'
alias g="grep"

# programming
alias CO="./configure"
alias CH="./configure --help"
alias make='colormake'
alias ddiff='diff -Naurd -x *.swp -x *.o -x *.so -x cscope.* -x tags -x .git -x .svn -x CVS'

# net
alias wr='wget --recursive --level=inf --convert-links --page-requisites --no-parent'

# prefer normal stat
alias  stat='command stat'
alias zstat='builtin stat'

# cleaning up
alias texclean='rm -f *.toc *.aux *.log *.out *.cp *.fn *.tp *.vr *.pg *.ky *.bbl *.blg'

# ignore ~/.ssh/known_hosts entries
alias insecssh='ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'

# if [[ -n "$TERMINFO" ]] && [[ -f "$TERMINFO/m/mostlike" ]]; then
#     alias man="TERM=mostlike PAGER=less man"
#     alias less="TERM=mostlike less"
# fi

# conversions
alias i2u='iconv --from-code=ISO-8859-15 --to-code=UTF-8'
alias u2i='iconv --from-code=UTF-8 --to-code=ISO-8859-15'
#alias u2d="perl -pe 'chop; $_="$_\r\n";'"
#alias d2u="tr -d '\015\032'"
alias tango2gnome="convert -bordercolor Transparent -border 1x1"

# games
alias wow='startx -- :1 -screen wowscreen'
alias nsrtc="nsrt -savetype jma -safetrim -remhead -rename -deint -fix -md5 -lowext -deldup -noext -sort genre1 -info -utf8 -r"

# if proxy is required
#alias slrn='tsocks /usr/bin/slrn'
#alias mc="tsocks /usr/bin/mc"

# debian stuff
if [[ -r /etc/debian_version ]] ; then
    alias acs='apt-cache search'
    alias acsh='apt-cache show'
    alias acp='apt-cache policy'
    alias afs='apt-file search'
    alias api="$SUDO aptitude install"
    alias dbp='dpkg-buildpackage'
    alias ge='grep-excuses'
    alias muttbts='bts --mailreader="mutt -f %s" --mbox show'
#     alias deborphan-by-size="dpkg-query -W --showformat='${Installed-Size} ${Package}\n' `deborphan -a | awk '{print $2}'` | sort -n"

    alias tlog="tail -f /var/log/syslog"
fi

# misc
alias missingcovers='ls -d /home/jan/media/music/alben/*/*/ | grep -v "$(ls /home/jan/media/music/alben/*/*/cover.jpg | cut -d'/' -f 7,8)" | cut -d'/' -f 7,8'
alias javabug="sudo sed -i 's/XINERAMA/FAKEEXTN/g' /usr/lib/jvm/java-6-sun/jre/lib/i386/xawt/libmawt.so"

# switch terminal encoding (rxvt-unicode only)
alias eucjp="printf '\33]701;%s\007' ja_JP.EUC-JP; export LANG=ja_JP.EUC-JP"
alias utf8="printf '\33]701;%s\007' en_US.UTF-8; export LANG=en_US.UTF-8"

# Xterm resizing-fu. Note that these are utf-8 fonts
alias hide='echo -en "\033]50;nil2\007"'
alias tiny='echo -en "\033]50;-misc-fixed-medium-r-normal--8-80-75-75-c-50-iso10646-1\007"'
alias small='echo -en "\033]50;6x10\007"'
alias default='echo -e "\033]50;-misc-fixed-medium-r-semicondensed--13-*-*-*-*-*-iso10646-1\007"'
alias medium='echo -en "\033]50;-misc-fixed-medium-r-normal--13-120-75-75-c-80-iso10646-1\007"'
alias large='echo -en "\033]50;-misc-fixed-medium-*-*-*-15-*-*-*-*-*-iso10646-1\007"'
# This is a large font that has a corresponding double-width font for 
# CJK and other characters, useful for full-on utf-8 goodness.
alias larger='echo -en "\033]50;-misc-fixed-medium-r-normal--18-*-*-*-*-*-iso10646-1\007"'
alias huge='echo -en "\033]50;-misc-fixed-medium-r-normal--20-200-75-75-c-100-iso10646-1\007"'
alias normal=default

# }}}

# keybindings {{{
## keybindings (run 'bindkeys' for details, more details via man zshzle)
# use emacs style per default:
bindkey -e
# use vi style:
# bindkey -v
# }}}

# power completion - abbreviation expansion {{{
# power completion / abbreviation expansion / buffer expansion
# see http://zshwiki.org/home/examples/zleiab for details
# less risky than the global aliases but powerful as well
# just type the abbreviation key and afterwards ',.' to expand it
declare -A abk
setopt extendedglob
setopt interactivecomments
abk=(
# key  # value
'C'    '| wc -l'
'...' '../..'
'....' '../../..'
'BG' '& exit'
'C' '|wc -l'
'G' '|& grep '
'H' '|head'
'Hl' ' --help |& less -r'
'L' '|less'
'LL' '|& less -r'
'M' '|most'
'N' '&>/dev/null'
'R' '| tr A-z N-za-m'
'SL' '| sort | less'
'S' '| sort -u'
'T' '|tail'
'V' '|& vim -'
'D'  'export DISPLAY=:0.0'
)

globalias () {
    local MATCH
    matched_chars='[.-|_a-zA-Z0-9]#'
    LBUFFER=${LBUFFER%%(#m)[.-|_a-zA-Z0-9]#}
    LBUFFER+=${abk[$MATCH]:-$MATCH}
}

zle -N globalias
bindkey ",." globalias

# }}}

# autoloading {{{
autoload -U zmv
autoload history-search-end

# we don't want to quote/espace URLs on our own...
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

autoload run-help
autoload run-help-git
autoload run-help-svn

# completion system
type compinit &>/dev/null || { autoload -U compinit && compinit -d $XDG_CACHE_HOME/zsh/zcompdump }

autoload -U zed                  # use ZLE editor to edit a file or function

for mod in complist deltochar mathfunc ; do
    zmodload -i zsh/${mod} 2>/dev/null || print "Notice: no ${mod} available :("
done

# autoload zsh modules when they are referenced
for opt mod in a stat \
               a zpty \
               ap zprof \
               ap mapfile; do
    zmodload -${opt} zsh/${mod} ${mod}
done ; unset opt mod

autoload -U insert-files && \
zle -N insert-files && \
bindkey "^Xf" insert-files

bindkey ' '   magic-space    # also do history expansion on space

# press esc-e for editing command line in $EDITOR or $VISUAL
autoload -U edit-command-line && \
zle -N edit-command-line && \
bindkey '\ee' edit-command-line

# menu selection: pick item but stay in the menu (press esc-return)
bindkey -M menuselect '\e^M' accept-and-menu-complete

# press "ctrl-x d" to insert the actual date in the form yyyy-mm-dd
_bkdate() { BUFFER="$BUFFER$(date '+%F')"; CURSOR=$#BUFFER; }
bindkey "^Xd" _bkdate
zle -N _bkdate

# press esc-m for inserting last typed word again (thanks to caphuso!)
insert-last-typed-word() { zle insert-last-word -- 0 -1 }; \
zle -N insert-last-typed-word; bindkey "\em" insert-last-typed-word

# run command line as user root via sudo:
_sudo-command-line() {
  [[ $BUFFER != sudo\ * ]] && LBUFFER="sudo $LBUFFER"
}
zle -N sudo-command-line _sudo-command-line
bindkey "^Xs" sudo-command-line

# }}}

# mime setup {{{

# is42 && autoload -U zsh-mime-setup && zsh-mime-setup

# alias -s pdf=xpdf

# }}}

# options {{{

umask 022

setopt append_history       # append history list to the history file
                            # (important for multiple parallel zsh sessions!)
setopt share_history        # import new commands from the history file
                            # also in other zsh-session
setopt extended_history     # save each command's beginning timestamp
                            # and the duration to the history file
setopt histignorealldups    # If  a  new  command  line being added to the history
                            # list duplicates an older one, the older command
                            # is removed from the list
setopt histignorespace      # remove command lines from the history list when
                            # the first character on the line is a space
setopt auto_cd              # if a command is issued that can't be executed as a
                            # normal command, and the command is the name of a
                            # directory, perform the cd command to that directory
setopt extended_glob        # in order to use #, ~ and ^ for filename generation
                            # grep word *~(*.gz|*.bz|*.bz2|*.zip|*.Z) ->
                            # -> searches for word not in compressed files
                            # don't forget to quote '^', '~' and '#'!
setopt notify               # report the status of backgrounds jobs immediately
setopt nohup                # and don't kill them, either
setopt hash_list_all        # Whenever a command completion is attempted, make sure \
                            # the entire command path is hashed first.
setopt completeinword       # not just at the end
# setopt printexitvalue       # alert me if something failed
setopt auto_pushd           # make cd push the old directory onto the directory stack.
setopt pushd_minus
setopt pushd_ignore_dups
setopt nonomatch            # try to avoid the 'zsh: no matches found...'
setopt nobeep               # avoid "beep"ing
setopt interactivecomments
setopt noclobber            # warn when overwriting files with output redirection
                            # '>!'/'>|' and '>>!'/'>>|' to force
setopt function_argzero     # set $0 to name of current function or script

# ctrl-s will no longer freeze the terminal.
setopt no_flow_control
stty ixoff
stty -ixon

# REPORTTIME=5                # report about cpu-/system-/user-time of command
                            # if running longer than 5 secondes
watch=(notme root)          # watch for everyone but me and root

# define word separators (for stuff like backward-word, forward-word, backward-kill-word,..)
#  WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>' # the default
#  WORDCHARS=.
#  WORDCHARS='*?_[]~=&;!#$%^(){}'
#  WORDCHARS='${WORDCHARS:s@/@}'

# only slash should be considered as a word separator:
slash-backward-kill-word() {
    local WORDCHARS="${WORDCHARS:s@/@}"
    # zle backward-word
    zle backward-kill-word
}
zle -N slash-backward-kill-word
# press esc-w (meta-w) to delete a word until its last '/' (not the same as ctrl-w!)
bindkey '\ew' slash-backward-kill-word

# }}}

# history {{{
HISTFILE=$XDG_CACHE_HOME/zsh/history
HISTSIZE=5000
SAVEHIST=10000
# }}}

# dirstack handling {{{
DIRSTACKSIZE=20
if [[ -f $XDG_CACHE_HOME/zsh/zdirs ]] && [[ ${#dirstack[*]} -eq 0 ]]; then
    dirstack=( ${(uf)"$(< $XDG_CACHE_HOME/zsh/zdirs)"} )
    # "cd -" won't work after login by just setting $OLDPWD, so
    if [[ -d $dirstack[0] ]]; then
        cd $dirstack[0] && cd $OLDPWD
    fi
fi
chpwd() {
    builtin dirs -pl >! $XDG_CACHE_HOME/zsh/zdirs
}
# }}}

# prompt {{{

autoload promptinit && promptinit

if is43 ; then
    ARROW="»"
else
    ARROW=">"
fi

precmd () {

    # handle deleted and then recreated directories
    if ! [[ . -ef $PWD ]]; then
         OLDOLDPWD="${OLDPWD}"
         if ! cd -- "${PWD}" >/dev/null 2>&1; then
            echo "W: ${PWD} does not exist anymore"
            return 1
         fi
         OLDPWD="${OLDOLDPWD}"
    fi

    JOBS="%(1j.${C_BOLD}[${C_F_CYAN}%j${C_F_DEFAULT}].)"
    EXITCODE="%(0?..${C_BOLD}[${C_F_RED}%?${C_F_DEFAULT}])"

    # set variable debian_chroot if running in a chroot with /etc/debian_chroot
    if [[ -z "$debian_chroot" ]] && [[ -r /etc/debian_chroot ]]; then
        debian_chroot=$(cat /etc/debian_chroot)
    fi

    # test ibam
    # BATTSTATE="$(ibam --percentbattery)"
    # BATTPRCNT="${BATTSTATE[(f)1][(w)-2]}"
    # BATTTIME="${BATTSTATE[(f)2][(w)-1]}"
    if command -v acpi >/dev/null 2>&1; then
        ACPI=$(acpi -b | grep -i discharging)
        if [[ -n "$ACPI" ]]; then
            PERCENT=$(echo $ACPI | cut -d',' -f 2 | tr -d " %")
            # PERCENT=${(s|,|)=${(s| |)ACPI}[4]}
            if [[ ${PERCENT} -gt 50 ]]; then
                BATTERY="($C_F_GREEN${PERCENT}%%$C_F_DEFAULT)"
            elif [[ ${PERCENT} -gt 15 ]]; then
                BATTERY="($C_F_YELLOW${PERCENT}%%$C_F_DEFAULT)"
            else
                BATTERY="($C_F_RED${PERCENT}%%$C_F_DEFAULT)"
            fi
        else
            BATTERY=""
        fi
    fi

    # test if we have writing permission for the current directory
    if [[ -w "$(pwd)" ]]; then
        WPERM=
    else
        WPERM="$C_F_RED!$C_F_DEFAULT"
    fi

#     ┌─[x]──────────────────────────────────────────────────────[x]─┐
#     └─[x]─── COMMANDS                                       ───[x]─┘

    vcs_info
    prompt_set_line_1
    prompt_set_line_2

    RPS1="${vcs_info_msg_1_:+${C_BOLD}<${C_F_RED}${vcs_info_msg_1_}${C_F_DEFAULT}>${C_DEFAULT}}"
    # adjust title of xterm
    # see http://www.faqs.org/docs/Linux-mini/Xterm-Title.html
    case $TERM in (xterm*|rxvt*|screen*)
        print -Pn "\e]0;%n@%m: %~\a"
        ;;
    esac
    if [[ "$TERM" == screen* ]]; then
        if [[ -n "$SSH_CLIENT" ]]; then
            print -Pn "\ek%m\e\\"
        else
            echo -ne "\ekzsh\e\\"
        fi
    fi
}

prompt_set_line_1 () {

#     local left_left="${C_BOLD}[($C_F_GREEN"
#     local left_left="${C_BOLD}${C_F_RED}┌${C_F_DEFAULT}($C_F_GREEN"
    local left_left="${PR_SET_CHARSET}${C_BOLD}${C_F_RED}${PR_SHIFT_IN}${PR_ULCORNER}${PR_SHIFT_OUT}${C_F_DEFAULT}($C_F_GREEN"
#     local left_dir="$CPATH"
    local left_dir="${${vcs_info_msg_0_/#${HOME}/~}%%/.}"
    local left_right="$C_F_DEFAULT$WPERM)"
    local left_side=$left_left$left_dir$left_right
    local right_side="---$BATTERY($C_F_CYAN%D{%H:%M:%S}$C_F_DEFAULT)]$C_DEFAULT"

    local left_side_width=${(m)#${(S%%)left_side//\%\{*\%\}/}}
    local right_side_width=${(m)#${(S%%)right_side//\%\{*\%\}/}}

    local padding_size=$(( COLUMNS - left_side_width - right_side_width ))

    # test if dir fits in the line, otherwise truncate it on the left
    if (( padding_size > 0 )); then
        local padding="${(l:${padding_size}::-:)""}"
        prompt_line_1="$left_side$padding$right_side"
        return
    else
        local left_left_width=${(m)#${(S%%)left_left//\%\{*\%\}/}}
        local left_right_width=${(m)#${(S%%)left_right//\%\{*\%\}/}}
        local rest_size=$(( left_left_width + left_right_width + right_side_width ))
        local max_size=$(( COLUMNS - rest_size ))
        prompt_line_1="$left_left%$max_size<...<${left_dir}%<<$left_right$right_side"
        return
    fi
}

prompt_set_line_2 () {
#     local p_arrow="${C_BOLD}${C_F_RED}${ARROW}${C_F_DEFAULT}"
#     local p_arrow="${C_BOLD}${C_F_RED}└${C_F_DEFAULT}"
    local p_arrow="${C_BOLD}${C_F_RED}${PR_SHIFT_IN}${PR_LLCORNER}${PR_SHIFT_OUT}${C_F_DEFAULT}"
    local p_info="${JOBS}${EXITCODE}"
    local p_user="($C_ROOT%n$C_F_YELLOW@$C_F_DEFAULT"
    local p_host="${SSH_CLIENT:+${C_F_GREEN}}%m${C_F_DEFAULT})${C_DEFAULT}"
    local p_rest=" %(!.#.>) "
    prompt_line_2=${p_arrow}${p_info}${p_user}${p_host}${p_rest}
    return
}

setprompt () {
    setopt prompt_subst

    # setup alternate character set
    # http://aperiodic.net/phil/prompt/
    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    PR_HBAR=${altchar[q]:--}
    PR_ULCORNER=${altchar[l]:--}
    PR_LLCORNER=${altchar[m]:--}
    PR_LRCORNER=${altchar[j]:--}
    PR_URCORNER=${altchar[k]:--}

    # set colors
    autoload colors && colors

    C_DEFAULT="%{${reset_color}%}"
    C_BOLD="%{${bold_color}%}"

    # Foreground colors
    for COLOR in BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE DEFAULT; do
        eval C_F_$COLOR='%{$fg[${(L)COLOR}]%}'
    done

    if [[ $UID == 0 ]]; then
        C_ROOT=$C_F_RED
    fi

    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git hg
    zstyle ':vcs_info:*' nvcsformats   '%~'
    zstyle ':vcs_info:*' formats       '%R'${C_F_DEFAULT}'['${C_F_YELLOW}'%s'${C_F_DEFAULT}':'${C_F_YELLOW}'%b'${C_F_DEFAULT}']'${C_F_GREEN}'/%S'
    zstyle ':vcs_info:*' actionformats '%R'${C_F_DEFAULT}'['${C_F_YELLOW}'%s'${C_F_DEFAULT}':'${C_F_YELLOW}'%b'${C_F_DEFAULT}']'${C_F_GREEN}'/%S' '%a'

    if [[ "$TERM" != "dumb" ]]; then
        PS1='$prompt_line_1$prompt_newline$prompt_line_2'
    else
        PS1="${EXITCODE}${debian_chroot:+($debian_chroot)}%n@%m %40<...<%B%~%b%<< %# "
    fi

    PS2="${C_BOLD}${C_F_RED}${ARROW}${C_DEFAULT} ${C_BOLD}%_${C_DEFAULT} %(!.#.>) "
    PS3='?# '         # selection prompt used within a select loop.
    PS4='+%N:%i:%_> ' # the execution trace prompt (setopt xtrace). default: '+%N:%i>'
}

preexec () {
    # get the name of the program currently running and hostname of local machine
    # set screen window title if running in a screen
    if [[ "$TERM" == screen* ]]; then
        local CMD="${1[(wr)^(*=*|sudo|ssh|-*)]}${SSH_CLIENT:+@$HOST}"
        echo -ne "\ek$CMD\e\\"
    fi
    # adjust title of xterm
    case $TERM in (xterm*|rxvt*|screen*)
        print -Pn "\e]0;%n@%m: $1\a"
        ;;
    esac
}

setprompt

# }}}

# completion stuff {{{

# notice: use 'zstyle' for getting current settings
# press ^Xh (control-x h) for getting tags in context; ^X? (control-x ?) to run complete_debug with trace output

## completion system
# allow one error for every three characters typed in approximate completer
zstyle ':completion:*:approximate:'    max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )'
# don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'
# start menu completion only if it could find no unambiguous initial string
zstyle ':completion:*:correct:*'       insert-unambiguous true
zstyle ':completion:*:correct:*'       original true
zstyle ':completion:*:corrections'     format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
# activate color-completion(!)
zstyle ':completion:*:default'         list-colors ${(s.:.)LS_COLORS}
# format on completion
zstyle ':completion:*:descriptions'    format $'%{\e[0;32m%}completing %B%d%b%{\e[0m%}'
# complete 'cd -<tab>' with menu
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
# complete '..'
zstyle ':completion:*'                 special-dirs true
# insert all expansions for expand completer
zstyle ':completion:*:expand:*'        tag-order all-expansions
zstyle ':completion:*:history-words'   list false
# activate menu
zstyle ':completion:*:history-words'   menu yes
# ignore duplicate entries
zstyle ':completion:*:history-words'   remove-all-dups yes
zstyle ':completion:*:history-words'   stop yes
# match uppercase from lowercase
zstyle ':completion:*'                 matcher-list 'm:{a-z}={A-Z}'
# separate matches into groups
zstyle ':completion:*:matches'         group 'yes'
zstyle ':completion:*'                 group-name ''
# if there are more than 1 options allow selecting from a menu
zstyle ':completion:*'                 menu select=1
zstyle ':completion:*:messages'        format '%d'
zstyle ':completion:*:options'         auto-description '%d'
# describe options in full
zstyle ':completion:*:options'         description 'yes'
# on processes completion complete all user processes
zstyle ':completion:*:processes'       command 'ps -au$USER'
# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
# provide verbose completion information
zstyle ':completion:*'                 verbose true
# set format for warnings
zstyle ':completion:*:warnings'        format $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'
# define files to ignore for zcompile
zstyle ':completion:*:*:zcompile:*'    ignored-patterns '(*~|*.zwc)'
zstyle ':completion:correct:'          prompt 'correct to: %e'
# Ignore completion functions for commands you don't have:
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'

zstyle ':completion:*:*:(^rm):*:*' ignored-patterns '*(.o|~)' '#*#(D)'

# complete manual by their section
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes no-select

## correction
# run rehash on completion so new installed program are found automatically:
_force_rehash() {
    (( CURRENT == 1 )) && rehash
    return 1 # Because we didn't really complete anything
}
# some people don't like the automatic correction - so run 'NOCOR=1 zsh' to deactivate it
if [[ -n "$NOCOR" ]] ; then
    zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete
    setopt nocorrect # do not try to correct the spelling if possible
else
    setopt correct  # try to correct the spelling if possible
    zstyle -e ':completion:*' completer '
    if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]]; then
        _last_try="$HISTNO$BUFFER$CURSOR"
        reply=(_complete _match _prefix)
    else
        if [[ $words[1] == (rm|mv) ]]; then
            reply=(_complete)
        else
            reply=(_oldlist _expand _force_rehash _complete _correct _approximate)
        fi
    fi'
fi

# command for process lists, the local web server details and host completion
zstyle ':completion:*:urls' local 'www' '/var/www/' 'public_html'

# caching
[[ -d $XDG_CACHE_HOME/zsh/cache ]] && zstyle ':completion:*' use-cache yes && \
zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/cache/

# host completion /* add brackets as vim can't parse zsh's complex cmdlines 8-) {{{ */
if is42 ; then
    [[ -r ~/.ssh/known_hosts ]] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
    [[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
else
    _ssh_hosts=()
    _etc_hosts=()
fi
hosts=(
$(hostname)
"$_ssh_hosts[@]"
"$_etc_hosts[@]"
localhost
majutsushi.net
)
zstyle ':completion:*:hosts' hosts $hosts

# use generic completion system for programs not yet defined:
compdef _gnu_generic tail head feh cp mv df stow uname ipacsum fetchipac
# }}}

# functions {{{
freload() { while (( $# )); do; unfunction $1; autoload -U $1; shift; done }
compdef _functions freload

# use "dchange <package-name>" to view Debian's changelog of the package:
dchange() {
    if [[ -r /usr/share/doc/${1}/changelog.Debian.gz ]] ; then
        less /usr/share/doc/${1}/changelog.Debian.gz
    else
        if [[ -r /usr/share/doc/${1}/changelog.gz ]] ; then
            less /usr/share/doc/${1}/changelog.gz
        else
            echo "No changelog for package $1 found, sorry."
            return 1
        fi
    fi
}
_dchange() { _files -W /usr/share/doc -/ }
compdef _dchange dchange

# use "uchange <package-name>" to view upstream's changelog of the package:
uchange() {
    if [[ -r /usr/share/doc/${1}/changelog.gz ]] ; then
        less /usr/share/doc/${1}/changelog.gz
    else
        echo "No changelog for package $1 found, sorry."
        return 1
    fi
}
_uchange() { _files -W /usr/share/doc -/ }
compdef _uchange uchange

# zsh profiling
profile () {
    ZSH_PROFILE_RC=1 $SHELL "$@"
}

# edit alias via zle:
edalias() {
    [[ -z "$1" ]] && { echo "Usage: edalias <alias_to_edit>" ; return 1 } || vared aliases'[$1]' ;
}
compdef _aliases edalias

# edit function via zle:
edfunc() {
    [[ -z "$1" ]] && { echo "Usage: edfunc <function_to_edit>" ; return 1 } || zed -f "$1" ;
}
compdef _functions edfunc

# use it e.g. via 'Restart apache2'
if [[ -d /etc/init.d ]] ; then
    for i in Start Restart Stop Force-Reload Reload ; do
        eval "$i() { $SUDO /etc/init.d/\$1 ${i:l} \$2 ; }"
    done
    # now the completion for this:
    compctl -g "$(echo /etc/init.d/*(:t))" Start Restart Stop Force-Reload Reload
fi

# grep for running process, like: 'psgrep vim'
psgrep() {
    if [[ -z "$1" ]] ; then
        echo "any - grep for process(es) by keyword" >&2
        echo "Usage: any <keyword>" >&2 ; return 1
    else
        local STRING=$1
        local LENGTH=$(expr length $STRING)
        local FIRSCHAR=$(echo $(expr substr $STRING 1 1))
        local REST=$(echo $(expr substr $STRING 2 $LENGTH))
        ps xauwww| grep "[$FIRSCHAR]$REST"
    fi
}

# After resuming from suspend, system is paging heavilly, leading to very bad interactivity.
# taken from $LINUX-KERNELSOURCE/Documentation/power/swsusp.txt
[ -r /proc/1/maps ] && deswap() {
    print 'Reading /proc/[0-9]*/maps and sending output to /dev/null, this might take a while.'
    cat $(sed -ne 's:.* /:/:p' /proc/[0-9]*/maps | sort -u | grep -v '^/dev/')  > /dev/null
    print 'Finished, running "swapoff -a; swapon -a" may also be useful.'
}

# functions without detailed explanation:
bk()      { cp -r -b ${1} ${1}_$(date --iso-8601=m) }
disassemble(){ gcc -pipe -S -o - -O -g $* | as -aldh -o /dev/null }
mdiff()   { diff -udrP "$1" "$2" > diff.$(date "+%Y-%m-%d")."$1" }
netcraft(){ ${=BROWSER} "http://toolbar.netcraft.com/site_report?url=$1" }
oleo()    { ${=BROWSER} "http://dict.leo.org/?search=$*" }
swiki()   { ${=BROWSER} http://de.wikipedia.org/wiki/Spezial:Search/${(C)1} }
wodeb ()  { ${=BROWSER} "http://packages.debian.org/cgi-bin/search_contents.pl?word=$1&version=${2:-unstable}" }
vman()    { man $* | vim --cmd 'let no_plugin_maps = 1' -c 'runtime! macros/less.vim' -c 'set ft=man nolist' - }
2html()   { gvim -f -n +"syntax on" +"run! syntax/2html.vim" +"wq" +"q" $1 }
sshot()   { scrot '%Y-%m-%d-%H%M%S_$wx$h.png' -e 'mv $f ~/media/desk/screenshots/' }

# http://ft.bewatermyfriend.org/comp/zsh/zfunct.html
hl() {
    if [[ -z ${2} ]] || (( ${#argv} > 2 )) ; then
        printf 'usage: hl <syntax> <file>\n'
        return 1
    fi
    highlight --xterm256 --syntax $1 --style darkness $2 | less
}

# upload()  { scp -p $1 cip:public_html/$2 }
upload() {
    if [[ -z "$1" ]]; then
        echo "usage: upload file1 file2 ..."
        return 1
    else
        wput ftp://majutsushi.net/httpdocs/stuff/ "$@"
    fi
    for i in "$@"; do
        echo "http://majutsushi.net/stuff/${i// /%20}"
    done
}

uploadshot() {
    for i in $@; do
        local target=${i%png}jpg
        convert $i $target
        scp -p $target cip:public_html/shots/
        rm $target
    done
}

wp() {
    dig +short txt ${1// /_}.wp.dg.cx
}

flv2ogg() {
#    ffmpeg -i $1 -ab 56 -ar 22050 -b 500 ${1%flv}mpg
    ffmpeg2theora --audiobitrate 56 --samplerate 22050 --videobitrate 500 --sync $1
}

wma2ogg() {
    for i in "$@"; do
        mplayer -vo null -vc dummy -af resample=44100 -ao pcm:waveheader:file=temp.wav "$i" && oggenc -o "${i%.wma}".ogg temp.wav
    done
    rm temp.wav
}

mkvrepack() {
    local name="${1:r}"
    mkvextract tracks "$1" 1:"${name}".raw
    avi2raw "${name}".raw "${name}".264 && rm "${name}".raw
    MP4Box -fps 29.970628 -add "${name}".264 "${name}".mp4 && rm "${name}".264
}

gensystags() {
    echo "Generating vim systags"
    ctags -f ~/.vim/systags/systags --recurse --verbose --totals=yes --extra=+q /usr/include
}

pdf2pdf() {
    if [[ $# != 2 ]]; then
        echo "Usage: $0 input.pdf output.pdf"
        return 1
    else
        gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -sOutputFile=$2 $1
    fi
}

zza() {
  NAMED_DIRECTORY=$PWD:t
  eval $NAMED_DIRECTORY=$PWD
  cd ~$NAMED_DIRECTORY
}

# Function Usage: doc packagename
doc() { cd /usr/share/doc/$1 && ll }
_doc() { _files -W /usr/share/doc -/ }
compdef _doc doc

# create pdf file from source code
makereadable() {
    output=$1
    shift
    a2ps --medium A4dj -E -o $output $*
    ps2pdf $output
}

# zsh with perl-regex - use it e.g. via:
# regcheck '\s\d\.\d{3}\.\d{3} Euro' ' 1.000.000 Euro'
regcheck() {
    zmodload -i zsh/pcre
    pcre_compile $1 && \
    pcre_match $2 && echo "regex matches" || echo "regex does not match"
}

# find out which libs define a symbol
# usage example: 'lcheck strcpy'
lcheck() {
    if [[ -n "$1" ]] ; then
        nm -go /usr/lib/lib*.a 2>/dev/null | grep ":[[:xdigit:]]\{8\} . .*$1" | grep "$1"
    else
        echo "Usage: lcheck <function>" >&2
    fi
}

# clean up directory
purge() {
    FILES=(*~(N) .*~(N) \#*\#(N) *.o(N) a.out(N) *.core(N) *.cmo(N) *.cmi(N) .*.swp(N))
    NBFILES=${#FILES}
    if [[ $NBFILES > 0 ]]; then
        print $FILES
        local ans
        echo -n "Remove these files? [y/n] "
        read -q ans
        if [[ $ans == "y" ]]
        then
            rm ${FILES}
            echo ">> $PWD purged, $NBFILES files removed"
        else
            echo "Nothing done"
        fi
    fi
}

# Some quick Perl-hacks aka /useful/ oneliner
getlinks ()   { perl -ne 'while ( m/"((www|ftp|http):\/\/.*?)"/gc ) { print $1, "\n"; }' $* }
gethrefs ()   { perl -ne 'while ( m/href="([^"]*)"/gc ) { print $1, "\n"; }' $* }
getanames ()  { perl -ne 'while ( m/a name="([^"]*)"/gc ) { print $1, "\n"; }' $* }
getforms ()   { perl -ne 'while ( m:(\</?(input|form|select|option).*?\>):gic ) { print $1, "\n"; }' $* }
getstrings () { perl -ne 'while ( m/"(.*?)"/gc ) { print $1, "\n"; }' $*}
getanchors () { perl -ne 'while ( m/«([^«»\n]+)»/gc ) { print $1, "\n"; }' $* }

# plap foo -- list all occurrences of program in the current PATH
plap() {
    if [[ $# == 0 ]]
    then
        echo "Usage:    $0 program"
        echo "Example:  $0 zsh"
        echo "Lists all occurrences of program in the current PATH."
    else
        ls -l ${^path}/*$1*(*N)
    fi
}

# Found in the mailinglistarchive from Zsh (IIRC ~1996)
selhist() {
    emulate -L zsh
    local TAB=$'\t';
    (( $# < 1 )) && {
        echo "Usage: $0 command"
        return 1
    };
    cmd=(${(f)"$(grep -w $1 $HISTFILE | sort | uniq | pr -tn)"})
    print -l $cmd | less -F
    echo -n "enter number of desired command [1 - $(( ${#cmd[@]} - 1 ))]: "
    local answer
    read answer
    [[ -n "$answer" ]] && print -z "${cmd[$answer]#*$TAB}"
}

# mkdir && cd
mcd() { mkdir -p "$@"; cd "$@" }

#   findsuid() {
#     print 'Output will be written to ~/suid_* ...'
#     $SUDO find / -type f \( -perm -4000 -o -perm -2000 \) -ls > ~/suid_suidfiles.$(date "+%Y-%m-%d").out 2>&1
#     $SUDO find / -type d \( -perm -4000 -o -perm -2000 \) -ls > ~/suid_suiddirs.$(date "+%Y-%m-%d").out 2>&1
#     $SUDO find / -type f \( -perm -2 -o -perm -20 \) -ls > ~/suid_writefiles.$(date "+%Y-%m-%d").out 2>&1
#     $SUDO find / -type d \( -perm -2 -o -perm -20 \) -ls > ~/suid_writedirs.$(date "+%Y-%m-%d").out 2>&1
#     print 'Finished'
#   }

# % slow_print `cat /etc/passwd`
slow_print() {
    while [[ "$1" != "" ]]; do
        for ((i = 1; i <= ${#1}; i++)) {
            print -n "${1[i]}"
            sleep 0.08
        }
        print -n " "
        shift
    done
    print ""
}

# display system state
status() {
    print ""
    print "Date..: "$(date "+%Y-%m-%d %H:%M:%S")""
    print "Shell.: Zsh $ZSH_VERSION (PID = $$, $SHLVL nests)"
    print "Term..: $TTY ($TERM), $BAUD bauds, $COLUMNS x $LINES chars"
    print "Login.: $LOGNAME (UID = $EUID) on $HOST"
    print "System: $(cat /etc/[A-Za-z]*[_-][rv]e[lr]*)"
    print "Uptime:$(uptime)"
    print ""
}

# Make an audio CD from all mp3 files
#   mkaudiocd() {
#         cd ~/ripps
#         for i in *.[Mm][Pp]3; do mv "$i" $(echo $i | tr '[A-Z]' '[a-z]'); done
#         for i in *.mp3; do mv "$i" $(echo $i | tr ' ' '_'); done
#         for i in *.mp3; do mpg123 -w $(basename $i .mp3).wav $i; done
#         normalize -m *.wav
#         for i in *.wav; do sox $i.wav -r 44100 $i.wav resample; done
#   }

# Create an ISO image. You are prompted for volume name, filename and directory
mkiso() {
    echo " * Volume name "
    read volume
    echo " * ISO Name (ie. tmp.iso)"
    read iso
    echo " * Directory or File"
    read files
    mkisofs -o ~/$iso -A $volume -allow-multidot -J -R -iso-level 3 -V $volume -R $files
}

# RFC 2396 URL encoding in Z-Shell
urlencode() {
    setopt localoptions extendedglob
    input=( ${(s::)1} )
    print ${(j::)input/(#b)([^A-Za-z0-9_.!~*\'\(\)-])/%$(([##16]#match))}
}

# backup important dirs
rs-important() {
    if [[ -z $1 ]]; then
        echo "usage: rs-important dest-dir"
        return 1
    fi

    rsync -vaxEHAX \
        --delete \
        --delete-excluded \
        --ignore-errors \
        --progress \
        --exclude=/.local/share/Trash/** \
        $HOME/.etc \
        $HOME/.mozilla \
        $HOME/.config \
        $HOME/.local \
        $HOME/.evolution \
        $HOME/.fceultra \
        $HOME/.fceux \
        $HOME/.gnome2 \
        $HOME/.gnupg \
        $HOME/.liferea_1.6 \
        $HOME/.offlineimap \
        $HOME/.openttd \
        $HOME/.purple \
        $HOME/.scummvm \
        $HOME/.ssh \
        $HOME/.zsnes \
        $HOME/.forward \
        $HOME/.netrc \
        $HOME/.offlineimaprc \
        $HOME/.scummvmrc \
        $HOME/Photos \
        $HOME/bin \
        $HOME/games \
        $HOME/projects \
        $HOME/src \
        $HOME/work \
        $1
}

# get specific git commitdiff
git-get-diff() {
    if [[ -z $GITTREE ]] ; then
        GITTREE='linux/kernel/git/torvalds/linux-2.6.git'
    fi
    if ! [[ -z $1 ]] ; then
        ${=BROWSER} "http://kernel.org/git/?p=$GITTREE;a=commitdiff;h=$1"
    else
        echo "Usage: git-get-diff <commit>"
    fi
}

# get specific git commit
git-get-commit() {
    if [[ -z $GITTREE ]] ; then
        GITTREE='linux/kernel/git/torvalds/linux-2.6.git'
    fi
    if ! [[ -z $1 ]] ; then
        ${=BROWSER} "http://kernel.org/git/?p=$GITTREE;a=commit;h=$1"
    else
        echo "Usage: git-get-commit <commit>"
    fi
}

# get specific git diff
git-get-plaindiff() {
    if [[ -z $GITTREE ]] ; then
        GITTREE='linux/kernel/git/torvalds/linux-2.6.git'
    fi
    if ! [[ -z $1 ]] ; then
        wget "http://kernel.org/git/?p=$GITTREE;a=commitdiff_plain;h=$1" -O $1.diff
    else
        echo 'Usage: git-get-plaindiff '
    fi
}

# log 'make install' output
# http://strcat.de/blog/index.php?/archives/335-Software-sauber-deinstallieren...html
mmake() {
    [[ ! -d ~/.errorlogs ]] && mkdir ~/.errorlogs
    =make -n install > ~/.errorlogs/${PWD##*/}-makelog
}
# }}}

# screen {{{
# 'rxvt' is needed for dvtm
if [[ "$TERM" != screen* ]] && [[ "$TERM" != "rxvt" ]]; then
    screen -m
fi
# }}}

# vim:foldmethod=marker
