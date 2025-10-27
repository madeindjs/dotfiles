# dotfiles

My dotfiles managed by [GNU Stow](https://www.gnu.org/software/stow/) [^1]

## Usage

```sh
stow -t /Users/alexandrerousseau aider
```

You also need to install ZSH autocompletion

```zsh
# ~/.zshrc
fpath=($HOME/.zsh/completions $fpath)
autoload -Uz compinit
```
