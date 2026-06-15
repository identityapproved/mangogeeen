#!/usr/bin/env bash
# Install oh-my-zsh custom plugins
set -euo pipefail

ZSH_CUSTOM_PLUGINS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
mkdir -p "$ZSH_CUSTOM_PLUGINS"

clone() {
  local repo="$1" dest="$ZSH_CUSTOM_PLUGINS/$(basename "$1")"
  if [[ -d "$dest" ]]; then
    echo "  exists: $(basename "$dest")"
  else
    git clone --depth=1 "https://github.com/$repo" "$dest"
    echo "  cloned: $(basename "$dest")"
  fi
}

clone zsh-users/zsh-syntax-highlighting
clone zsh-users/zsh-autosuggestions
clone zshzoo/cd-ls
clone jeffreytse/zsh-vi-mode
clone djui/alias-tips
clone alexiszamanidis/zsh-git-fzf

echo "Done — restart zsh or: source ~/.zshrc"
