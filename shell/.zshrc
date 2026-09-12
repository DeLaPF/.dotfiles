# Enable colored ls output
export CLICOLOR=1
export LS_COLORS="di=34:ln=36:so=35:pi=33:ex=32:bd=1;33:cd=1;33:su=1;31:sg=1;31:tw=1;34:ow=1;34"

# Atuin owns persistent history; keep native history in memory for vicmd j/k.
HISTSIZE=10000

# Register interactive commands and completion definitions without parsing
# their implementations during startup.
typeset _zshrc_completions="$HOME/.config/zsh/completions"
[[ -d "$_zshrc_completions" ]] && fpath=("$_zshrc_completions" $fpath)
unset _zshrc_completions

typeset -a req_interactive=(
  links cmds plg refr
  _link _core_fzf_engine _core_fzf_completions
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

# Keep one Atuin session per tmux pane, including across tmux-resurrect. During
# restore, only newly created panes inherit the snapshot path exported by the
# restore hook; ordinary new panes always receive a fresh UUID.
if (( $+commands[atuin] )); then
  typeset _atuin_pane_session=""

  if [[ -n ${TMUX_PANE:-} ]]; then
    _atuin_pane_session=$(tmux show-options -pqv -t "$TMUX_PANE" @atuin-session 2>/dev/null)

    if [[ -z $_atuin_pane_session && -r ${ATUIN_TMUX_RESURRECT_FILE:-} ]]; then
      typeset _atuin_tmux_session _atuin_tmux_window _atuin_tmux_pane
      _atuin_tmux_session=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}')
      _atuin_tmux_window=$(tmux display-message -p -t "$TMUX_PANE" '#{window_index}')
      _atuin_tmux_pane=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_index}')
      _atuin_pane_session=$(awk -F '\t' \
        -v session="$_atuin_tmux_session" \
        -v window="$_atuin_tmux_window" \
        -v pane="$_atuin_tmux_pane" \
        '$1 == "atuin" && $2 == session && $3 == window && $4 == pane { print $5; exit }' \
        "$ATUIN_TMUX_RESURRECT_FILE")
      unset _atuin_tmux_session _atuin_tmux_window _atuin_tmux_pane
    fi

    [[ -n $_atuin_pane_session ]] || _atuin_pane_session=$(atuin uuid)
    export ATUIN_SESSION="$_atuin_pane_session"
    export ATUIN_SHLVL="$SHLVL"
  fi

  eval "$(ATUIN_NOBIND=1 atuin init zsh)"

  if [[ -n ${TMUX_PANE:-} && -n ${ATUIN_SESSION:-} ]]; then
    tmux set-option -pq -t "$TMUX_PANE" @atuin-session "$ATUIN_SESSION"
  fi

  unset _atuin_pane_session ATUIN_TMUX_RESURRECT_FILE

  # / is pane-local, ? is global, and j/k retain native in-memory traversal.
  bindkey -M vicmd '/' atuin-up-search-vicmd
  bindkey -M vicmd '?' atuin-search-vicmd
  bindkey -M vicmd 'j' down-line-or-history
  bindkey -M vicmd 'k' up-line-or-history
fi

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
