#!/usr/bin/env python3

import signal
import sys

import i3ipc

OPACITY = "0.7"

prev_focused = None
paused = False


def on_window_focus(ipc: i3ipc.Connection, event):
    if paused:
        return

    global prev_focused

    focused_workspace = ipc.get_tree().find_focused()

    if focused_workspace is None:
        return

    focused = event.container

    if focused.id != prev_focused.id:  # https://github.com/swaywm/sway/issues/2859
        focused.command("opacity 1")
        prev_focused.command("opacity " + OPACITY)
        prev_focused = focused


def set_opacity(ipc: i3ipc.Connection):
    global prev_focused
    for window in ipc.get_tree():
        if window.focused:
            prev_focused = window
        else:
            window.command("opacity " + OPACITY)


def reset_opacity(ipc: i3ipc.Connection):
    for workspace in ipc.get_tree().workspaces():
        for w in workspace:
            w.command("opacity 1")


def toggle_pause(ipc: i3ipc.Connection):
    global paused
    paused = not paused
    if paused:
        reset_opacity(ipc)
    else:
        set_opacity(ipc)


def shutdown(ipc: i3ipc.Connection):
    reset_opacity(ipc)
    ipc.main_quit()
    sys.exit(0)


if __name__ == "__main__":
    ipc = i3ipc.Connection()

    for sig in [signal.SIGINT, signal.SIGTERM]:
        signal.signal(sig, lambda _signal, _frame: shutdown(ipc))
    signal.signal(signal.SIGUSR1, lambda _signal, _frame: toggle_pause(ipc))

    set_opacity(ipc)
    ipc.on("window::focus", on_window_focus)
    ipc.main()
