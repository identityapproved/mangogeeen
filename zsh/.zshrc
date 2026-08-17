# .zshrc — interactive shells only. Thin loader.
#
# zsh load order: .zshenv (all shells) -> .zprofile (login: PATH, mango exec)
#                 -> .zshrc (this file) -> .zlogin.
#
# Real config lives in rc.d/*.zsh, sourced below in filename order (00, 10, 20 …).
# ${(%):-%x} is this file's own path; :A resolves the ~/.zshrc symlink back to the
# mangogeeen repo, so modules load from there and don't each need symlinking.
# To extend, drop a NN-name.zsh into rc.d/ — no edit here needed.

_rcd="${${(%):-%x}:A:h}/rc.d"
for _f in "$_rcd"/*.zsh(N); do
  source "$_f"
done
unset _rcd _f

# opencode
export PATH=$HOME/.opencode/bin:$PATH
