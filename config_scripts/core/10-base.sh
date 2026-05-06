#!/usr/bin/env bash

# -------------------------------- Basic Stow ----------------------------------
log_info "Configuring core"

check_deps stow || return 1

system_stow core

if [[ $DRY_RUN -eq 0 ]]; then
    if [[ "$SHELL" != *"zsh"* ]] && command -v zsh &>/dev/null; then
        log_info "Changing default shell to ZSH..."
        chsh -s "$(command -v zsh)"
    fi
fi

log_pass "Core configuration complete."


