function link() {
    # Print the clickable link
    echo -e "\033]8;;${1}\033\\${2}\033]8;;\033\\"
}

# Structure .linksrc like:
#   [group]
#   name url
#   can have spaces: and other symbols url
#
#   ![hidden_group | alias1|alias2]
#   these appear in separate group with tab completion url
#   # Only first alias appears in tab completion (no spaces allowed)
function links() {
    local link_file="$HOME/.linksrc"

    if [[ ! -f "$link_file" ]]; then
        echo "Error: $link_file not found."
        return 1
    fi

    local target_group="$1"
    local filtered_links

    # 1. awk: Parses the file, handles aliases, and respects ![hidden] groups
    filtered_links=$(awk -v target="$target_group" '
        BEGIN { group_matches = (target == "") ? 1 : 0 }

        # Skip comments and empty lines
        /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }

        # Match headers like [name] or ![name]
        /^[[:space:]]*!?\[.*\][[:space:]]*$/ {
            # Check if this group is marked as hidden (starts with !)
            is_hidden = ($0 ~ /^[[:space:]]*!/) ? 1 : 0

            # Strip outer characters: optional spaces, optional !, [, and ]
            gsub(/^[[:space:]]*!?\[|\][[:space:]]*$/, "")

            if (target == "") {
                # If no arguments passed, skip the hidden groups
                group_matches = (is_hidden) ? 0 : 1
            } else {
                group_matches = 0
                n = split($0, aliases, "|")
                for (i = 1; i <= n; i++) {
                    gsub(/^[[:space:]]+|[[:space:]]+$/, "", aliases[i])
                    if (aliases[i] == target) {
                        group_matches = 1
                        break
                    }
                }
            }
            next
        }

        # For all other lines (the actual links)
        {
            if (group_matches) {
                print $0
            }
        }
    ' "$link_file")

    # 2. Check if anything was actually found
    if [[ -z "$filtered_links" ]]; then
        if [[ -n "$target_group" ]]; then
            echo "Error: Group '$target_group' not found or contains no links."
        else
            echo "Error: No links found in $link_file."
        fi
        return 1
    fi

    # 3. Pass the filtered list to sed and fzf
    local selection
    selection=$(printf "%s\n" "$filtered_links" | \
                sed 's/ \([^ ]*\)$/\t\1/' | \
                fzf -d '\t' \
                    --with-nth 1 \
                    --preview 'echo {2}' \
                    --preview-window down:1:wrap \
                    --prompt="Select Link> ")

    # If the user made a selection
    if [[ -n "$selection" ]]; then
        local name="${selection%$'\t'*}"
        local url="${selection#*$'\t'}"

        # Print the clickable OSC 8 link to the terminal
        link "$url" "$name"

        # Open based on OS
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            xdg-open "$url" > /dev/null 2>&1
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            open "$url"
        fi
    fi
}

# Zsh completion function for 'links'
_links_completions() {
    local link_file="$HOME/.linksrc"
    if [[ ! -f "$link_file" ]]; then return; fi

    local -a normal_words hidden_words

    # 1. Extract normal groups (no ! at the start)
    normal_words=( $(awk '
        /^[[:space:]]*\[.*\][[:space:]]*$/ {
            gsub(/^[[:space:]]*\[|\][[:space:]]*$/, "")
            split($0, aliases, "|")
            primary = aliases[1]
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", primary)
            print primary
        }
    ' "$link_file") )

    # 2. Extract hidden groups (starts with !)
    hidden_words=( $(awk '
        /^[[:space:]]*!\[.*\][[:space:]]*$/ {
            gsub(/^[[:space:]]*!\[|\][[:space:]]*$/, "")
            split($0, aliases, "|")
            primary = aliases[1]
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", primary)
            print primary
        }
    ' "$link_file") )

    # 3. Add to completion menu with -J (independent groups) and -X (headers)
    # We use basic ANSI escape codes for the header colors
    if (( ${#normal_words[@]} )); then
        compadd -J normal -X $'\e[32mPublic Groups\e[0m' -a normal_words
    fi

    if (( ${#hidden_words[@]} )); then
        compadd -J hidden -X $'\e[31mHidden Groups\e[0m' -a hidden_words
    fi
}
compdef _links_completions links
