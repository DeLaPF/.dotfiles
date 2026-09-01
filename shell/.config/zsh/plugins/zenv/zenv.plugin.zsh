# zenv - stateful shell environment plugin (zsh-only direnv alternative)
# Manages env vars, aliases, and functions from .envrc files
# with automatic loading/unloading on directory change
#
# LIMITATION: only one .envrc is active at a time. Walks up from $PWD
# and loads the nearest .envrc. Does not stack parent .envrc files like
# direnv's `source_env`. To support stacking, would need an array of
# loaded dirs + per-file diff tracking + reverse-order restore.
#
# HOOK: if .envrc defines a function named `zenv_deactivate`, it runs
# on unload before env/aliases/funcs are restored.

# Tracks only what .envrc added, modified, or removed.
typeset -gA _zenv_added_env       # key -> ""  (new vars to unset on restore)
typeset -gA _zenv_changed_env     # key -> old_value  (changed vars to restore)
typeset -gA _zenv_removed_env     # key -> old_value  (removed vars to restore)
typeset -gA _zenv_added_aliases   # key -> ""
typeset -gA _zenv_changed_aliases # key -> old_value
typeset -gA _zenv_removed_aliases # key -> old_value
typeset -gA _zenv_added_funcs     # key -> ""
typeset -gA _zenv_changed_funcs   # key -> old_body
typeset -gA _zenv_removed_funcs   # key -> old_body
typeset -g _zenv_loaded_dir=""
typeset -g _zenv_loaded_hash=""
typeset -g _zenv_warned_hash=""
typeset -g _zenv_loading=""  # guard so the cd into .envrc dir doesn't re-trigger the hook
typeset -g _zenv_allow_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zenv/allowed"

# --- Security ---

_zenv_hash() {
    local digest
    if (( $+commands[shasum] )); then
        digest=$(shasum -a 256 "$1" 2>/dev/null) || return
    elif (( $+commands[sha256sum] )); then
        digest=$(sha256sum "$1" 2>/dev/null) || return
    else
        echo "zenv: shasum or sha256sum is required" >&2
        return 127
    fi
    echo "${digest%% *}"
}

_zenv_hash_text() {
    local digest
    if (( $+commands[shasum] )); then
        digest=$(shasum -a 256) || return
    elif (( $+commands[sha256sum] )); then
        digest=$(sha256sum) || return
    else
        echo "zenv: shasum or sha256sum is required" >&2
        return 127
    fi
    echo "${digest%% *}"
}

_zenv_allow_file() {
    local dir="${1:A}"
    local digest
    digest=$(printf '%s\n' "$dir" | _zenv_hash_text) || return
    echo "$_zenv_allow_dir/$digest"
}

_zenv_allow() {
    local target="${1:-$PWD}"
    local envrc_dir
    if [ -f "$target" ]; then
        envrc_dir="${target:h:A}"
    else
        envrc_dir=$(_zenv_find_envrc "$target") || {
            echo "No .envrc found" >&2
            return 1
        }
    fi
    local envrc="$envrc_dir/.envrc"
    local hash allow_file
    hash=$(_zenv_hash "$envrc") || return
    allow_file=$(_zenv_allow_file "$envrc_dir") || return
    mkdir -p "$_zenv_allow_dir"
    echo "$hash" > "$allow_file"
    echo "zenv: allowed $envrc"
    _zenv_hook
}

