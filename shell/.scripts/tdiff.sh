#!/usr/bin/env bash

word_diff_arg=""

while getopts "w" opt; do
    case $opt in
        w)
            word_diff_arg="--word-diff"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            echo "Usage: tdiff [-w]" >&2
            exit 1
            ;;
    esac
done

f1=$(mktemp)
f2=$(mktemp)
trap 'rm -f "$f1" "$f2"' EXIT

echo "> Paste first block (Enter, then Ctrl+D to submit)"
cat > "$f1"
# input2=$(cat)

echo ""

echo "> Paste seoncd block (Enter, then Ctrl+D to submit)"
cat > "$f2"
# input2=$(cat)

echo ""

# diff --color=auto <(echo "$input1") <(echo "$input2")
git diff --no-index --color=auto $word_diff_arg "$f1" "$f2"
