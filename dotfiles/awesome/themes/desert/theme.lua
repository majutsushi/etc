local awful = require("awful")

-- {{{ Main
local theme = {}
theme.confdir = awful.util.getdir("config") .. "/themes/desert"
theme.wallpaper = theme.confdir .. "/background.png"
-- }}}

-- {{{ Styles
theme.font = "sans 8"

-- {{{ Colors
theme.fg_normal  = "#FFFFFF"
theme.bg_normal  = "#333333"
theme.fg_focus   = "#FFFFFF"
theme.bg_focus   = "#1E2320"
theme.fg_urgent  = "#FF0000"
theme.bg_urgent  = "#333333"
theme.bg_systray = theme.bg_normal
-- }}}

-- {{{ Borders
theme.border_width  = 0
theme.border_normal = theme.bg_normal
theme.border_focus  = "#6B8E23"
-- }}}

theme.useless_gap = 7
theme.gap_single_client = false
-- theme.master_fill_policy = "master_width_factor"

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#3F3F3F"
theme.titlebar_bg_normal = "#3F3F3F"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
theme.taglist_fg_focus = "#2E3436"
theme.taglist_bg_focus = "#D3D7CF"
theme.taglist_fg_empty = "#777777"

theme.notification_font = "sans 10"
theme.notification_max_width = 700
theme.notification_icon_size = 128

theme.tooltip_bg = theme.bg_normal
theme.tooltip_title_color = "#f0e68c"
theme.tooltip_key_color = "#98fb98"
theme.tooltip_border_width = 0
theme.tooltip_border_color = "#777777"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
theme.fg_widget = theme.fg_normal
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
theme.bg_widget = "#4D4D4D"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = theme.fg_urgent
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = 16
theme.menu_width  = 150
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = theme.confdir .. "/icons/taglist/squarefz.png"
theme.taglist_squares_unsel = theme.confdir .. "/icons/taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

theme.widget_sep = theme.confdir .. "/icons/widgets/separator.png"
theme.widget_vol = theme.confdir .. "/icons/widgets/volume.png"
theme.widget_bat = theme.confdir .. "/icons/widgets/battery.png"
theme.widget_cpu = theme.confdir .. "/icons/widgets/cpu.png"
theme.widget_mem = theme.confdir .. "/icons/widgets/memory.png"
theme.widget_inhibit = theme.confdir .. "/icons/widgets/inhibit.png"
theme.widget_inhibit_active = theme.confdir .. "/icons/widgets/inhibit_active.png"
theme.widget_rhino = theme.confdir .. "/icons/widgets/rhino.png"
theme.widget_rhino_active = theme.confdir .. "/icons/widgets/rhino_active.png"
theme.widget_docker = theme.confdir .. "/icons/widgets/docker.png"
theme.widget_docker_active = theme.confdir .. "/icons/widgets/docker_active.png"
theme.widget_notifhist = theme.confdir .. "/icons/widgets/notifhist.png"

-- {{{ Misc
theme.icon_theme        = "Faenza-Darkest"
theme.awesome_icon      = theme.confdir .. "/icons/awesome-icon.png"
theme.menu_submenu_icon = theme.confdir .. "/icons/submenu.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = theme.confdir .. "/icons/layouts/tile.png"
theme.layout_tileleft   = theme.confdir .. "/icons/layouts/tileleft.png"
theme.layout_tilebottom = theme.confdir .. "/icons/layouts/tilebottom.png"
theme.layout_tiletop    = "/usr/share/awesome/themes/zenburn/layouts/tiletop.png"
theme.layout_fairv      = theme.confdir .. "/icons/layouts/fairv.png"
theme.layout_fairh      = theme.confdir .. "/icons/layouts/fairh.png"
theme.layout_spiral     = "/usr/share/awesome/themes/zenburn/layouts/spiral.png"
theme.layout_dwindle    = theme.confdir .. "/icons/layouts/dwindle.png"
theme.layout_max        = theme.confdir .. "/icons/layouts/max.png"
theme.layout_fullscreen = "/usr/share/awesome/themes/zenburn/layouts/fullscreen.png"
theme.layout_magnifier  = theme.confdir .. "/icons/layouts/magnifier.png"
theme.layout_cornernw   = theme.confdir .. "/icons/layouts/cornernw.png"
theme.layout_cornerne   = "/usr/share/awesome/themes/zenburn/layouts/cornerne.png"
theme.layout_cornersw   = "/usr/share/awesome/themes/zenburn/layouts/cornersw.png"
theme.layout_cornerse   = "/usr/share/awesome/themes/zenburn/layouts/cornerse.png"
theme.layout_floating   = theme.confdir .. "/icons/layouts/floating.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = "/usr/share/awesome/themes/zenburn/titlebar/close_focus.png"
theme.titlebar_close_button_normal = "/usr/share/awesome/themes/zenburn/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active    = "/usr/share/awesome/themes/zenburn/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active   = "/usr/share/awesome/themes/zenburn/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = "/usr/share/awesome/themes/zenburn/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = "/usr/share/awesome/themes/zenburn/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active    = "/usr/share/awesome/themes/zenburn/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active   = "/usr/share/awesome/themes/zenburn/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = "/usr/share/awesome/themes/zenburn/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = "/usr/share/awesome/themes/zenburn/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active    = "/usr/share/awesome/themes/zenburn/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active   = "/usr/share/awesome/themes/zenburn/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = "/usr/share/awesome/themes/zenburn/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = "/usr/share/awesome/themes/zenburn/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active    = "/usr/share/awesome/themes/zenburn/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = "/usr/share/awesome/themes/zenburn/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = "/usr/share/awesome/themes/zenburn/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = "/usr/share/awesome/themes/zenburn/titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}

return theme
