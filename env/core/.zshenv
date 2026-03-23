# minimal configuration for moving the zsh config location
ZDOTDIR=$HOME/.config/zsh

# load modular environment variables and paths
if [ -d "$ZDOTDIR/env.d" ]; then
    for f in "$ZDOTDIR/env.d/"*.zsh(N); do
        source "$f"
    done
fi
