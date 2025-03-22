# Handle path
BREW_PATH="/opt/homebrew/bin"
CARGO_ENV_PATH="$HOME/.cargo/env"
BOB_NVIM_PATH="$HOME/.local/share/bob/nvim-bin"
SCRIPTS_PATH="$HOME/.scripts"
LCL_GO_PATH="$HOME/.local/share/go/bin"
JENV_ROOT="$HOME/.jenv"
export PYENV_ROOT="$HOME/.pyenv"
export NVM_DIR="$HOME/.nvm"

# Add homebrew to path (if exists)
[ -d $BREW_PATH ] && path+=($BREW_PATH)
# Load cargo env (if exists)
[ -f $CARGO_ENV_PATH ] && source $CARGO_ENV_PATH
# Add bob-nvim to path (if exists)
[ -d $BOB_NVIM_PATH ] && path+=($BOB_NVIM_PATH)
# Add .scripts to path (if exists)
[ -d $SCRIPTS_PATH ] && path+=($SCRIPTS_PATH)
# Add go to path (if exists)
[ -d $LCL_GO_PATH ] && path+=($LCL_GO_PATH)
# Add jenv to path (if exists)
[ -d $JENV_ROOT/bin ] && path+=("$JENV_ROOT/bin")
# Add pyenv to path (if exists)
[ -d $PYENV_ROOT/bin ] && path+=("$PYENV_ROOT/bin")
# Add nvm to path (if exists)
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
path+=($HOME/.local/bin)
export PATH

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

# Load aliases (if exists)
[ -f "$HOME/.aliasrc" ] && source "$HOME/.aliasrc"
# Load additional rc (run commands) config (if exists) (TODO: replace add_env)
[ -f "$HOME/.addrc" ] && source "$HOME/.addrc"
# Load additional environment vars (if exists)
[ -f "$HOME/.add_env" ] && source "$HOME/.add_env"
# Load sh_funcs (if exists)
[ -n "$(ls -A $HOME/.sh_funcs 2>/dev/null)" ] && for f in $HOME/.sh_funcs/*; do source $f; done

# Load jenv (if exists)
[ -d $JENV_ROOT/bin ] && eval "$(jenv init -)"

# Load pyenv (if exists)
[ -d $PYENV_ROOT/bin ] && eval "$(pyenv init -)"
[ -d $PYENV_ROOT/bin ] && eval "$(pyenv virtualenv-init -)"

# Load nvm completion (if exists)
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Load zsh-syntax-highlighting (if exists); should be last.
ZSH_PLUGIN_ROOT="$HOME/.zsh/plugins"
[[ -d $ZSH_PLUGIN_ROOT/zsh-syntax-highlighting ]] && source "$ZSH_PLUGIN_ROOT/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" 2 > /dev/null
