function gcb() {
    #date +: %Y, %m, %d, %H, %M, %S
    local suffix=$(date +%Y_%m_%d_%H%M)
    # If $1 exists, append it with an underscore; otherwise, leave empty.
    local name_part="${1:+${1}__}"
    git checkout -b "$USER/${name_part}${suffix}"
}

function gwt() {
    # Find the repo root (parent of .bare/)
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.bare" ]; then
            break
        fi
        dir=$(dirname "$dir")
    done

    if [ ! -d "$dir/.bare" ]; then
        echo "Error: could not find .bare/ directory" >&2
        return 1
    fi

    local hook_dir="$dir/.worktree-hooks"

    case "$1" in
        -c)
            local date_short=$(date +%m%d)
            local time_short=$(date +%H%M)
            local wt_name
            if [ -n "$2" ]; then
                wt_name="${USER}__${2}__${date_short}"
            else
                wt_name="${USER}__${date_short}__${time_short}"
            fi
            local start_point=${3:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}
            git -C "$dir/.bare" worktree add "$dir/$wt_name" -b "$wt_name" $start_point && {
                [ -x "$hook_dir/on-create" ] && "$hook_dir/on-create" "$dir/$wt_name"
                cd "$dir/$wt_name"
            }
            ;;
        -e)
            local branch="$2"
            if [ -z "$branch" ]; then
                echo "Usage: gwt -e <existing-branch>" >&2
                return 1
            fi
            git -C "$dir/.bare" worktree add "$dir/$branch" "$branch" && {
                [ -x "$hook_dir/on-create" ] && "$hook_dir/on-create" "$dir/$branch"
                cd "$dir/$branch"
            }
            ;;
        -r)
            shift
            local wt_path
            wt_path=$(git rev-parse --show-toplevel 2>/dev/null) || {
                echo "Error: not inside a worktree" >&2
                return 1
            }
            [ -x "$hook_dir/on-remove" ] && "$hook_dir/on-remove" "$wt_path"
            cd "$dir" && git -C "$dir/.bare" worktree remove "$@" "$wt_path"
            ;;
        *)
            echo "Usage: gwt <command>"
            echo "  -c [name] [base]   Create new worktree (name optional, base defaults to current branch)"
            echo "  -e <branch>        Check out existing branch into a new worktree"
            echo "  -r [--force]       Remove current worktree"
            ;;
    esac
}

function grs() {
    git reflog show --pretty=format:'%gs ~ %gd' --date=relative | grep 'checkout:' | grep -oE '[^ ]* ~ .*' | awk -F~ '!seen[$1]++' | awk -F' ~ HEAD@{' '{printf(" \033[33m%s: \033[37m %s\033[0m\n", substr($2, 1, length($2)-1), $1)}'
}

function gpo() {
    local branch=$(git rev-parse --abbrev-ref HEAD)
    local repo=$(git remote get-url origin | sed -E 's|.*github\.com[:/](.+)(\.git)?$|\1|' | sed 's/\.git$//')
    local default_branch=$(git remote show origin | sed -n 's/.*HEAD branch: //p')
    git $1 push -u origin $branch

    _link "https://github.com/$repo/compare/$default_branch...$branch" "Click to Open PR"
}
