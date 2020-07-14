import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from time import strftime
from typing import Iterable, Optional

from ranger.api.commands import Command


class movetotrash(Command):
    """:movetotrash

    Moves the selection or the current file to the XDG trash.
    """

    def execute(self) -> None:

        if self.rest(1):
            self.fm.notify(
                "Error: movetotrash takes no arguments! It "
                "operates on the selected file(s).",
                bad=True,
            )
            return

        try:
            trash_dir = Path(os.environ["XDG_DATA_HOME"]) / "Trash"
        except KeyError:
            trash_dir = Path(os.environ["HOME"]) / ".local" / "share" / "Trash"

        selected = self.fm.thistab.get_selection()
        self.fm.copy_buffer -= set(selected)
        if selected:
            for f in selected:
                dest = trash_dir / "files" / f.basename
                basename = f.basename
                if dest.exists():
                    counter = 2
                    while os.path.exists(os.fspath(dest) + "." + str(counter)):
                        counter += 1
                    basename += "." + str(counter)
                with open(trash_dir / "info" / (basename + ".trashinfo"), "w") as info:
                    info.write(
                        "[Trash Info]\n"
                        + f"Path={f.path}\n"
                        + f"DeletionDate={strftime('%Y-%m-%dT%H:%M:%S')}\n"
                    )
                shutil.move(f.path, trash_dir / "files" / basename)
        self.fm.thistab.ensure_correct_pointer()


class fzfjump(Command):
    """:fzfjump

    Use fzf to quickly jump to recent dirs
    """

    def execute(self) -> None:
        with open(Path.home() / ".var/lib/zsh/recent-dirs") as f:
            entries = (" ".join(line.split()[3:]) for line in f)
            unique_entries = list(dict.fromkeys(entries))
            directory = (
                subprocess.run(
                    ["fzf", "-e", "+s", "+m"],
                    check=False,
                    input="\n".join(unique_entries).encode(sys.stdin.encoding),
                    stdout=subprocess.PIPE,
                )
                .stdout.strip()
                .decode(sys.stdout.encoding)
            )
            self.fm.cd(directory)
            self.fm.ui.redraw_window()


class scp(Command):
    def execute(self) -> None:
        if self.arg(1):
            scpcmd = ["scp", "-r"]
            scpcmd.extend([f.realpath for f in self.fm.thistab.get_selection()])
            scpcmd.append(self.arg(1))
            self.fm.execute_command(scpcmd)
            self.fm.notify("Uploaded!")

    def tab(self, tabnum: int) -> Optional[Iterable]:
        try:
            with open(Path.home() / ".ssh/config") as file:
                host_lines = (line for line in file if re.match("^Host ", line))
                hosts_set = set()
                for line in host_lines:
                    hosts_set |= set(line.split()[1:])
        except IOError:
            print("Can't open ssh config")
            return None

        hosts = sorted(list(hosts_set))
        # remove any wildcard host settings since they're not real servers
        hosts = [host for host in hosts if host.find("*") == -1]
        query = self.arg(1) or ""
        matching_hosts = [host for host in hosts if host.startswith(query)]
        return (self.start(1) + host + ":" for host in matching_hosts)
