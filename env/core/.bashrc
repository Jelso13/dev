
# add vim bindings
set -o vi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth


# append to the history file, don't overwrite it
shopt -s histappend


# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000


alias aoei="setxkbmap gb -option 'caps:swapescape'"
# alias asdf="xmodmap ~/.config/keyboard/xmodmap/xmodmap"
alias asdf="xkbcomp ~/.config/keyboard/custom.xkb '$DISPLAY'"

eval "$(starship init bash)"
