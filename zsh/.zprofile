# Gentoo's /etc/zsh/zprofile resets PATH — put custom paths here, not in .zshrc

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"  # `go install` binaries (clipse, catnip, …)

# Flatpak exports must be on XDG_DATA_DIRS before the compositor starts, so launchers
# that inherit mango's env (walker) can index flatpak .desktop files. Single source of
# truth — do not also set XDG_DATA_DIRS in mango/config.conf (it would clobber this).
export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

# GPU OpenCL: enable Rusticl on radeonsi (RX 580) for darktable et al.
export RUSTICL_ENABLE=radeonsi

# nb notebooks. Set before the mango exec below so everything the compositor
# spawns (waybar's nb module, terminals) sees the same notebook dir.
export NB_DIR="/mnt/kodak/nb"

# Auto-start mango on tty1
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec dbus-run-session mango
fi
