#!/usr/bin/env bash

function gcb() {
    #date +: %Y, %m, %d, %H, %M, %S
    BRANCH_NAME=$(echo $USER'_'$(date +%Y_%m_%d_%H%M))
    git checkout -b $BRANCH_NAME
}

function grs() {
    git reflog show --pretty=format:'%gs ~ %gd' --date=relative | grep 'checkout:' | grep -oE '[^ ]* ~ .*' | awk -F~ '!seen[$1]++' | awk -F' ~ HEAD@{' '{printf(" \033[33m%s: \033[37m %s\033[0m\n", substr($2, 1, length($2)-1), $1)}'
}
