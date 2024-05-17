# Use Starship For Prompt (may switch to PS1 in the future)
eval "$(starship init zsh)"

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
autoload -U compinit
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

# Load aliases if exist
[ -f "$HOME/.aliasrc" ] && source "$HOME/.aliasrc"
# Load additional environment vars if exist
[ -f "$HOME/.add_env" ] && source "$HOME/.add_env"

# Load scripts if exist
# [ -d "$HOME/.scripts" ] && for f in $HOME/.scripts/*; do source $f; done
[ -n "$(ls -A $HOME/.scripts 2>/dev/null)" ] && for f in $HOME/.scripts/*; do source $f; done

# Load nvm
[ -d "/usr/local/nvm" ] && source /usr/local/nvm/nvm.sh

# Load zsh-syntax-highlighting; should be last.
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2 > /dev/null
