# .zshenv — sourced for EVERY zsh (login, interactive, scripts), before all else.
# Keep it minimal and side-effect-free: only environment that non-interactive
# shells and scripts also need. Interactive-only setup lives in rc.d/.
#
# PATH is intentionally NOT here: Gentoo's /etc/zsh/zprofile runs `env-update`,
# which resets PATH *after* .zshenv is read. PATH lives in .zprofile.

export EDITOR="nvim"
export MANPAGER="nvim +Man!"
export GOPATH="$HOME/go"
export XDG_DATA_HOME="$HOME/.local/share"
export AGENTSDOTS_ROOT="/mnt/kodak/github/agentsdots"
export ZK_NOTEBOOK_DIR="/mnt/kodak/zettelnotes"
export ZETTEL_DIR="/mnt/kodak/zettelnotes"
export BAT_THEME="tokyonight_night"   # used by bat, the cat= alias, and fzf previews
