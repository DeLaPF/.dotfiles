# Environment shared by interactive and non-interactive zsh processes.
typeset -U path PATH
typeset -U fpath FPATH
typeset -a _zshenv_path
typeset _zshenv_mise_data="${XDG_DATA_HOME:-$HOME/.local/share}/mise"

# Static executable locations belong here so scripts, editors, and agents see
# the same commands as interactive terminals. Runtime-specific paths come from
# Mise rather than individual version managers.
for _zshenv_dir in \
  "$_zshenv_mise_data/shims" \
  "$HOME/.local/share/bob/nvim-bin" \
  "$HOME/.scripts" \
  "$HOME/.cargo/bin" \
  "$HOME/.local/bin" \
  /opt/homebrew/bin \
  /home/linuxbrew/.linuxbrew/bin
do
  [[ -d "$_zshenv_dir" ]] && _zshenv_path+=("$_zshenv_dir")
done

path=($_zshenv_path $path)
export PATH
unset _zshenv_path _zshenv_dir
unset _zshenv_mise_data

# Load unshared, device-specific exports and PATH setup after the shared base.
# Keep this file silent because every zsh process sources it.
[[ -r "$HOME/.zshenv.local" ]] && source "$HOME/.zshenv.local"

# Register commands that must be available to scripts and agents. Autoloading
# exposes each name immediately while deferring its implementation until use.
typeset _zshenv_functions="$HOME/.config/zsh/functions"
if [[ -d "$_zshenv_functions" ]]; then
  fpath=("$_zshenv_functions" $fpath)
  typeset -a req_universal=(
    bare-clone gcb gwt grs gpo
    _gwt_post_create _link
  )
  autoload -Uz $req_universal
  unset req_universal
fi
unset _zshenv_functions

export VISUAL=nvim
export EDITOR="$VISUAL"

# Use the same Typst package location on macOS and Linux.
export TYPST_PACKAGE_PATH="$HOME/.local/share/typst/packages"

# Zenv owns persistent directory state, so it is the one eager shell plugin.
typeset _zshenv_zenv="$HOME/.config/zsh/plugins/zenv/zenv.plugin.zsh"
[[ -r "$_zshenv_zenv" ]] && source "$_zshenv_zenv"
unset _zshenv_zenv

# Full activation keeps interactive shells, scripts, and agents aligned on
# tool paths and environment variables (for example JAVA_HOME and GOROOT).
# Measured cost on this machine: about 40 ms per fresh non-interactive zsh.
(( $+commands[mise] )) && eval "$(mise activate zsh)"
