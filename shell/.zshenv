# Environment shared by interactive and non-interactive zsh processes.
typeset -U fpath FPATH
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"

# Static executable locations load here so scripts, editors, and agents see
# the same commands as interactive terminals. Runtime-specific paths come from
# Mise rather than individual version managers.
typeset _zshenv_path_config="$HOME/.config/zsh/path.zsh"
[[ -r "$_zshenv_path_config" ]] && source "$_zshenv_path_config"
unset _zshenv_path_config

# Load unshared, device-specific exports and PATH setup after the shared base.
# Keep this file silent because every zsh process sources it.
[[ -r "$HOME/.zshenv.local" ]] && source "$HOME/.zshenv.local"

# Register commands that must be available to scripts and agents. Autoloading
# exposes each name immediately while deferring its implementation until use.
typeset _zshenv_functions="$HOME/.config/zsh/functions"
if [[ -d "$_zshenv_functions" ]]; then
  fpath=("$_zshenv_functions" $fpath)
  typeset -a req_universal=(
    gcb grs gpo pnpm _link
  )
  autoload -Uz $req_universal
  unset req_universal
fi
unset _zshenv_functions

# Worktree commands are packaged separately so they can be shared without the
# rest of these dotfiles.
typeset _zshenv_worktrees="$HOME/.config/zsh/plugins/worktrees/worktrees.plugin.zsh"
[[ -r "$_zshenv_worktrees" ]] && source "$_zshenv_worktrees"
unset _zshenv_worktrees

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
