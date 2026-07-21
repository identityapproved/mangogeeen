#!/bin/sh
# setup-liferea.sh — link the Tokyonight item-view CSS and apply Liferea prefs.
# Liferea keeps its preferences in GSettings (dconf), not in a config file, so
# they cannot be checked into this repo as dotfiles — this script is the
# reproducible record of them. Safe to re-run.
set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CONF="$HOME/.config/liferea"

if ! command -v liferea >/dev/null 2>&1; then
    echo "!! liferea is not installed; install it first" >&2
    exit 1
fi

# 1. Link the theme files INTO ~/.config/liferea, one by one.
#
#    Deliberately not a symlink of the whole directory. Liferea writes its own
#    data into this path — feedlist.opml, feedlist.opml.backup, user.js — so
#    pointing the directory at the repo drags subscriptions into the working
#    tree and leaves .gitignore papering over it. The repo carries theming and
#    config only; lists and the item DB live outside it and sync via the NAS
#    instead (see liferea/liferea-sync.sh).
if [ -L "$CONF" ]; then
    OLD=$(readlink -f "$CONF")
    echo ">> $CONF is a whole-directory symlink (old layout); migrating"
    rm "$CONF"
    mkdir -p "$CONF"
    # Under the old layout Liferea's data landed inside the repo. Move it out,
    # or this machine would come up with an empty subscription list while the
    # real one sat orphaned in the working tree.
    for data in feedlist.opml feedlist.opml.backup feedlist.opml.presync user.js; do
        if [ -f "$OLD/$data" ]; then
            mv "$OLD/$data" "$CONF/$data"
            echo "   moved $data out of the repo"
        fi
    done
fi
mkdir -p "$CONF"
for css in liferea.css gtk.css; do
    if [ -e "$CONF/$css" ] && [ ! -L "$CONF/$css" ]; then
        echo ">> Backing up existing $CONF/$css to $css.bak"
        mv "$CONF/$css" "$CONF/$css.bak"
    fi
    ln -sfn "$REPO/liferea/$css" "$CONF/$css"
done

# 2. Link the transparency plugin into Liferea's user plugin dir. libpeas looks
#    under XDG_DATA_HOME, not the config dir, so this cannot ride along on the
#    symlink above.
PLUGINS="$HOME/.local/share/liferea/plugins"
mkdir -p "$(dirname "$PLUGINS")"
if [ -L "$PLUGINS" ]; then
    :
elif [ -e "$PLUGINS" ]; then
    echo ">> Backing up existing $PLUGINS to $PLUGINS.bak"
    mv "$PLUGINS" "$PLUGINS.bak"
fi
ln -sfn "$REPO/liferea/plugins" "$PLUGINS"

# 3. Preferences.
set_key() {
    gsettings set net.sf.liferea "$1" "$2"
}

echo ">> Applying GSettings"

# Open links in zen, not the GNOME default handler. browser-id must be
# "manual" or the browser command below is ignored.
set_key browser-id 'manual'
set_key browser 'zen %s'
set_key browse-inside-application false

# Space pages down and then jumps to the next unread item (0=space,
# 1=ctrl-space, 2=alt-space).
set_key browse-key-setting 0

# Poll hourly. Per-feed intervals still override this.
set_key default-update-interval 60
set_key startup-feed-action 0

# Reading pane: auto-switch between the email-like and wide 3-pane layouts
# depending on window shape.
set_key default-view-mode 2
set_key toolbar-style 'icons'
set_key confirm-mark-all-read false

# Privacy: no JS in the item view, and tell sites so.
set_key disable-javascript true
set_key enable-itp true
set_key do-not-track true
set_key do-not-sell false

# Strip page chrome from fetched articles.
set_key enable-reader-mode true

# 4. Enable the transparency plugin, keeping whatever else is already active.
#    (This is the libpeas plugin list; the separate "enable-plugins" key is a
#    WebKit browser-plugin setting and is unrelated.)
echo ">> Enabling transparency plugin"
ACTIVE=$(gsettings get net.sf.liferea.plugins active-plugins)
NEW=$(ACTIVE="$ACTIVE" python3 -c '
import ast, os
plugins = ast.literal_eval(os.environ["ACTIVE"])
if "transparency" not in plugins:
    plugins.append("transparency")
print(repr(plugins))
')
gsettings set net.sf.liferea.plugins active-plugins "$NEW"

echo ">> Done. Restart Liferea — liferea.css and the plugin load only at startup."
