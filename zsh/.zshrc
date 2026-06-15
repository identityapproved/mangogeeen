#  On the PATH warning from Portage: Gentoo's system /etc/zsh/zprofile runs env-update which
#  resets PATH. If you later need to add custom paths (like $GOPATH/bin), put them in
#  ~/.zprofile, not in .zshrc or .zshenv. I'll create that file when you need it.
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export MANPAGER="nvim +Man!"
export GOPATH="$HOME/go"
export XDG_DATA_HOME="$HOME/.local/share"
export AGENTSDOTS_ROOT="/mnt/kodak/github/agentsdots"

ZSH_THEME="random"

zstyle ':omz:update' mode auto
zstyle ':completion::complete:*' use-cache 1

HIST_STAMPS="dd.mm.yyyy"

plugins=(
  git
  gitignore
  web-search
  pip
  python
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-vi-mode
  cd-ls
  zsh-git-fzf
  alias-tips
)

source $ZSH/oh-my-zsh.sh
source $HOME/.aliases

# FZF — key-bindings (CTRL+R history, CTRL+T files, ALT+C cd)
source /usr/share/fzf/key-bindings.zsh
# completions (_fzf) auto-loaded from /usr/share/zsh/site-functions via compinit

export FZF_DEFAULT_OPTS='--reverse --preview="bat {}" --info=inline --color=fg:#c0caf5,bg:-1,hl:#ff9e64 --color=fg+:#c0caf5,bg+:#292e42,gutter:-1,hl+:#ff9e64 --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff --color=marker:#9ece6a,spinner:#9ece6a,header:#565f89'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :100 {}'"
export FZF_ALT_C_OPTS="--preview 'ls -1 {}'"
# Tokyo Night for bat (install theme: github.com/0xTadash1/bat-into-tokyonight, then `bat cache --build`)
export BAT_THEME="tokyonight_night"

# yazi: cd on exit
function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# nvim fuzzy config switcher
function vff() {
  local config=$(fd --max-depth 1 --glob 'nvim-*' ~/.config | fzf --prompt="Neovim Configs > " --height=15% --layout=reverse --border --exit-0)
  [[ -z "$config" ]] && echo "No config selected" && return
  NVIM_APPNAME=$(basename "$config") nvim "$@"
}

# Flatpak: include exported desktop/icon data for installed flatpaks
export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

# zoxide must stay at the very end of this file
eval "$(zoxide init --cmd cd zsh)"
