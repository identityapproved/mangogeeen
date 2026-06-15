# Gentoo's /etc/zsh/zprofile resets PATH — put custom paths here, not in .zshrc

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Flatpak exports must be on XDG_DATA_DIRS before the compositor starts,
# so Quickshell (which inherits mango's env) can index flatpak .desktop files.
export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

# Auto-start mango on tty1
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec dbus-run-session mango
fi
