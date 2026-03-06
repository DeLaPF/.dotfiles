function gcb() {
    #date +: %Y, %m, %d, %H, %M, %S
    local suffix=$(date +%Y_%m_%d_%H%M)
    # If $1 exists, append it with an underscore; otherwise, leave empty.
    local name_part="${1:+${1}__}"
    git checkout -b "$USER/${name_part}${suffix}"
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
