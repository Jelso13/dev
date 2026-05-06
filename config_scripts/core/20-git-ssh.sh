
# ------------------------------------ SSH & Git ------------------------------
#
log_info "=== Configuring SSH & Git ==="

check_deps jq git ssh-keyscan || return 1

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if ! ssh-keygen -F github.com &>/dev/null; then
    log_info "Adding github.com to known_hosts..."
    if [[ $DRY_RUN -eq 0 ]]; then
        ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
    fi
else
    log_pass "github.com is already in known_hosts."
fi

# 2. Deploy Git Identity (Pass-by-reference, no subshells!)
local git_name=""
local git_email=""

# Notice the syntax: get_secret "key.path" variable_name
get_secret "git.name" git_name 
get_secret "git.email" git_email

if [[ -n "$git_name" && -n "$git_email" ]]; then
    mkdir -p "$HOME/.config/git"
    local git_local="$HOME/.config/git/config.local"
    
    if [[ $DRY_RUN -eq 0 ]]; then
        git config --file "$git_local" user.name "$git_name"
        git config --file "$git_local" user.email "$git_email"
        log_pass "Git configured locally for $git_name <$git_email>"
    else
        log_info "[DRY_RUN] Would configure Git identity in $git_local"
    fi
fi

# 3. Deploy SSH Key
local ssh_key=""

get_secret "ssh.private_key" ssh_key

if [[ -n "$ssh_key" ]]; then
    if [[ $DRY_RUN -eq 0 ]]; then
        printf "%s\n" "$ssh_key" > "$HOME/.ssh/id_rsa"
        chmod 600 "$HOME/.ssh/id_rsa"
        log_pass "SSH private key deployed."
    else
        log_info "[DRY_RUN] Would deploy SSH private key."
    fi
fi
