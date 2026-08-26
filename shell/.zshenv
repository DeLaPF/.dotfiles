# Environment shared by interactive and non-interactive zsh processes.
typeset -U path PATH
typeset -a _zshenv_path _zshenv_inherited_path
typeset _zshenv_mise_data="${XDG_DATA_HOME:-$HOME/.local/share}/mise"

# A nested zsh may inherit activation metadata from its parent. Start from the
# inherited executable PATH but let this shell establish its own Mise session.
unset MISE_SHELL __MISE_DIFF __MISE_ORIG_PATH __MISE_SESSION
unset __MISE_ZSH_ACTIVATE_ENV __MISE_ZSH_ACTIVATE_PATH
unset __MISE_ZSH_CHPWD_RAN __MISE_ZSH_PRECMD_RUN

# Drop paths inherited from shells that still initialized the retired runtime
# managers. Their installations remain on disk until removed deliberately.
for _zshenv_dir in $path; do
  case "$_zshenv_dir" in
    "$_zshenv_mise_data"/installs/*|"$HOME"/.nvm/*|"$HOME"/.pyenv/*|"$HOME"/.jenv/*|"$HOME"/.zvm/*|"$HOME"/.local/share/go/bin)
      ;;
    *)
      _zshenv_inherited_path+=("$_zshenv_dir")
      ;;
  esac
done

# Static executable locations belong here so scripts, editors, and agents see
# the same commands as interactive terminals. Runtime-specific paths come from
# Mise rather than individual version managers.
for _zshenv_dir in \
  "$_zshenv_mise_data/shims" \
  "$HOME/.local/share/neovim/bin" \
  "$HOME/.local/share/bob/nvim-bin" \
  "$HOME/.scripts" \
  "$HOME/.cargo/bin" \
  "$HOME/.local/bin" \
  "$HOME/google-cloud-sdk/bin" \
  /opt/homebrew/bin \
  /home/linuxbrew/.linuxbrew/bin
do
  [[ -d "$_zshenv_dir" ]] && _zshenv_path+=("$_zshenv_dir")
done

path=($_zshenv_path $_zshenv_inherited_path)
export PATH
unset _zshenv_path _zshenv_inherited_path _zshenv_dir
unset _zshenv_mise_data
unset NVM_DIR PYENV_ROOT JENV_ROOT ZVM_ROOT ZVM_INSTALL

export VISUAL=nvim
export EDITOR="$VISUAL"

# Use the same Typst package location on macOS and Linux.
export TYPST_PACKAGE_PATH="$HOME/.local/share/typst/packages"

# Full activation keeps interactive shells, scripts, and agents aligned on
# tool paths and environment variables (for example JAVA_HOME and GOROOT).
# Measured cost on this machine: about 40 ms per fresh non-interactive zsh.
(( $+commands[mise] )) && eval "$(mise activate zsh)"
