# Enable colored ls output
export CLICOLOR=1
export LS_COLORS="di=34:ln=36:so=35:pi=33:ex=32:bd=1;33:cd=1;33:su=1;31:sg=1;31:tw=1;34:ow=1;34"

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

# Register interactive commands and completion definitions without parsing
# their implementations during startup.
typeset _zshrc_completions="$HOME/.config/zsh/completions"
[[ -d "$_zshrc_completions" ]] && fpath=("$_zshrc_completions" $fpath)
unset _zshrc_completions

typeset -a req_interactive=(
  links cmds glg plg refr
  _core_fzf_engine _core_fzf_completions
)
autoload -Uz $req_interactive
unset req_interactive

# Basic auto/tab complete:
autoload -Uz compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files.

# vi mode
bindkey -v
bindkey -M viins 'jk' vi-cmd-mode
export KEYTIMEOUT=50

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# +----- Change cursor shape for vi mode -----+
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt
# +------------------- End -------------------+

# Edit line in vim with alt-e
autoload edit-command-line; zle -N edit-command-line
bindkey '^[e' edit-command-line

# Load aliases (if exists)
[ -f "$HOME/.aliasrc" ] && source "$HOME/.aliasrc"
# Load device-local interactive setup that does not belong in shared dotfiles.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Load Starship when present.
(( $+commands[starship] )) && eval "$(starship init zsh)"

# Load zsh-syntax-highlighting (if exists); should be last.
ZSH_PLUGIN_ROOT="$HOME/.zsh/plugins"
[[ -d $ZSH_PLUGIN_ROOT/zsh-syntax-highlighting ]] && source "$ZSH_PLUGIN_ROOT/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
unset ZSH_PLUGIN_ROOT
