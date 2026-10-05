# Dotfiles

Personal macOS/Linux configuration managed with GNU Stow. Zsh owns shell
startup; Mise owns portable executables and runtime versions.

## Setup

```sh
# macOS
brew install stow tmux mise

# Debian/Ubuntu
sudo apt update
sudo apt install -y git stow zsh tmux
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
```

Tmux 3.4 or newer is required.

```sh
git clone git@github.com:DeLaPF/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
mise trust
mise run setup

chsh -s "$(command -v zsh)"
exec zsh

bob use stable
```

`mise run setup` stows every package with `--no-folding`, installs pinned
executables, and runs the idempotent Git, Zsh-plugin, and tmux-plugin setup
tasks. No-folding keeps shared directories such as `~/.config` and `~/.local`
real, allowing packages to overlap without capturing runtime files in this
repository. Pass package names to select a subset, such as
`mise run setup shell agents`; shell-owned tools and plugins are configured
only when `shell` is selected. Use `--target "$HOME"` when the repository is
cloned somewhere other than `~/.dotfiles`. Rerun setup after changing package
or tool pins.

Remove the links with
`stow -D nvim shell agents`.

## Shell

- `.zshenv` provides universal PATH, exports, core commands, Zenv, and Mise to
  terminals, scripts, editors, and agents.
- `.zprofile` restores Mise precedence after macOS login-shell `path_helper`.
- `.zshrc` adds interactive aliases, completion, keybindings, Starship, and
  syntax highlighting. Atuin keeps history local: normal-mode `/` searches the
  current tmux pane, while normal-mode `?` searches globally; tmux-resurrect
  preserves pane history identities.
- Device-only configuration belongs in `~/.zshenv.local` or `~/.zshrc.local`.
- Functions are autoloaded from `~/.config/zsh/functions`; `refr` replaces the
  current shell after configuration changes.
- Git helpers are native subcommands: `git cb`, `git rs`, `git po`, and `git lg`.
  Shared defaults use XDG config; normal `git config --global` writes stay in
  the machine-specific `~/.gitconfig` reserved by `dotfiles:setup`.
- Zenv loads the nearest trusted `.envrc`: `zenv status|allow|deny|reload`.
- Optional `.cmdsrc`/`.linksrc` files use `[group|alias]` headings (`!` hides a
  group) and `label :: command`/`label URL` entries.

## Agent messaging

`agent-msg peers` lists reachable Claude sessions and recent Codex threads.
Send with `agent-msg send claude:TARGET MESSAGE` or
`agent-msg send codex:TARGET MESSAGE`; each message includes a return command.
An active Codex turn is steered immediately; an idle or non-steerable thread is
queued for its next turn.
Claude messages use its peer socket, which preserves the peer-message trust
boundary. Because peer turns may not render in Remote Control, each Claude
message asks it to run a target-bound `agent-msg ack` command first. The tool
output shows the complete envelope exactly as sent, including the generated
reply and acknowledgement instructions, without Claude regenerating anything.
Receipts are private runtime files, deleted after a successful acknowledgement,
and expire after one day if never acknowledged.

## Worktrees

The `worktrees` plugin provides `bare-clone` and `gwt` and is installed by the
normal `stow shell`. To use it without the rest of these dotfiles, copy
`shell/.config/zsh/plugins/worktrees` to `~/.config/zsh/plugins/`, then add this
to `~/.zshenv` so terminals and agents both load it:

```zsh
source "$HOME/.config/zsh/plugins/worktrees/worktrees.plugin.zsh"
```

`bare-clone URL` creates `repo/.bare` plus an initial worktree for the default
branch. From any worktree, `gwt -c [name] [base]` creates a sibling branch and
worktree. Names use a lowercase, underscore-normalized login from the
authenticated GitHub CLI: a named worktree starts as `github_login__name`,
adding `__YYYY_MM_DD` and then `__HH_MM` only on collisions. Without a name, it starts as
`github_login__YYYY_MM_DD` and adds the time on collision. `gwt -m name`
renames the current branch and worktree using the same ladder. Optional
`.ctx/` contents are copied into new worktrees; executable
`.worktree-hooks/on-create` and `on-remove` scripts run around creation and
removal.

## Tool ownership

| Owner | Tools |
| --- | --- |
| Mise | Node, Python, uv, pnpm, Starship, Typst, ripgrep, fzf, Bat, GitHub CLI, Bob, Tree-sitter CLI, Atuin |
| Bob | Neovim stable/nightly, exact versions, commits, and source builds |
| Mason | Neovim LSPs and editor-only tools |
| [rustup](https://www.rust-lang.org/tools/install) | Rust and Cargo |
| Homebrew/apt | tmux, Stow, and native build tools |
| Native installers | gcloud, Docker, and Xcode |

Projects override global Mise versions with a checked-in `mise.toml`. Prefer
`mise use --pin TOOL@VERSION`; missing tools never auto-install. Java, Go, Zig,
and ZLS have no global defaults yet and should be pinned when needed.

Node projects should pin Node and pnpm together. Mise provides global Python
and uv; uv owns project dependencies, locks, and `.venv`. Python-centric
projects may instead let uv own Python via `.python-version` and
`requires-python`.

Mise provides TypeScript 6 only as the `typescript-tools.nvim` fallback;
project-local TypeScript versions take precedence.

Global pnpm executables live in `$PNPM_HOME/bin`. A shell guard rejects global
commands under project-pinned pnpm versions older than 11; leave the project to
use the global Mise version instead.

Standalone Python dependencies use PEP 723 metadata:

```sh
uv add --script file.py package
uv run file.py
uv lock --script file.py  # optional
```

`plg --help` carries the same reminder.

## Neovim and Typst

Bob installs Neovim 0.12 or newer; `lazy-lock.json` pins its plugins. Source
builds need the platform's
[Neovim prerequisites](https://github.com/neovim/neovim/blob/master/BUILD.md),
then `bob use COMMIT`. Set `enable_release_build = true`
in Bob's config for an optimized build.

Mise installs Typst and Mason installs Tinymist. In Typst buffers, `\p` toggles
preview, `\e` exports, `\o` opens the PDF, and `\f` formats. Local packages are:

```typst
#import "@local/letter:0.1.0": letter
#import "@local/doc:0.1.0": doc
#import "@local/slides:0.1.0": slides, title-slide, slide
```

## Updating

- Bump Mise tool versions or plugin refs, then run `mise install` and
  `mise run dotfiles:setup`.
- Update Neovim plugins with `:Lazy update` and commit `lazy-lock.json`.
- Move Neovim with `bob use VERSION`.
