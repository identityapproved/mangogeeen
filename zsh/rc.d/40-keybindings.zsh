# fzf key-bindings: CTRL-R history, CTRL-T files, ALT-C cd.
# Deferred via zvm_after_init: zsh-vi-mode rebuilds the viins keymap on the first
# prompt and would otherwise clobber fzf's insert-mode CTRL-R (leaving normal mode
# working but insert mode falling back to zsh's default history search).
# Completions (_fzf) come from /usr/share/zsh/site-functions via compinit.
zvm_after_init_commands+=('source /usr/share/fzf/key-bindings.zsh')

export FZF_DEFAULT_OPTS='--reverse --preview="bat {}" --info=inline --color=fg:#c0caf5,bg:-1,hl:#ff9e64 --color=fg+:#c0caf5,bg+:#292e42,gutter:-1,hl+:#ff9e64 --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff --color=marker:#9ece6a,spinner:#9ece6a,header:#565f89'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :100 {}'"
export FZF_ALT_C_OPTS="--preview 'ls -1 {}'"
