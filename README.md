# My Config files (dotfiles, nvim, etc.)

## Requirements:
- GNU stow (otherwise manual symlink)
- neovim v0.9.0 or above (otherwise don't include `nvim` in stow command)
- starship (otherwise don't include `shell` becuase `.zshrc` will error)


## Setup
For simplest setup clone to `$HOME/.dotfiles` (i.e. clone in `~` dir)
- Run `stow nvim shell` from repo root
- To remove configs run `stow -D nvim shell` from repo root

If cloned elsewhere:
- Run `stow -t $HOME nvim scripts shell` from repo root
- To remove configs run `stow -Dt $HOME nvim shell` from repo root
