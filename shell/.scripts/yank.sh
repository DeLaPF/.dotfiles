#!/usr/bin/env sh

input=$( cat "$@" )
input() { printf %s "$input" ;}
known() { command -v "$1" >/dev/null ;}
maybe() { known "$1" && input | "$@" ;}
alive() { known "$1" && "$@" >/dev/null 2>&1 ;}

# copy to tmux
test -n "$TMUX" && maybe tmux load-buffer -

# copy via X11
test -n "$DISPLAY" && alive xhost && {
  maybe xsel -i -b || maybe xclip -sel c
}

# copy via OSC 52
printf_escape() {
  esc=$1
  test -n "$TMUX" -o -z "${TERM##screen*}" && esc="\033Ptmux;\033$esc\033\\"
  printf "$esc"
}
len=$( input | wc -c ) max=74994
test $len -gt $max && echo "$0: input is $(( len - max )) bytes too long" >&2
printf_escape "\033]52;c;$( input | head -c $max | base64 | tr -d '\r\n' )\a"
