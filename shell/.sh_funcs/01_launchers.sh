function links() {
    local selection
    # For links, split by the *last* space on the line
    selection=$(_core_fzf_engine "$HOME/.linksrc" "$1" "Select Link> " 's/ \([^ ]*\)$/\t\1/')

    if [[ -n "$selection" ]]; then
        local name="${selection%$'\t'*}"
        local url="${selection#*$'\t'}"

        _link "$url" "$name"

        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            xdg-open "$url" > /dev/null 2>&1
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            open "$url"
        fi
    fi
}

function cmds() {
    local selection
    # For commands, split by the " :: " delimiter
    selection=$(_core_fzf_engine "$HOME/.cmdsrc" "$1" "Select Command> " 's/[[:space:]]*::[[:space:]]*/\t/')

    if [[ -n "$selection" ]]; then
        local name="${selection%$'\t'*}"
        local cmd="${selection#*$'\t'}"

        # Print the command being run for visual feedback
        echo -e "\033[36mRunning:\033[0m $cmd"

        if [[ -n "$ZSH_VERSION" ]]; then
            # Pushes the command directly to the current prompt buffer
            print -z "$cmd"
        elif [[ -n "$BASH_VERSION" ]]; then
            # Bash cannot easily inject into the active prompt from a command,
            # so we put it in history and tell the user to press Up.
            history -s "$cmd"
            echo -e "\033[33mCommand added to history. Press UP arrow to review/run.\033[0m"
        fi

        # Alternatively execute
        # Safely push the executed command to the shell history
        # if [[ -n "$ZSH_VERSION" ]]; then
        #     print -s "$cmd"
        # elif [[ -n "$BASH_VERSION" ]]; then
        #     history -s "$cmd"
        # fi

        # # Execute it using eval so pipes/redirects work properly
        # eval "$cmd"
    fi
}


# Bind completions to their respective files
_links_completions() { _core_fzf_completions "$HOME/.linksrc" }
_cmds_completions() { _core_fzf_completions "$HOME/.cmdsrc" }

# Bind completions
compdef _links_completions links
compdef _cmds_completions cmds
