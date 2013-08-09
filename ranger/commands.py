from ranger.api.commands import *

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
                with open(os.path.join(trash_dir, "info",
                                       f.basename + ".trashinfo"), "w") as info:
                    info.write(
                        "[Trash Info]\n" +
                        "Path=" + f.path + "\n" +
                        "DeletionDate=" + strftime("%Y-%m-%dT%H:%M:%S") + "\n"
                    )
                shutil.move(f.path, os.path.join(trash_dir, "files"))
        self.fm.thistab.ensure_correct_pointer()
