# My Config files (dotfiles, nvim, etc.)

## Requirements:
- GNU stow (otherwise manual symlink)
- neovim v0.11.4 or above (otherwise don't include `nvim` in stow command)
- starship (otherwise don't include `shell` becuase `.zshrc` will error)
- tmux v3.4 (otherwise ERROR: `invalid option: allow-passthrough`)

## Dotfiles
For simplest setup clone to `$HOME/.dotfiles` (i.e. clone in `~` dir)
- Run `stow nvim shell` from repo root
- To remove configs run `stow -D nvim shell` from repo root

If cloned elsewhere:
- Run `stow -t $HOME nvim shell` from repo root
- To remove configs run `stow -Dt $HOME nvim shell` from repo root

## Env and Dependencies
### Pre
- `sudo apt update`

### GNU Stow (manage dotfiles)
- `sudo apt install -y stow`

### Build Tools (to install (build) programs with cargo)
- `sudo apt install -y build-essential cmake`

### CLI Search
- `sudo apt install -y ripgrep`

### Typst (Typesetting / document authoring → PDF)
- macOS: `brew install typst`  •  Linux: `cargo install typst-cli` (or grab a [release](https://github.com/typst/typst/releases))
- The `tinymist` language server (completion, diagnostics, format, PDF export on save) auto-installs
  via Mason the first time you open a `.typ` file in neovim. Live preview via `typst-preview.nvim`.
- In a `.typ` buffer (localleader is `\`): `\p` toggle preview · `\e` export PDF · `\o` open PDF · `\f` format.
- Three local templates live in the `shell` package (`~/.local/share/typst/packages/local/`) and
  resolve via `TYPST_PACKAGE_PATH` (set in `.zshenv`), so they import identically on macOS and Linux:
  - `#import "@local/letter:0.1.0": letter` — business letter
  - `#import "@local/doc:0.1.0": doc` — basic document (or just write plain typst)
  - `#import "@local/slides:0.1.0": slides, title-slide, slide` — minimal 16:9 deck
- Starter examples to open + preview: `~/typst/{letter,doc,slides}.typ`.

### Tmux (Terminal multiplexer/window manager)
- `sudo apt install -y tmux`
- Install [plugin manager](https://github.com/tmux-plugins/tpm):
`git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm`

### Zsh
- `sudo apt install zsh`
- `sudo chsh $USER /usr/bin/zsh`
#### Highlighting (For "Fish-like" syntax hightlighting)
- Install [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting):
`git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/plugins/zsh-syntax-highlighting`

### Rust (Cargo)
- Install [rustup](https://www.rust-lang.org/tools/install):
`curl -sSf https://sh.rustup.rs | sh`

### Starship
- `cargo install starship`

### Bob (neovim version manager)
- `cargo install bob-nvim`

### Neovim
- `bob install stable && bob use stable`
#### Build from source (for unsupported systems) [ref](https://github.com/neovim/neovim/blob/master/INSTALL.md#install-from-source)
- Install prereqs: `sudo apt-get install ninja-build gettext cmake curl build-essential git`
- Clone and checkout stable: `git clone https://github.com/neovim/neovim && cd neovim && git checkout stable`
- Build: `make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.local/share/neovim"`
- Install: `make install`

## Additional Env setup
### GitHub CLI
- Install [gh](https://github.com/cli/cli/blob/trunk/docs/install_linux.md):
```
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
```
- Login: `gh auth login`

### Go
- Go is managed by Mise when needed: `mise use --pin go@<version>`.

### Mise (runtime versions)
- Install [Mise](https://mise.jdx.dev/installing-mise.html):
  - macOS: `brew install mise`
  - Linux: follow the package-manager or installer instructions linked above
- Restart the shell, then explicitly install the tools declared in the global config: `mise install`
- The global defaults are Node `24.19.0` and Python `3.12.12`. A project's checked-in `mise.toml` overrides them.
- Mise replaces NVM, pyenv, jenv, and zvm for runtime selection. Rust remains managed by rustup.
- Prefer a checked-in `mise.toml` for new projects: `mise use --pin node@24.19.0`
- Missing tools do not auto-install; run `mise install` after cloning a project or changing its tool versions.

### Python
- Python is managed by Mise. The global version is declared in the Mise config.
- Prefer a project-local `.venv` for dependencies and isolation.

### Node
- Node is managed by Mise. Install the globally declared version with `mise install`.
- Projects must declare their Node version in a checked-in `mise.toml`.
- NOTE: neovim will complain about not being able to install pyright if missing npm

### Java
- Java is managed by Mise when needed: `mise use --pin java@<version>`.

### Zig
- Zig and ZLS are managed separately by Mise:
  `mise use --pin zig@<version> zls@<version>`.