_zenv_deny() {
    local target="${1:-$PWD}"
    local dir
    if [ "${target:t}" = .envrc ]; then
        dir="${target:h:A}"
    else
        dir=$(_zenv_find_envrc "$target" 2>/dev/null) || dir="${target:A}"
    fi
    rm -f "$(_zenv_allow_file "$dir")"
    echo "zenv: denied $dir/.envrc"
    [ "$dir" = "$_zenv_loaded_dir" ] && _zenv_unload
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
    local -A before_env before_aliases before_funcs after_env
    local key source_status
    for key in ${(k)parameters}; do
        [[ "${parameters[$key]}" == *export* ]] || continue
        before_env[$key]="${(P)key}"
    done
    before_aliases=(${(kv)aliases})
    before_funcs=()
    for key in ${(k)functions}; do
        [[ "$key" = _zenv_* || "$key" = zenv-* ]] && continue
        before_funcs[$key]="${functions[$key]}"
    done

    # Source from the .envrc's directory so relative paths inside resolve
    # against it, not against $PWD (which may be a subdir).
    local _prev_pwd="$PWD" _prev_oldpwd="$OLDPWD"
    _zenv_loading=1
    cd "${1:h}" || {
        _zenv_loading=""
        return 1
    }
    {
        source "$1"
        source_status=$?
    } always {
        cd "$_prev_pwd"
        OLDPWD="$_prev_oldpwd"  # undo the OLDPWD side effect of the cd round-trip
        _zenv_loading=""
    }

    # Diff env vars
    _zenv_added_env=()
    _zenv_changed_env=()
    _zenv_removed_env=()
    for key in ${(k)parameters}; do
        [[ "${parameters[$key]}" == *export* ]] || continue
        after_env[$key]="${(P)key}"
    done
    for key in ${(k)after_env}; do
        if [[ -z "${before_env[$key]+x}" ]]; then
            _zenv_added_env[$key]=""
        elif [[ "${before_env[$key]}" != "${after_env[$key]}" ]]; then
            _zenv_changed_env[$key]="${before_env[$key]}"
        fi
    done
    for key in ${(k)before_env}; do
        [[ -n "${after_env[$key]+x}" ]] ||
            _zenv_removed_env[$key]="${before_env[$key]}"
    done

    # Diff aliases
    _zenv_added_aliases=()
    _zenv_changed_aliases=()
    _zenv_removed_aliases=()
    for key in ${(k)aliases}; do
        if [[ -z "${before_aliases[$key]+x}" ]]; then
            _zenv_added_aliases[$key]=""
        elif [[ "${before_aliases[$key]}" != "${aliases[$key]}" ]]; then
            _zenv_changed_aliases[$key]="${before_aliases[$key]}"
        fi
    done
    for key in ${(k)before_aliases}; do
        [[ -n "${aliases[$key]+x}" ]] ||
            _zenv_removed_aliases[$key]="${before_aliases[$key]}"
    done

    # Diff functions
    _zenv_added_funcs=()
    _zenv_changed_funcs=()
    _zenv_removed_funcs=()
    for key in ${(k)functions}; do
        [[ "$key" = _zenv_* || "$key" = zenv-* ]] && continue
        if [[ -z "${before_funcs[$key]+x}" ]]; then
            _zenv_added_funcs[$key]=""
        elif [[ "${before_funcs[$key]}" != "${functions[$key]}" ]]; then
            _zenv_changed_funcs[$key]="${before_funcs[$key]}"
        fi
    done
    for key in ${(k)before_funcs}; do
        [[ -n "${functions[$key]+x}" ]] ||
            _zenv_removed_funcs[$key]="${before_funcs[$key]}"
    done

    return "$source_status"
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
    for key in ${(k)_zenv_removed_env}; do
        export "$key"="${_zenv_removed_env[$key]}"
    done

    # Aliases: unset added, restore changed
    for key in ${(k)_zenv_added_aliases}; do
        unalias "$key" 2>/dev/null
    done
    for key in ${(k)_zenv_changed_aliases}; do
        alias "$key"="${_zenv_changed_aliases[$key]}"
    done
    for key in ${(k)_zenv_removed_aliases}; do
        alias "$key"="${_zenv_removed_aliases[$key]}"
    done

    # Functions: unset added, restore changed
    for key in ${(k)_zenv_added_funcs}; do
        unset -f "$key" 2>/dev/null
    done
    for key in ${(k)_zenv_changed_funcs}; do
        functions[$key]="${_zenv_changed_funcs[$key]}"
    done
    for key in ${(k)_zenv_removed_funcs}; do
        functions[$key]="${_zenv_removed_funcs[$key]}"
    done

    _zenv_added_env=()
    _zenv_changed_env=()
    _zenv_removed_env=()
    _zenv_added_aliases=()
    _zenv_changed_aliases=()
    _zenv_removed_aliases=()
    _zenv_added_funcs=()
    _zenv_changed_funcs=()
    _zenv_removed_funcs=()
}

# --- Load / Unload ---

