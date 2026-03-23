# Load modular interactive configurations (aliases, functions)
if [ -d "$ZDOTDIR/conf.d" ]; then
    for f in "$ZDOTDIR/conf.d/"*.zsh(N); do
        source "$f"
    done
fi

# alias mountonedrive="rclone --vfs-cache-mode writes mount onedrive: ~/Resources/onedrive/ &"
alias mountonedrive="rclone mount onedrive: ~/Resources/onedrive/ --vfs-cache-mode writes --rc &"
# return message if umountonedrive doesn't work
alias umountonedrive="fusermount -u ~/Resources/onedrive/ && echo 'onedrive unmounted' || echo 'onedrive unmount failed'"


eval "$(starship init zsh)"


. "$HOME/.cargo/env"
