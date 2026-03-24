# ----------------------------------- Zinit ------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

# --------------------------------- Completion ---------------------------------
autoload -Uz compinit && compinit
zinit cdreplay -q
# Make tab-completion case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# Use LS_COLORS to colorize completion menus
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# Disable the legacy completion menu to let fzf-tab take over
zstyle ':completion:*' menu no
# Configure fzf-tab previews
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# --------------------------------- Bindings -----------------------------------
bindkey -v
export VI_MODE_SET_CURSOR=true

# History search (Up/Down arrows matching typed prefix)
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Execute tmux-sessionizer directly from the prompt
bindkey -s '^f' "tmux-sessionizer\n"

# ---------------------------------- Aliases -----------------------------------
alias ls='ls --color=auto'
# Keyboard mapping
alias aoei="setxkbmap gb -option 'caps:swapescape'"
alias asdf="xkbcomp ~/.config/keyboard/custom.xkb '$DISPLAY'"

# ----------------------------------- History ----------------------------------
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt append_history share_history hist_ignore_all_dups hist_ignore_space

# -------------------------------- Core Tools ----------------------------------
eval "$(starship init zsh)"

# include fzf
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi

# -------------------------------- Load Modules --------------------------------
if [ -d "$ZDOTDIR/conf.d" ]; then
    for f in "$ZDOTDIR/conf.d/"*.zsh(N); do
        source "$f"
    done
fi

