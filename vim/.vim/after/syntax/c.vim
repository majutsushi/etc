" Put it to ~/.vim/after/syntax/ (or in /var/lib/vim/addons/after/syntax/)
" and tailor to your needs.

let clutter_deprecated_errors = 1
let gconf_deprecated_errors = 1
let gdk_deprecated_errors = 1
let gdkpixbuf_deprecated_errors = 1
let gimp_deprecated_errors = 1
let gio_deprecated_errors = 1
let glib_deprecated_errors = 1
let gnomedesktop_deprecated_errors = 1
let gobject_deprecated_errors = 1
let gtk_deprecated_errors = 1
let libglade_deprecated_errors = 1
let libgnome_deprecated_errors = 1
let libgnomeui_deprecated_errors = 1
let librsvg_deprecated_errors = 1
let libwnck_deprecated_errors = 1
let pango_deprecated_errors = 1
let vte_deprecated_errors = 1

if version < 600
  so <sfile>:p:h/atk.vim
  so <sfile>:p:h/atspi.vim
  so <sfile>:p:h/cairo.vim
  so <sfile>:p:h/clutter.vim
  so <sfile>:p:h/dbusglib.vim
  so <sfile>:p:h/evince.vim
  so <sfile>:p:h/gail.vim
  so <sfile>:p:h/gconf.vim
  so <sfile>:p:h/gdkpixbuf.vim
  so <sfile>:p:h/gdk.vim
  so <sfile>:p:h/gimp.vim
  so <sfile>:p:h/gio.vim
  so <sfile>:p:h/glib.vim
  so <sfile>:p:h/gnomedesktop.vim
  so <sfile>:p:h/gnomevfs.vim
  so <sfile>:p:h/gobject.vim
  so <sfile>:p:h/goocanvas.vim
  so <sfile>:p:h/gtkglext.vim
  so <sfile>:p:h/gtksourceview.vim
  so <sfile>:p:h/gtk.vim
  so <sfile>:p:h/libglade.vim
  so <sfile>:p:h/libgnomecanvas.vim
  so <sfile>:p:h/libgnomeui.vim
  so <sfile>:p:h/libgnome.vim
  so <sfile>:p:h/libgsf.vim
  so <sfile>:p:h/libnotify.vim
  so <sfile>:p:h/liboil.vim
  so <sfile>:p:h/librsvg.vim
  so <sfile>:p:h/libwnck.vim
  so <sfile>:p:h/orbit2.vim
  so <sfile>:p:h/pango.vim
  so <sfile>:p:h/poppler.vim
  so <sfile>:p:h/vte.vim
  so <sfile>:p:h/xlib.vim
else
  runtime! syntax/atk.vim
  runtime! syntax/atspi.vim
  runtime! syntax/cairo.vim
  runtime! syntax/clutter.vim
  runtime! syntax/dbusglib.vim
  runtime! syntax/evince.vim
  runtime! syntax/gail.vim
  runtime! syntax/gconf.vim
  runtime! syntax/gdkpixbuf.vim
  runtime! syntax/gdk.vim
  runtime! syntax/gimp.vim
  runtime! syntax/gio.vim
  runtime! syntax/glib.vim
  runtime! syntax/gnomedesktop.vim
  runtime! syntax/gnomevfs.vim
  runtime! syntax/gobject.vim
  runtime! syntax/goocanvas.vim
  runtime! syntax/gtkglext.vim
  runtime! syntax/gtksourceview.vim
  runtime! syntax/gtk.vim
  runtime! syntax/libglade.vim
  runtime! syntax/libgnomecanvas.vim
  runtime! syntax/libgnomeui.vim
  runtime! syntax/libgnome.vim
  runtime! syntax/libgsf.vim
  runtime! syntax/libnotify.vim
  runtime! syntax/liboil.vim
  runtime! syntax/librsvg.vim
  runtime! syntax/libwnck.vim
  runtime! syntax/orbit2.vim
  runtime! syntax/pango.vim
  runtime! syntax/poppler.vim
  runtime! syntax/vte.vim
  runtime! syntax/xlib.vim
endif

" vim: set ft=vim :
