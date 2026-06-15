#!/usr/bin/env python3
"""mango IPC -> Ironbar feed.

Ironbar has no native dwl/mango module, so this bridges mango's `mmsg watch`
JSON streams into single-line output for Ironbar `script`/`custom` modules in
"watch" mode (each printed line replaces the module's content).

Usage (one process per module):
    mango-ipc.py tags    [--monitor NAME]   # Pango markup, one glyph per tag
    mango-ipc.py title   [--max 80]         # focused window title
    mango-ipc.py layout                     # keyboard layout, abbreviated

Waybar does NOT use this — it reads tags/title from native ext/workspaces and
dwl/window. This feed exists only for the Ironbar (second) bar.

mmsg JSON shapes (mango 0.14.2; probed, not documented in the wiki):
    all-tags        {"all_tags":[{"monitor","tags":[{"index","is_active",
                                   "is_urgent","layout","client_count"}]}]}
    focusing-client {"id","title","appid","monitor","tags":[...], ...}
    keyboardlayout  {"layout":"English (US)"}
`watch` emits full state immediately, then re-emits the same shape on change.
"""

import argparse
import html
import json
import subprocess
import sys
import time

# Inline Pango colors (Ironbar script labels can't take CSS classes, so style
# inline here; tweak to match the ironbar theme once it's in place).
COLOR_ACTIVE = "#7aa2f7"   # focused tag
COLOR_OCCUPIED = "#c0caf5"  # has clients, not focused
COLOR_EMPTY = "#565f89"    # no clients
COLOR_URGENT = "#f7768e"   # urgent

# Layout abbreviations for the keyboard-layout module.
LAYOUT_ABBR = {
    "English (US)": "US",
}


def stream(event, *extra):
    """Yield parsed JSON objects from `mmsg watch <event>`, restarting on death."""
    cmd = ["mmsg", "watch", event, *extra]
    while True:
        proc = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, text=True, bufsize=1
        )
        try:
            for line in proc.stdout:
                line = line.strip()
                if not line:
                    continue
                try:
                    yield json.loads(line)
                except json.JSONDecodeError:
                    continue
        finally:
            proc.terminate()
        # mmsg exited (compositor restart/socket drop); back off and retry.
        time.sleep(1)


def emit(text):
    print(text, flush=True)


def run_tags(monitor):
    last = None
    for msg in stream("all-tags"):
        mons = msg.get("all_tags", [])
        chosen = None
        if monitor:
            chosen = next((m for m in mons if m.get("monitor") == monitor), None)
        if chosen is None and mons:
            chosen = mons[0]
        if chosen is None:
            continue
        parts = []
        for t in chosen.get("tags", []):
            idx = t.get("index", "?")
            if t.get("is_urgent"):
                color = COLOR_URGENT
            elif t.get("is_active"):
                color = COLOR_ACTIVE
            elif t.get("client_count", 0) > 0:
                color = COLOR_OCCUPIED
            else:
                color = COLOR_EMPTY
            weight = "bold" if t.get("is_active") else "normal"
            parts.append(
                f'<span foreground="{color}" weight="{weight}">{idx}</span>'
            )
        out = " ".join(parts)
        if out != last:
            emit(out)
            last = out


def run_tag(index, monitor):
    """Emit one tag's styled glyph (for a single clickable Ironbar button)."""
    last = None
    for msg in stream("all-tags"):
        mons = msg.get("all_tags", [])
        chosen = None
        if monitor:
            chosen = next((m for m in mons if m.get("monitor") == monitor), None)
        if chosen is None and mons:
            chosen = mons[0]
        if chosen is None:
            continue
        t = next((x for x in chosen.get("tags", []) if x.get("index") == index), None)
        if t is None:
            continue
        if t.get("is_urgent"):
            color = COLOR_URGENT
        elif t.get("is_active"):
            color = COLOR_ACTIVE
        elif t.get("client_count", 0) > 0:
            color = COLOR_OCCUPIED
        else:
            color = COLOR_EMPTY
        weight = "bold" if t.get("is_active") else "normal"
        out = f'<span foreground="{color}" weight="{weight}">{index}</span>'
        if out != last:
            emit(out)
            last = out


def run_title(max_len):
    last = None
    for msg in stream("focusing-client"):
        title = msg.get("title") or ""
        if max_len and len(title) > max_len:
            title = title[: max_len - 1].rstrip() + "…"
        out = html.escape(title)
        if out != last:
            emit(out)
            last = out


def run_layout():
    last = None
    for msg in stream("keyboardlayout"):
        layout = msg.get("layout") or ""
        out = LAYOUT_ABBR.get(layout, layout)
        if out != last:
            emit(out)
            last = out


def main():
    p = argparse.ArgumentParser(description="mango mmsg -> Ironbar feed")
    sub = p.add_subparsers(dest="mode", required=True)

    pt = sub.add_parser("tags", help="all tag indicators (Pango markup)")
    pt.add_argument("--monitor", default=None,
                    help="monitor name (default: first reported)")

    pg = sub.add_parser("tag", help="one tag's indicator (for a single button)")
    pg.add_argument("index", type=int, help="tag index (1-based)")
    pg.add_argument("--monitor", default=None,
                    help="monitor name (default: first reported)")

    pw = sub.add_parser("title", help="focused window title")
    pw.add_argument("--max", type=int, default=80, dest="max_len",
                    help="truncate title to N chars (0 = no limit)")

    sub.add_parser("layout", help="keyboard layout, abbreviated")

    args = p.parse_args()
    try:
        if args.mode == "tags":
            run_tags(args.monitor)
        elif args.mode == "tag":
            run_tag(args.index, args.monitor)
        elif args.mode == "title":
            run_title(args.max_len)
        elif args.mode == "layout":
            run_layout()
    except KeyboardInterrupt:
        pass
    except BrokenPipeError:
        sys.exit(0)


if __name__ == "__main__":
    main()
