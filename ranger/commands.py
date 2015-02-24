from ranger.api.commands import *
import subprocess

class movetotrash(Command):
    """:movetotrash

    Moves the selection or the current file to the XDG trash.
    """

    def execute(self):
        import os
        import datetime
        import shutil
        from time import strftime
        if self.rest(1):
            self.fm.notify("Error: movetotrash takes no arguments! It "
                           "operates on the selected file(s).", bad=True)
            return

        try:
            trash_dir = os.path.join(os.environ["XDG_DATA_HOME"], "Trash")
        except:
            trash_dir = os.path.join(os.environ["HOME"], ".local", "share",
                                     "Trash")

        selected = self.fm.thistab.get_selection()
        self.fm.copy_buffer -= set(selected)
        if selected:
            for f in selected:
                dest = os.path.join(trash_dir, "files", f.basename)
                basename = f.basename
                if os.path.exists(dest):
                    counter = 2
                    while os.path.exists(dest + "." + str(counter)):
                        counter += 1
                    basename += "." + str(counter)
                with open(os.path.join(trash_dir, "info",
                                       basename + ".trashinfo"), "w") as info:
                    info.write(
                        "[Trash Info]\n" +
                        "Path=" + f.path + "\n" +
                        "DeletionDate=" + strftime("%Y-%m-%dT%H:%M:%S") + "\n"
                    )
                shutil.move(f.path, os.path.join(trash_dir, "files", basename))
        self.fm.thistab.ensure_correct_pointer()

class fzfjump(Command):
    """:fzfjump

    Use fzf to quickly jump to recent dirs
    """
    def execute(self):
        with open("/home/user/jan/.var/lib/zsh/recent-dirs") as f:
            try:
                directory = subprocess.check_output(["fzf", "-e", "-s", "+m"], stdin=f).strip()
                self.fm.cd(directory)
            except:
                pass
            self.fm.ui.redraw_window()
