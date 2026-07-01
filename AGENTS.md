# AGENTS.md

Personal dotfiles repo. Each top-level directory is a Stow package that maps to a location under `$HOME`.

## Layout / conventions

- Top-level directories are **GNU Stow** packages. Deploy with `stow -t "$HOME" <pkg>` from the repo root.
- Config is organized by tool/app, not by OS-path. Examples: `neovim/`, `zsh/`, `scripts/`, `tmux/`, `opencode/`, `vibe/`, `yazi/`, `zellij/`.
- `scripts/` contains custom binaries under `scripts/.local/bin/` and zsh completions under `scripts/.zsh/completions/`.
- Empty directories `cursor-linux/` and `cursor-macos/` exist for OS-specific Cursor settings; ignore them if they have no current content.
- Binary/scripts under `scripts/.local/bin/` are mostly personal helpers; edit carefully and respect existing `set -euo pipefail` style.

## Git workflow

- Commit messages follow **Conventional Commits** with a single-file/package scope, e.g. `neovim: update deps`, `scripts: add music export`, `opencode: use ollama`.
- The repo default model config lives in `opencode/.config/opencode/opencode.json` (`ollama-cloud/kimi-k2.7-code`).
- There is a custom commit helper script at `scripts/.local/bin/git-commit-conv` (Bash, interactive).
- There is also an OpenCode subagent at `opencode/.config/opencode/agent/commit.md` for automatic commits.

## Important config quirks

- `git/.gitconfig` sets `gpgsign = true` and a signing key. Commits will be signed if the key is available.
- `wezterm/.wezterm.lua` contains work-specific tab-layout macros that launch projects (`fs.action-ai`, `isignif`). Treat these as personal shortcuts; do not rewrite unless asked.
- `vibe/.vibe/config.toml` also contains API/provider configuration. Avoid leaking it.

## Editing guidance

- Neovim config is LazyVim-based. Custom plugins/override files are under `neovim/.config/nvim/lua/plugins/` and `lua/config/`. `lazy-lock.json` is checked in.
- `neovim/.config/nvim/stylua.toml` sets 2-space indentation and 120 column width. Use it when editing Lua files.
- MPV, Yazi, Zellij, WezTerm, Tmux, Aider, and Vibe configs are plain static config files. There is no build or test step.
- No package manifests, CI workflows, Makefile, or pre-commit hooks exist. Do not invent them.

## What to avoid

- Do not run `stow -t /Users/alexandrerousseau` on Linux; use `stow -t "$HOME"`.
- Do not commit generated spell files (`*.spl`, `*.sug`) or `mpv/.config/mpv/watch_later`; these are already gitignored.
- This is a personal config repo, not a shared app. Avoid unrelated refactors or adding documentation beyond config comments.
- Commit API key or sensible information since the repo is public
