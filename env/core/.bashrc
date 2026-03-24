
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Immediately route Bash to the XDG-compliant directory
if [ -f "$HOME/.config/bash/bashrc" ]; then
    source "$HOME/.config/bash/bashrc"
fi
