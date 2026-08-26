# My Config files (dotfiles, nvim, etc.)

## Requirements:
- GNU stow (otherwise manual symlink)
- neovim v0.11.4 or above (otherwise don't include `nvim` in stow command)
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

### Native Build Tools
- `sudo apt install -y build-essential cmake`

### Typst (Typesetting / document authoring → PDF)
- Typst is installed at the globally pinned version through Mise.
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
- [TPM](https://github.com/tmux-plugins/tpm) and the plugins declared in `.tmux.conf`
  are installed by `mise run dotfiles:setup`.

### Zsh
- `sudo apt install zsh`
- `sudo chsh $USER /usr/bin/zsh`
- Commands in `~/.config/zsh/functions` are autoloaded on first use. `.zshenv`
  registers commands needed by scripts and agents; `.zshrc` adds interactive commands and completions.
- Zenv is the eager directory-environment plugin. Use `zenv status`, `zenv allow`,
  `zenv deny`, and `zenv reload` to inspect and manage the nearest `.envrc`.
- Put unshared, device-specific exports and PATH setup in `~/.zshenv.local`; it is sourced by every zsh.
- Put unshared, device-specific interactive setup in `~/.zshrc.local`; it is sourced only interactively.
#### Highlighting (For "Fish-like" syntax hightlighting)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) is installed by
  `mise run dotfiles:setup` and loaded last by `.zshrc` when present.

### Rust and Cargo
- Install the Rust toolchain with [rustup](https://www.rust-lang.org/tools/install):
`curl -sSf https://sh.rustup.rs | sh`
- Cargo ships with the selected Rust toolchain. Use it for Rust projects and source-build fallbacks,
  not as the default owner of standalone global CLIs that publish binaries.

### Starship
- Starship is installed at the globally pinned version through Mise.

### Neovim
- [Bob](https://github.com/MordechaiHadad/bob) currently owns the Neovim installation
  (`bob install stable && bob use stable`); the Bob executable is installed through Mise.
- Bob remains the intentional owner because it supports stable/nightly releases, exact versions,
  commits, and source builds. Source builds require Git, CMake, and Clang or GCC on Unix.

#### Build Neovim from source through Bob
- Install the [Neovim build prerequisites](https://github.com/neovim/neovim/blob/master/BUILD.md):
  Git, CMake, a Clang or GCC toolchain, and the platform-specific build dependencies.
- Resolve the desired Neovim commit (for example, from the `stable` branch), then run:
  `bob install <commit-hash> && bob use <commit-hash>`.
- Set `enable_release_build = true` in Bob's configuration when the source build should be
  optimized and omit debug information.

### Mise (version-managed tools)
- Install [Mise](https://mise.jdx.dev/installing-mise.html):
  - macOS: `brew install mise`
  - Linux: follow the package-manager or installer instructions linked above
- Restart the shell, then explicitly install the tools declared in the global config: `mise install`
- Install the shell and tmux plugins declared by the dotfiles: `mise run dotfiles:setup`
- The global config pins Node, Python, uv, pnpm, Starship, Typst, ripgrep, fzf, Bat, GitHub CLI, and Bob.
  A project's checked-in `mise.toml` overrides any global tool version.
- Mise replaces NVM, pyenv, jenv, and zvm for runtime selection. Rust remains managed by rustup.
- Prefer checked-in, exact project pins: `mise use --pin <tool>@<version>`.
- Missing tools do not auto-install; run `mise install` after cloning a project or changing its tool versions.
- Tool-specific notes:
  - Mise provides the global Python and uv executables; uv owns project dependencies, lockfiles,
    and `.venv` directories.
  - Each project should choose one Python runtime owner. Multi-tool projects should pin Python in
    `mise.toml` and use uv for the environment. Python-centric projects may instead omit Python
    from `mise.toml` and let uv select/install it from `.python-version` and `requires-python`.
  - Global pnpm is the convenient default; Node projects should pin Node and pnpm together.
    Neovim also needs npm to install Pyright.
  - Authenticate GitHub CLI once with `gh auth login`; Mise only owns the executable.
  - Bat provides syntax-highlighted fzf previews for `glg`.
  - Go and Java have no global default yet; projects that need them should pin them.
  - Zig and ZLS have no global default yet; they are separate tools and should be pinned together.

#### Tool ownership roadmap

| Owner | Tools | Direction |
| --- | --- | --- |
| Mise now | Node, Python, uv, pnpm, Starship, Typst, ripgrep, fzf, Bat, GitHub CLI, Bob | Global defaults plus exact project overrides. |
| Mise when needed | Java, Go, Zig, ZLS | No global pins yet; add deliberately or pin per project. |
| rustup | Rust, Cargo | Rust toolchains and project components; Cargo comes with Rust. |
| Bob | Neovim | Intentional owner, including source-build support. |
| Homebrew/apt | tmux, Stow, native build tools | Keep system-linked tools native. |
| Vendor/native installers | gcloud, Docker, Xcode | Keep component managers, daemons, authentication, and platform integration native. |
