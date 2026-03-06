# Structure .linksrc like (using split regex: `'s/ \([^ ]*\)$/\t\1/'`):
#   [group]
#   name url
#   can have spaces: and other symbols url
#
#   ![hidden_group | alias1|alias2]
#   these appear in separate group with tab completion url
#   # Only first alias appears in tab completion (no spaces allowed)
function _core_fzf_engine() {
    local source_file="$1"
    local target_group="$2"
    local prompt_text="$3"
    local sed_split_expr="$4" # Custom regex to split Name and Value

    if [[ ! -f "$source_file" ]]; then
        echo "Error: $source_file not found." >&2
        return 1
    fi

    local filtered_items
    filtered_items=$(awk -v target="$target_group" '
        BEGIN { group_matches = (target == "") ? 1 : 0 }
        /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
        /^[[:space:]]*!?\[.*\][[:space:]]*$/ {
            is_hidden = ($0 ~ /^[[:space:]]*!/) ? 1 : 0
            gsub(/^[[:space:]]*!?\[|\][[:space:]]*$/, "")
            if (target == "") {
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
        { if (group_matches) print $0 }
    ' "$source_file")

    if [[ -z "$filtered_items" ]]; then
        [[ -n "$target_group" ]] && echo "Error: Group '$target_group' not found/empty." >&2 || echo "Error: No items found." >&2
        return 1
    fi

    # Apply the custom sed split and pipe to fzf
    printf "%s\n" "$filtered_items" | \
        sed "$sed_split_expr" | \
        fzf -d '\t' \
            --with-nth 1 \
            --preview 'echo {2}' \
            --preview-window down:1:wrap \
            --prompt="$prompt_text"
}

# Core completion generator
_core_fzf_completions() {
    local source_file="$1"
    if [[ ! -f "$source_file" ]]; then return; fi

    local -a normal_words hidden_words

    normal_words=( $(awk '
        /^[[:space:]]*\[.*\][[:space:]]*$/ {
            gsub(/^[[:space:]]*\[|\][[:space:]]*$/, "")
            split($0, aliases, "|")
            primary = aliases[1]
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", primary)
            print primary
        }
    ' "$source_file") )

    hidden_words=( $(awk '
        /^[[:space:]]*!\[.*\][[:space:]]*$/ {
            gsub(/^[[:space:]]*!\[|\][[:space:]]*$/, "")
            split($0, aliases, "|")
            primary = aliases[1]
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", primary)
            print primary
        }
    ' "$source_file") )

    if (( ${#normal_words[@]} )); then
        compadd -J normal -X $'\e[32mPublic Groups\e[0m' -a normal_words
    fi

    if (( ${#hidden_words[@]} )); then
        compadd -J hidden -X $'\e[31mHidden Groups\e[0m' -a hidden_words
    fi
}

function _link() {
    # Print the clickable link
    echo -e "\033]8;;${1}\033\\${2}\033]8;;\033\\"
}
