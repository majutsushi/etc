#!/usr/bin/env python3
# Author: Jan Larres <jan@majutsushi.net>
# License: MIT/X11
#
# ruff: noqa: S603, S607

import argparse
import os
import subprocess
import sys
from pathlib import Path

import i3ipc  # type: ignore[reportMissingTypeStubs]

WALLPAPERS_DIR = Path(os.environ["XDG_DATA_HOME"]) / "wallpapers"


def main(args: argparse.Namespace) -> int:
    mode = args.mode
    if args.mode == "auto":
        try:
            subprocess.run(["is-dark-mode"], check=True)
            mode = "dark"
        except subprocess.CalledProcessError:
            mode = "light"

    sway = i3ipc.Connection()
    set_wallpapers(sway, mode)
    if args.wallpapers_only:
        return 0

    set_colours(sway, mode == "dark")

    return 0


def set_wallpapers(sway: i3ipc.Connection, mode: str):
    outputs = sway.get_outputs()
    for output in outputs:
        transform = output.transform  # type: ignore[reportAttributeAccessIssue]
        output_name = output.name  # type: ignore[reportAttributeAccessIssue]
        orientation = "vert" if "90" in transform or "270" in transform else "horiz"
        wp_path = WALLPAPERS_DIR / f"wallpaper-{orientation}-{mode}.png"
        if wp_path.exists():
            sway.command(f"output {output_name} bg {wp_path} fill")
        else:
            print(f"Wallpaper {wp_path} not found")


def set_colours(sway: i3ipc.Connection, is_dark: bool):
    # defaults: https://github.com/swaywm/sway/blob/5312376077254d6431bb92ba22de3840b9933f67/sway/config.c#L314
    if is_dark:
        # class                               border  backgr. text    indicator child_border
        sway.command("client.focused          #6B8E23 #6B8E23 #FFFFFF #00FF00 #6B8E23")
        sway.command("client.focused_inactive #222222 #222222 #888888 #222222 #222222")
        sway.command("client.unfocused        #222222 #222222 #888888 #222222 #222222")
        sway.command("client.urgent           #900000 #900000 #FFFFFF #900000 #900000")
    else:
        # class                               border  backgr. text    indicator child_border
        sway.command("client.focused          #39ADB5 #39ADB5 #FFFFFF #00FF00 #39ADB5")
        sway.command("client.focused_inactive #BBBBBB #BBBBBB #000000 #BBBBBB #BBBBBB")
        sway.command("client.unfocused        #BBBBBB #BBBBBB #000000 #BBBBBB #BBBBBB")
        sway.command("client.urgent           #900000 #900000 #FFFFFF #900000 #900000")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="update Sway wallpapers")
    parser.add_argument(
        "mode", choices=["dark", "light", "auto"], help="the mode to set"
    )
    parser.add_argument(
        "--wallpapers-only",
        action="store_true",
        help="only change wallpapers, not colours",
    )
    return parser.parse_args()


if __name__ == "__main__":
    sys.exit(main(parse_args()))
