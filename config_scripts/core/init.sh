#!/usr/bin/env bash

log_info "=== Starting Core Configuration Suite ==="
local core_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Basic environment and Stowing
source "$core_dir/10-base.sh"

# 2. Secure Identity Setup
source "$core_dir/20-git-ssh.sh"

source "$core_dir/30-nvim.sh"

log_pass "Core Configuration Suite Complete"
