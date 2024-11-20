# My Config files (dotfiles, nvim, etc.)

## Requirements:
- GNU stow (otherwise manual symlink)
- neovim v0.9.0 or above (otherwise don't include `nvim` in stow command)
- starship (otherwise don't include `shell` becuase `.zshrc` will error)
- tmux v3.??? (otherwise ERROR: `invalid option: allow-passthrough`)

## Dotfiles
For simplest setup clone to `$HOME/.dotfiles` (i.e. clone in `~` dir)
- Run `stow nvim shell` from repo root
- To remove configs run `stow -D nvim shell` from repo root

If cloned elsewhere:
- Run `stow -t $HOME nvim scripts shell` from repo root
- To remove configs run `stow -Dt $HOME nvim shell` from repo root

## Env and Dependencies
### Pre
`sudo apt update`

### GNU Stow (manage dotfiles)
`sudo apt install -y stow`

### Build Tools (to install (build) programs with cargo)
`sudo apt install -y build-essential cmake`

### CLI Search
`sudo apt install -y ripgrep`

### Tmux (Terminal multiplexer/window manager)
`sudo apt install -y tmux`
Install [plugin manager](https://github.com/tmux-plugins/tpm):
`git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm`

### Zsh Highlighting (For "Fish-like" syntax hightlighting)
Install [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
`git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/plugins/zsh-syntax-highlighting`

### Rust (Cargo)
Install [rustup](https://www.rust-lang.org/tools/install)
`curl -sSf https://sh.rustup.rs | sh`

### Starship
`cargo install starship`

### Bob (neovim version manager)
`cargo install bob-nvim`

### Neovim
`bob install stable && bob use stable`
