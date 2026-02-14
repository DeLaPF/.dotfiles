glg() {
    local missing=()
    command -v rg  > /dev/null || missing+=(rg)
    command -v fzf > /dev/null || missing+=(fzf)
    command -v bat > /dev/null || missing+=(bat)
    if (( ${#missing[@]} )); then
        echo "Error: missing required commands: ${missing[*]}"
        return 1
    fi

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Error: Not inside a git repository"
        return 1
    fi

    local selected_lines=$(rg --hidden --line-number --no-heading --color=always "$@" | \
        fzf --ansi \
            --multi \
            --delimiter : \
            --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3' \
            --bind 'enter:accept')

    # 3. If nothing selected, exit
    if [[ -z "$selected_lines" ]]; then
        return 0
    fi

    # 4. Get Git metadata ONCE (optimization)
    local remote_url=$(git config --get remote.origin.url)
    local hash=$(git rev-parse HEAD)

    # Normalize URL (Convert SSH git@ to HTTPS)
    if [[ "$remote_url" == git@* ]]; then
        remote_url=${remote_url#git@}
        remote_url=${remote_url/://}
        remote_url="https://${remote_url%.git}"
    else
        remote_url=${remote_url%.git}
    fi

    # Get path prefix for when running from a subdirectory
    local repo_prefix=$(git rev-parse --show-prefix)

    # 5. Process EACH selected line
    #    We allow opening multiple files at once
    echo "$selected_lines" | while read -r item; do
        local file=$(echo "$item" | cut -d: -f1)
        local line=$(echo "$item" | cut -d: -f2)

        # Construct permalink
        local permalink="${remote_url}/blob/${hash}/${repo_prefix}${file}#L${line}"

        # Open based on OS
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            xdg-open "$permalink" > /dev/null 2>&1
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            open "$permalink"
        fi
    done
}
