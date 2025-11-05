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
- Run `stow -t $HOME nvim scripts shell` from repo root
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
- Find link to correct version of [go](https://go.dev/dl/) (e.g. https://go.dev/dl/go1.23.3.linux-amd64.tar.gz)
- Install go (in this case to local user, alternatively can [global install](https://go.dev/doc/install)):
`curl -sL https://go.dev/dl/go1.23.3.linux-amd64.tar.gz | tar -C $HOME/.local/share -xzf -`

### Python
- Install [pip](https://pip.pypa.io/en/stable/installation/#get-pip-py):
`curl -sS https://bootstrap.pypa.io/get-pip.py | python3`
- Install [pyenv](https://github.com/pyenv/pyenv):
`git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv`
- Install [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv?tab=readme-ov-file#installing-as-a-pyenv-plugin):
`git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv`
- Setup env for [pyenv](https://github.com/pyenv/pyenv/wiki#suggested-build-environment)
(required to run `pyenv install x.x.x`):
```
sudo apt update; sudo apt install build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
```

### Node
- Intall [nvm](https://github.com/nvm-sh/nvm):
`git clone https://github.com/nvm-sh/nvm.git $HOME/.nvm`
- `nvm install stable && nvm use stable`
- NOTE: neovim will complain about not being able to install pyright if missing npm

### Java
- Install [jenv](https://github.com/jenv/jenv):
`git clone https://github.com/jenv/jenv.git ~/.jenv`
- First time run: `jenv enable-plugin export`
- Continue following to setup [jenv](https://github.com/jenv/jenv?tab=readme-ov-file#13-adding-your-java-environment)
 - Notes:
  - When using brew to install java, it will provide the correct symlink command in its output
  - The provided `jenv add` command does not seem to work, use `jenv add /Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home` (after symlinking) instead
- Example for openjdk version 21 (Mac):
```
brew install openjdk@21
sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk
jenv add /Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home
```
- Example for openjdk version 17 (Linux):
```
sudo apt install openjdk-17-jdk
jenv add /usr/lib/jvm/java-17-openjdk-amd64
jenv global openjdk64-17.0.17
```

### Zig
- Install [zvm](https://www.zvm.app/guides/install-zvm/):
`curl https://raw.githubusercontent.com/tristanisham/zvm/master/install.sh | bash`
- Check for most recent stable version at [zig website](https://ziglang.org/download/)
- Run: `zvm i --zls <version> && zvm use <version>`