_zenv_find_envrc() {
    local dir="${1:A}"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/.envrc" ]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

_zenv_status() {
    local target="${1:-$PWD}"
    [ "${target:t}" = .envrc ] && target="${target:h}"

    local envrc_dir
    envrc_dir=$(_zenv_find_envrc "$target") || {
        echo "zenv: none (no .envrc found from $target)"
        return 1
    }

    local state
    if [ "$envrc_dir" = "$_zenv_loaded_dir" ]; then
        if [ "$(_zenv_hash "$envrc_dir/.envrc")" = "$_zenv_loaded_hash" ]; then
            state=loaded
        else
            state=changed
        fi
    elif _zenv_is_allowed "$envrc_dir"; then
        state=allowed
    else
        state=blocked
    fi

    echo "zenv: $state $envrc_dir/.envrc"
}

_zenv_notice() {
    # Shell startup and captured commands must not write state notices into
    # their caller's output. Interactive directory changes may stay visible.
    [[ -z "${_zenv_quiet:-}" && -o interactive && -t 1 ]] || return 0
    echo "$@"
}

_zenv_load() {
    local dir="$1"
    local hash load_status
    hash=$(_zenv_hash "$dir/.envrc") || return
    _zenv_diff "$dir/.envrc"
    load_status=$?
    if (( load_status != 0 )); then
        _zenv_restore
        echo "zenv: failed to load $dir/.envrc (status $load_status)" >&2
        return "$load_status"
    fi
    _zenv_loaded_dir="$dir"
    _zenv_loaded_hash="$hash"
    _zenv_warned_hash=""
    _zenv_notice "zenv: loaded $dir/.envrc"
}

_zenv_unload() {
    [ -z "$_zenv_loaded_dir" ] && return
    # Run user-defined deactivate hook while env/aliases/funcs are still active
    if (( ${+functions[zenv_deactivate]} )); then
        zenv_deactivate
    fi
    _zenv_restore
    _zenv_notice "zenv: unloaded $_zenv_loaded_dir/.envrc"
    _zenv_loaded_dir=""
    _zenv_loaded_hash=""
    _zenv_warned_hash=""
}

# --- Hook ---

_zenv_hook() {
    local _zenv_quiet="${1:-}"
    [[ -o interactive && -t 1 ]] || _zenv_quiet=1
    [ -n "$_zenv_loading" ] && return
    local envrc_dir
    envrc_dir=$(_zenv_find_envrc "$PWD")

    if [ $? -ne 0 ]; then
        [ -n "$_zenv_loaded_dir" ] && _zenv_unload
        return 0
    fi

    # Still in subdirectory of loaded envrc
    if [ "$envrc_dir" = "$_zenv_loaded_dir" ]; then
        local current_hash=$(_zenv_hash "$envrc_dir/.envrc")
        if [ "$current_hash" != "$_zenv_loaded_hash" ]; then
            if _zenv_is_allowed "$envrc_dir"; then
                _zenv_unload
                _zenv_load "$envrc_dir"
            elif [ "$current_hash" != "$_zenv_warned_hash" ]; then
                _zenv_notice "zenv: .envrc changed, run 'zenv allow' to reload"
                _zenv_warned_hash="$current_hash"
            fi
        else
            _zenv_warned_hash=""
        fi
        return
    fi

    # Different .envrc — unload old, maybe load new
    [ -n "$_zenv_loaded_dir" ] && _zenv_unload

    if _zenv_is_allowed "$envrc_dir"; then
        _zenv_load "$envrc_dir"
    else
        _zenv_notice "zenv: blocked $envrc_dir/.envrc (run 'zenv allow' to trust)"
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
    elif [ "$current_hash" != "$_zenv_warned_hash" ]; then
        _zenv_notice "zenv: .envrc changed, run 'zenv allow' to reload"
        _zenv_warned_hash="$current_hash"
    fi
}

# --- Command surface ---

zenv() {
    emulate -L zsh

    local command_name="${1:-help}"
    (( $# )) && shift

    case "$command_name" in
        allow)  _zenv_allow "$@" ;;
        deny)   _zenv_deny "$@" ;;
        reload)
            _zenv_unload
            _zenv_hook
            ;;
        status) _zenv_status "$@" ;;
        help|-h|--help)
            printf '%s\n' \
                'Usage: zenv <command> [path]' \
                '  allow [path]   Trust and load the nearest .envrc' \
                '  deny [path]    Revoke trust and unload its .envrc' \
                '  reload         Reload the current trusted .envrc' \
                '  status [path]  Show none, blocked, allowed, changed, or loaded'
            ;;
        *)
            echo "zenv: unknown command: $command_name" >&2
            return 1
            ;;
    esac
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _zenv_hook
add-zsh-hook precmd _zenv_precmd

# Run on initial load in case shell starts in a dir with .envrc. Notices are
# emitted only when this is a genuinely interactive terminal.
_zenv_hook
