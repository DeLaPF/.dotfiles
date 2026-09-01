if [[ "$OSTYPE" == darwin* ]]; then
  # /etc/zprofile runs path_helper after .zshenv; restore static precedence,
  # then force Mise to rebuild its runtime paths from that corrected base.
  [[ -r "$HOME/.config/zsh/path.zsh" ]] && source "$HOME/.config/zsh/path.zsh"
  (( $+commands[mise] )) && eval "$(mise hook-env --force -s zsh)"
fi
