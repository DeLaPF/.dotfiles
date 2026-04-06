# zenv - shell environment manager (zsh-only direnv alternative)
# Manages env vars, aliases, and functions from .envrc files
# with automatic loading/unloading on directory change
#
# LIMITATION: only one .envrc is active at a time. Walks up from $PWD
# and loads the nearest .envrc. Does not stack parent .envrc files like
# direnv's `source_env`. To support stacking, would need an array of
# loaded dirs + per-file diff tracking + reverse-order restore.

# Tracks only what .envrc changed (added or modified)
typeset -gA _zenv_added_env       # key -> ""  (new vars to unset on restore)
typeset -gA _zenv_changed_env     # key -> old_value  (changed vars to restore)
typeset -gA _zenv_added_aliases   # key -> ""
typeset -gA _zenv_changed_aliases # key -> old_value
typeset -gA _zenv_added_funcs     # key -> ""
typeset -gA _zenv_changed_funcs   # key -> old_body
typeset -g _zenv_loaded_dir=""
typeset -g _zenv_loaded_hash=""
typeset -g _zenv_allow_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zenv/allowed"

# --- Security ---

_zenv_hash() {
    shasum -a 256 "$1" 2>/dev/null | cut -d' ' -f1
}

_zenv_allow_file() {
    local dir="$1"
    echo "$_zenv_allow_dir/$(echo "$dir" | shasum -a 256 | cut -d' ' -f1)"
}

zenv-allow() {
    local envrc="${1:-$PWD/.envrc}"
    [ -f "$envrc" ] || { echo "No .envrc found" >&2; return 1; }
    mkdir -p "$_zenv_allow_dir"
    _zenv_hash "$envrc" > "$(_zenv_allow_file "$(dirname "$envrc")")"
    echo "zenv: allowed $(dirname "$envrc")/.envrc"
    _zenv_hook
}

zenv-deny() {
    local dir="${1:-$PWD}"
    rm -f "$(_zenv_allow_file "$dir")"
    echo "zenv: denied $dir/.envrc"
    _zenv_unload
}

_zenv_is_allowed() {
    local dir="$1"
    local allow_file="$(_zenv_allow_file "$dir")"
    [ -f "$allow_file" ] || return 1
    local stored_hash=$(cat "$allow_file")
    local current_hash=$(_zenv_hash "$dir/.envrc")
    [ "$stored_hash" = "$current_hash" ]
}

# --- Diff-based tracking ---

_zenv_diff() {
    # Capture env before
    local -A before_env before_aliases before_funcs
    local key val
    while IFS='=' read -r key val; do
        before_env[$key]="$val"
    done < <(env)
    before_aliases=(${(kv)aliases})
    before_funcs=()
    for key in ${(k)functions}; do
        [[ "$key" = _zenv_* || "$key" = zenv-* ]] && continue
        before_funcs[$key]="${functions[$key]}"
    done

    # Source the envrc
    source "$1"

    # Diff env vars
    _zenv_added_env=()
    _zenv_changed_env=()
    while IFS='=' read -r key val; do
        if [[ -z "${before_env[$key]+x}" ]]; then
            _zenv_added_env[$key]=""
        elif [[ "${before_env[$key]}" != "$val" ]]; then
            _zenv_changed_env[$key]="${before_env[$key]}"
        fi
    done < <(env)

    # Diff aliases
    _zenv_added_aliases=()
    _zenv_changed_aliases=()
    for key in ${(k)aliases}; do
        if [[ -z "${before_aliases[$key]+x}" ]]; then
            _zenv_added_aliases[$key]=""
        elif [[ "${before_aliases[$key]}" != "${aliases[$key]}" ]]; then
            _zenv_changed_aliases[$key]="${before_aliases[$key]}"
        fi
    done

    # Diff functions
    _zenv_added_funcs=()
    _zenv_changed_funcs=()
    for key in ${(k)functions}; do
        [[ "$key" = _zenv_* || "$key" = zenv-* ]] && continue
        if [[ -z "${before_funcs[$key]+x}" ]]; then
            _zenv_added_funcs[$key]=""
        elif [[ "${before_funcs[$key]}" != "${functions[$key]}" ]]; then
            _zenv_changed_funcs[$key]="${before_funcs[$key]}"
        fi
    done
}

