# lib/utils.sh

# --- Global State ---
# This variable caches the decrypted vault in RAM during the script execution
declare -g _SECRET_CACHE=""

# --- Secret Engine ---
get_secret() {
    local key="$1"
    local out_var="$2" # The name of the variable we will inject the secret into
    local secret_file="$PROJECT_ROOT/secret.asc"

    # 1. Decrypt into memory ONLY if the cache is currently empty
    if [[ -z "$_SECRET_CACHE" ]]; then
        if [[ ! -f "$secret_file" ]]; then
            log_error "Secret file not found: $secret_file" >&2
            return 1
        fi
        
        log_info "Unlocking secrets vault..." >&2
        export GPG_TTY=$(tty)
        gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
        
        if ! _SECRET_CACHE=$(gpg --quiet --no-symkey-cache --decrypt "$secret_file" 2>/dev/null); then
            log_error "Failed to decrypt secrets. Check terminal ownership." >&2
            _SECRET_CACHE=""
            return 1
        fi
    fi

    # 2. Extract the requested key using jq
    local value
    value=$(printf "%s\n" "$_SECRET_CACHE" | jq -r ".${key} // empty")
    
    if [[ -n "$value" ]]; then
        # 3. Safely inject the value directly into the requested variable name
        printf -v "$out_var" "%s" "$value"
    else
        log_warn "Secret key '${key}' not found in vault." >&2
        return 1
    fi
}

