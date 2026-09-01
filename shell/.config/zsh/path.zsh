# Static executable locations shared by all zsh startup modes.
typeset -gU path PATH
typeset -a _zsh_path_prepend=(
  "${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims"
  "$PNPM_HOME/bin"
)

for _zsh_path_dir in \
  "$HOME/.local/share/bob/nvim-bin" \
  "$HOME/.scripts" \
  "$HOME/.cargo/bin" \
  "$HOME/.local/bin" \
  /opt/homebrew/bin \
  /home/linuxbrew/.linuxbrew/bin
do
  [[ -d "$_zsh_path_dir" ]] && _zsh_path_prepend+=("$_zsh_path_dir")
done

# Remove inherited copies before prepending so nested shells keep this order.
for _zsh_path_dir in $_zsh_path_prepend; do
  path=(${path:#"$_zsh_path_dir"})
done
path=($_zsh_path_prepend $path)
export PATH
unset _zsh_path_prepend _zsh_path_dir