_zenv_restore() {
    local key

    # Env: unset added, restore changed
    for key in ${(k)_zenv_added_env}; do
        unset "$key" 2>/dev/null
    done
    for key in ${(k)_zenv_changed_env}; do
        export "$key"="${_zenv_changed_env[$key]}"
    done

    # Aliases: unset added, restore changed
    for key in ${(k)_zenv_added_aliases}; do
        unalias "$key" 2>/dev/null
    done
    for key in ${(k)_zenv_changed_aliases}; do
        alias "$key"="${_zenv_changed_aliases[$key]}"
    done

    # Functions: unset added, restore changed
    for key in ${(k)_zenv_added_funcs}; do
        unset -f "$key" 2>/dev/null
    done
    for key in ${(k)_zenv_changed_funcs}; do
        functions[$key]="${_zenv_changed_funcs[$key]}"
    done
}

# --- Load / Unload ---

_zenv_find_envrc() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/.envrc" ]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

_zenv_load() {
    local dir="$1"
    _zenv_loaded_dir="$dir"
    _zenv_loaded_hash=$(_zenv_hash "$dir/.envrc")
    _zenv_diff "$dir/.envrc"
    echo "zenv: loaded $dir/.envrc"
}

_zenv_unload() {
    [ -z "$_zenv_loaded_dir" ] && return
    _zenv_restore
    echo "zenv: unloaded $_zenv_loaded_dir/.envrc"
    _zenv_loaded_dir=""
    _zenv_loaded_hash=""
}

# --- Hook ---

_zenv_hook() {
    local envrc_dir
    envrc_dir=$(_zenv_find_envrc "$PWD")

    if [ $? -ne 0 ]; then
        [ -n "$_zenv_loaded_dir" ] && _zenv_unload
        return
    fi

    # Still in subdirectory of loaded envrc
    if [ "$envrc_dir" = "$_zenv_loaded_dir" ]; then
        local current_hash=$(_zenv_hash "$envrc_dir/.envrc")
        if [ "$current_hash" != "$_zenv_loaded_hash" ]; then
            if _zenv_is_allowed "$envrc_dir"; then
                _zenv_unload
                _zenv_load "$envrc_dir"
            else
                echo "zenv: .envrc changed, run 'zenv-allow' to reload"
            fi
        fi
        return
    fi

    # Different .envrc — unload old, maybe load new
    [ -n "$_zenv_loaded_dir" ] && _zenv_unload

    if _zenv_is_allowed "$envrc_dir"; then
        _zenv_load "$envrc_dir"
    else
        echo "zenv: blocked $envrc_dir/.envrc (run 'zenv-allow' to trust)"
    fi
}

_zenv_precmd() {
    # Only check for file changes if something is loaded
    [ -z "$_zenv_loaded_dir" ] && return
    [ ! -f "$_zenv_loaded_dir/.envrc" ] && { _zenv_unload; return; }
    local current_hash=$(_zenv_hash "$_zenv_loaded_dir/.envrc")
    [ "$current_hash" = "$_zenv_loaded_hash" ] && return
    if _zenv_is_allowed "$_zenv_loaded_dir"; then
        _zenv_unload
        _zenv_load "$_zenv_loaded_dir"
    else
        echo "zenv: .envrc changed, run 'zenv-allow' to reload"
        _zenv_loaded_hash="$current_hash"  # avoid repeating the message
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _zenv_hook
add-zsh-hook precmd _zenv_precmd

# Run on initial load in case shell starts in a dir with .envrc
_zenv_hook
