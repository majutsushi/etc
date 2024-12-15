#!/usr/bin/env python3

import signal
import sys

import i3ipc

OPACITY = "0.7"


def on_window_focus(ipc, event):
    global prev_focused

    focused_workspace = ipc.get_tree().find_focused()

    if focused_workspace is None:
        return

    focused = event.container

    if focused.id != prev_focused.id:  # https://github.com/swaywm/sway/issues/2859
        focused.command("opacity 1")
        prev_focused.command("opacity " + OPACITY)
        prev_focused = focused


def reset_opacity(ipc):
    for workspace in ipc.get_tree().workspaces():
        for w in workspace:
            w.command("opacity 1")
    ipc.main_quit()
    sys.exit(0)


if __name__ == "__main__":
    ipc = i3ipc.Connection()
    prev_focused = None

    for window in ipc.get_tree():
        if window.focused:
            prev_focused = window
        else:
            window.command("opacity " + OPACITY)
    for sig in [signal.SIGINT, signal.SIGTERM]:
        signal.signal(sig, lambda signal, frame: reset_opacity(ipc))
    ipc.on("window::focus", on_window_focus)
    ipc.main()
