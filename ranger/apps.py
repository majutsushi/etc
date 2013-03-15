# -*- coding: utf-8 -*-
# Copyright (C) 2009, 2010, 2011  Roman Zimbelmann <romanz@lavabit.com>
# This configuration file is licensed under the same terms as ranger.
# ===================================================================
# This is the configuration file for file type detection and application
# handling.  It's all in python; lines beginning with # are comments.
#
# You can customize this in the file ~/.config/ranger/apps.py.
# It has the same syntax as this file.  In fact, you can just copy this
# file there with `ranger --copy-config=apps' and make your modifications.
# But make sure you update your configs when you update ranger.
#
# In order to add application definitions "on top of" the default ones
# in your ~/.config/ranger/apps.py, you should subclass the class defined
# here like this:
#
#   from ranger.defaults.apps import CustomApplications as DefaultApps
#   class CustomApplications(DeafultApps):
#       <your definitions here>
#
# To override app_defaults, you can write something like:
#
#       def app_defaults(self, c):
#           f = c.file
#           if f.extension == 'lol':
#               return "lolopener", c
#           return DefaultApps.app_default(self, c)
#
# ===================================================================
# This system is based on things called MODES and FLAGS.  You can read
# in the man page about them.  To remind you, here's a list of all flags.
# An uppercase flag inverts previous flags of the same name.
#     s   Silent mode.  Output will be discarded.
#     d   Detach the process.  (Run in background)
#     p   Redirect output to the pager
#     w   Wait for an Enter-press when the process is done
#     c   Run the current file only, instead of the selection
#     r   Run application with root privilege
#     t   Run application in a new terminal window
#
# To implement flags in this file, you could do this:
#     context.flags += "d"
# Another example:
#     context.flags += "Dw"
#
# To implement modes in this file, you can do something like:
#     if context.mode == 1:
#         <run in one way>
#     elif context.mode == 2:
#         <run in another way>
#
# ===================================================================
# The methods are called with a "context" object which provides some
# attributes that transfer information.  Relevant attributes are:
#
# mode -- a number, mainly used in determining the action in app_xyz()
# flags -- a string with flags which change the way programs are run
# files -- a list containing files, mainly used in app_xyz
# filepaths -- a list of the paths of each file
# file -- an arbitrary file from that list (or None)
# fm -- the filemanager instance
# popen_kws -- keyword arguments which are directly passed to Popen
#
# ===================================================================
# The return value of the functions should be either:
# 1. A reference to another app, like:
#     return self.app_editor(context)
#
# 2. A call to the "either" method, which uses the first program that
# is installed on your system.  If none are installed, None is returned.
#     return self.either(context, "libreoffice", "soffice", "ooffice")
#
# 3. A tuple of arguments that should be run.
#     return "mplayer", "-fs", context.file.path
# If you use lists instead of strings, they will be flattened:
#     args = ["-fs", "-shuf"]
#     return "mplayer", args, context.filepaths
# "context.filepaths" can, and will often be abbreviated with just "context":
#     return "mplayer", context
#
# 4. "None" to indicate that no action was found.
#     return None
#
# ===================================================================
# When using the "either" method, ranger determines which program to
# pick by looking at its dependencies.  You can set dependencies by
# adding the decorator "depends_on":
#     @depends_on("vim")
#     def app_vim(self, context):
#         ....
# There is a special keyword which you can use as a dependence: "X"
# This ensures that the program will only run when X is running.
# ===================================================================

import ranger
from ranger.api.apps import *
from ranger.ext.get_executables import get_executables
from ranger.defaults.apps import CustomApplications as DefaultApps

class CustomApplications(DefaultApps):
    def app_default(self, c):
        f = c.file

        if f.extension == 'jar':
            handler = self.either(c, 'deepjarlist')
            # Only return if the program was found
            if handler:
                return handler

        return DefaultApps.app_default(self, c)

    @depends_on('deepjarlist')
    def app_deepjarlist(self, c):
        if c.mode is 0:
            c.flags += 'p'
            return 'deepjarlist', c.file.path
        return None
