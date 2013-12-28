-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

local vicious = require("vicious")
vicious.contrib = require("vicious.contrib")

local eldritch = require("eldritch")

local pulse = require("pulse")
local scratch = require("scratch")
local cal = require("cal")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Override awesome.quit when we're using GNOME
_awesome_quit = awesome.quit
awesome.quit = function()
    if os.getenv("DESKTOP_SESSION") == "awesome-gnome" then
        os.execute("/usr/bin/gnome-session-quit")
    else
        _awesome_quit()
    end
end
--- }}}

-- {{{ Variable definitions
local home   = os.getenv("HOME")
local exec   = awful.util.spawn
local sexec  = awful.util.spawn_with_shell
local scount = screen.count()
local osinfo = vicious.widgets.os()

-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/desert/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local altkey = "Mod1"
local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile,            -- 1
    awful.layout.suit.tile.bottom,     -- 2
    awful.layout.suit.fair,            -- 3
    awful.layout.suit.fair.horizontal, -- 4
    awful.layout.suit.max,             -- 5
    awful.layout.suit.magnifier,       -- 6
    awful.layout.suit.floating         -- 7
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}
-- {{{ Tags
tags = {
    names  = { "web", 2, 3, 4, 5, 6, 7, 8, 9, 10, "mail", "im" },
    layout = { layouts[5], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1],
               layouts[1], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1]
}}

for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)

    if s == 1 then
        -- Configure 'mail' tag (10)
        awful.tag.setncol(2, tags[s][11])
        awful.tag.setnmaster(1, tags[s][11])
        awful.tag.setproperty(tags[s][11], "mwfact", 0.65)

        -- Configure 'im' tag (12)
        awful.tag.setncol(3, tags[s][12])
        awful.tag.setnmaster(1, tags[s][12])
        awful.tag.setproperty(tags[s][12], "mwfact", 0.55)

        -- for i, t in ipairs(tags[s]) do
            -- awful.tag.setproperty(t, "mwfact", i == 9 and 0.13  or  0.5)
            -- awful.tag.setproperty(t, "hide",  (i==6 or  i==7) and true)
        -- end
    end
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
awful.menu.menu_keys = {
    up =    { "Up", "k" },
    down =  { "Down", "j" },
    back =  { "Left", "h" },
    enter = { "Right", "l" },
    exec =  { "Return" },
    close = { "Escape", "q" }
}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- applications menu
require('freedesktop.utils')
freedesktop.utils.terminal = terminal
freedesktop.utils.icon_theme = { 'Faenza-Darkest', 'Faenza-Dark', 'gnome' }
require('freedesktop.menu')
require("debian.menu")

menu_items = freedesktop.menu.new()
myawesomemenu = {
    { "manual", terminal .. " -e man awesome",
      freedesktop.utils.lookup_icon({ icon = 'help' }) },
    { "edit config", editor_cmd .. " " .. awesome.conffile,
      freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
    { "restart", awesome.restart,
      freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) },
    { "quit", awesome.quit,
      freedesktop.utils.lookup_icon({ icon = 'gtk-quit' }) }
}
table.insert(menu_items, { "awesome", myawesomemenu,
                           beautiful.awesome_icon })
table.insert(menu_items, { "Debian", debian.menu.Debian_menu.Debian,
                           freedesktop.utils.lookup_icon({ icon = 'debian-logo' }) })
table.insert(menu_items, { "open terminal", terminal,
                           freedesktop.utils.lookup_icon({icon = 'terminal'}) })

mymainmenu = awful.menu.new({ items = menu_items, width = 150 })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
separator = wibox.widget.imagebox(beautiful.widget_sep)

-- Create a textclock widget
mytextclock = awful.widget.textclock('<span font_size="smaller" fgcolor="#999999">%a %d %b</span> %H:%M')

cal.register(mytextclock, '<b>%s</b>')

-- {{{ Rhino
if osinfo[4] == "vanadis" then
    rhinoicon = wibox.widget.imagebox(beautiful.widget_rhino)
    rhinoicon.tooltip = awful.tooltip({ objects = { rhinoicon } })
    vicious.register(rhinoicon, eldritch.widgets.rhino, function(widget, args)
        if #args == 0 then
            rhinoicon:set_image(beautiful.widget_rhino)
        else
            rhinoicon:set_image(beautiful.widget_rhino_active)
        end
        rhinoicon.tooltip:set_text(table.concat(args, "\n"))
        return ""
    end, 31)
end
-- }}}

-- {{{ CPU
local function getnprocs()
    local f = io.popen("grep -c processor /proc/cpuinfo")
    local nprocs = f:read("*all")
    f:close()
    return nprocs
end
nprocs = getnprocs()
local function getcpucolours()
    local colours = { "#ffffff" }
    local step = math.floor(0xff / nprocs)

    for i = nprocs - 2, 1, -1 do
        local curval = step * i
        local newcolour = string.format("#%x%x%x", curval, curval, curval)
        colours[#colours + 1] = newcolour
    end

    colours[#colours + 1] = "#000000"

    return colours
end
local function getcpukeys()
    local keys = { "Total" }

    for i = 1, nprocs do
        table.insert(keys, "CPU " .. i)
    end

    return keys
end
cpuicon = wibox.widget.imagebox(beautiful.widget_cpu)
cputext = wibox.widget.textbox()
cpuwidget = awful.widget.graph()
cpuwidget:set_width(50)
cpuwidget:set_stack(true)
cpuwidget:set_max_value(100)
cpuwidget:set_background_color(beautiful.bg_widget)
cpuwidget:set_stack_colors(getcpucolours())
cpuwidgetm = wibox.layout.mirror(cpuwidget, { vertical = true })
cpuwidget.tooltip = eldritch.tooltip("CPU", getcpukeys(), { cpuwidget, cpuwidgetm, cpuicon })
cpumargin = wibox.layout.margin(cpuwidgetm, 0, 0, 1, 1)
vicious.register(cputext, vicious.widgets.cpu, function(widget, args)
    local values = { args[1] .. "%" }
    for i = 2, #args do
        table.insert(values, args[i] .. "%")
        cpuwidget:add_value(args[i], i - 1)
    end
    cpuwidget.tooltip:update(values)
    return args[1]
end)
--- }}}

-- {{{ Memory
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = awful.widget.progressbar()
memwidget:set_width(8)
memwidget:set_height(10)
memwidget:set_vertical(true)
memwidget:set_background_color(beautiful.bg_widget)
memwidget:set_border_color(nil)
memwidget:set_color(beautiful.fg_widget)
memwidget.tooltip = eldritch.tooltip("Memory",
                                     { "Memory", "Swap" },
                                     { memwidget, memicon })
memmargin = wibox.layout.margin(memwidget, 0, 0, 1, 1)
vicious.register(memwidget, vicious.widgets.mem, function(widget, args)
    widget.tooltip:update({
        string.format("%d / %d MB", args[2], args[3]),
        string.format("%d / %d MB", args[6], args[7])
    })
    return args[1]
end, 13)
--- }}}

-- {{{ Battery
baticon = wibox.widget.imagebox(beautiful.widget_bat)
batwidget = wibox.widget.textbox()
batwidget.tooltip = eldritch.tooltip("Battery charge",
                                     { "State", "Charge", "Time left" },
                                     { batwidget, baticon })
vicious.register(batwidget, vicious.widgets.bat, function(widget, args)
    local text = ""
    if args[1] == "-" then
        text = text .. '<span fgcolor="#D75F5F">↓</span>'
    elseif args[1] == "+" then
        text = text .. '<span fgcolor="#87FF87">↑</span>'
    else
        text = args[1]
    end
    if args[1] == "-" or args[1] == "+" then
        if args[2] < 20 then
            text = text .. string.format('<span fgcolor="#D75F5F">%d</span>%%', args[2])
        elseif args[2] < 50 then
            text = text .. string.format('<span fgcolor="#FFD700">%d</span>%%', args[2])
        else
            text = text .. string.format('<span fgcolor="#87FF87">%d</span>%%', args[2])
        end
    end
    widget.tooltip:update({ args[1], args[2] .. "%", args[3] })
    return text
end, 61, "BAT0")
--- }}}

-- {{{ Pulseaudio volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volbar = pulse.widget(volicon)
volbuttons = awful.util.table.join(
    awful.button({ }, 1, function() pulse.pulse.toggle() vicious.force({volbar}) end),
    awful.button({ }, 3, function() awful.util.spawn("pavucontrol") end),
    awful.button({ }, 4, function() pulse.pulse.add( 5) vicious.force({volbar}) end),
    awful.button({ }, 5, function() pulse.pulse.add(-5) vicious.force({volbar}) end)
)
volicon:buttons(volbuttons)
volbar:buttons(volbuttons)
volmargin = wibox.layout.margin(volbar, 0, 0, 1, 1)
vicious.register(volbar, pulse.pulse, function(widget, args)
    return widget:update(args)
end, 5)
--- }}}

-- {{{ Weather
weathericon = wibox.widget.imagebox(beautiful.weather_dir .. "01d.png")
weatherwidget = wibox.widget.textbox()
weatherwidget.tooltip = eldritch.tooltip(
    "Weather",
    {"City", "Updated", "Sky", "Temperature", "Humidity", "Wind", "Sunrise", "Sunset"},
    { weatherwidget, weathericon }
)
vicious.register(weatherwidget, eldritch.widgets.weather, function(widget, args)
    widget.tooltip:update({
        args.city,
        args.updated,
        args.sky,
        string.format("%s °C", args.temp),
        args.humid .. "%",
        string.format("%s, %s km/h", args.wind.aim, args.wind.kmh),
        string.format(os.date('%H:%M', args.sunrise)),
        string.format(os.date('%H:%M', args.sunset))
    })
    if args.icon then
        weathericon:set_image(beautiful.weather_dir .. args.icon .. ".png")
    end
    return math.floor(args.temp + 0.5) .. "°C"
end, 60, "2179537")
-- }}}

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(
        awful.util.table.join(
            awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
            awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
            awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
            awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mylayoutbox[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(separator)
    if osinfo[4] == "vanadis" then
        right_layout:add(rhinoicon)
    end
    right_layout:add(baticon)
    right_layout:add(batwidget)
    right_layout:add(cpuicon)
    right_layout:add(cpumargin)
    right_layout:add(memicon)
    right_layout:add(memmargin)
    right_layout:add(volicon)
    right_layout:add(volmargin)
    right_layout:add(weathericon)
    right_layout:add(weatherwidget)
    right_layout:add(separator)
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey }, "Escape", awful.tag.history.restore),

    awful.key({ modkey }, "s",
              function () scratch.drop("urxvt", "top", "left", 600, 600) end),
    awful.key({ modkey }, "d",
              function () scratch.pad.toggle() end),

    awful.key({ modkey }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "w", function ()
        mymainmenu:show({ coords = { x = 0, y = 0 } })
    end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j",
              function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k",
              function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j",
              function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k",
              function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Move and resize floating clients with the keyboard
    awful.key({ modkey }, "Next",
              function () awful.client.moveresize( 20,  20, -40, -40) end),
    awful.key({ modkey }, "Prior",
              function () awful.client.moveresize(-20, -20,  40,  40) end),
    awful.key({ modkey }, "Down",
              function () awful.client.moveresize(  0,  20,   0,   0) end),
    awful.key({ modkey }, "Up",
              function () awful.client.moveresize(  0, -20,   0,   0) end),
    awful.key({ modkey }, "Left",
              function () awful.client.moveresize(-20,   0,   0,   0) end),
    awful.key({ modkey }, "Right",
              function () awful.client.moveresize( 20,   0,   0,   0) end),

    -- Standard functionality
    awful.key({ modkey, "Control" }, "Return", function () exec(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey }, "l",     function () awful.tag.incmwfact( 0.05) end),
    awful.key({ modkey }, "h",     function () awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, "Shift" }, "h", function () awful.tag.incnmaster( 1) end),
    awful.key({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1) end),
    awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1) end),
    awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1) end),
    awful.key({ modkey }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Multimedia keys
    awful.key({}, "XF86AudioRaiseVolume", function()
        pulse.pulse.add( 5)
        vicious.force({volbar})
        volbar:notify()
    end),
    awful.key({}, "XF86AudioLowerVolume", function()
        pulse.pulse.add(-5)
        vicious.force({volbar})
        volbar:notify()
    end),
    awful.key({}, "XF86AudioMute", function()
        pulse.pulse.toggle()
        vicious.force({volbar})
        volbar:notify()
    end),

    awful.key({}, "XF86MonBrightnessUp", function () eldritch.utils.brightness(4) end),
    awful.key({}, "XF86MonBrightnessDown", function () eldritch.utils.brightness(-4) end),

    awful.key({ altkey, "Control" }, "l", function () exec("gnome-screensaver-command --lock") end),
    awful.key({ }, "Print", function () exec("gnome-screenshot --interactive") end),

    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey, "Control" }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f", function (c) c.fullscreen = not c.fullscreen end),
    awful.key({ modkey, "Shift"   }, "c", function (c) c:kill() end),
    awful.key({ modkey, "Control" }, "d", function (c) scratch.pad.set(c, 0.60, 0.60, true) end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey,           }, "Return",
        function (c)
            c:swap(awful.client.getmaster())
            client.focus = c
            c:raise()
        end),
    awful.key({ modkey }, "m",
        function ()
            local m = awful.client.getmaster()
            client.focus = m
            m:raise()
        end),
    awful.key({ modkey }, "o", awful.client.movetoscreen),
    awful.key({ modkey }, "t", function (c) c.ontop = not c.ontop end),
    awful.key({ modkey }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
            c:raise()
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
local function viewonly(i)
    local screen = mouse.screen
    local tag = awful.tag.gettags(screen)[i]
    if tag then
        awful.tag.viewonly(tag)
    end
end
local function viewtoggle(i)
    local screen = mouse.screen
    local tag = awful.tag.gettags(screen)[i]
    if tag then
        awful.tag.viewtoggle(tag)
    end
end
local function movetotag(i)
    local tag = awful.tag.gettags(client.focus.screen)[i]
    if client.focus and tag then
        awful.client.movetotag(tag)
    end
end
local function toggletag(i)
    local tag = awful.tag.gettags(client.focus.screen)[i]
    if client.focus and tag then
        awful.client.toggletag(tag)
    end
end

for i = 1, 12 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9, function() viewonly(i) end),
        awful.key({ modkey, "Control" }, "#" .. i + 9, function() viewtoggle(i) end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function() movetotag(i) end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function() toggletag(i) end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     maximized_vertical = false,
                     maximized_horizontal = false,
                     size_hints_honor = false,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Plugin-container" },
      properties = { floating = true } },
    { rule = { class = "mt32emu" },
      properties = { floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    -- Fine grained borders and floaters control
    if #clients > 0 then
        for _, c in pairs(clients) do
            if c.fullscreen or c.name == "plugin-container" then
                c.border_width = 0
            elseif awful.client.floating.get(c) or layout == "floating" then
                c.border_width = beautiful.border_width
            elseif #clients == 1 or layout == "max" or
                #clients == 2 and
                    (awful.client.floating.get(clients[1]) or
                     awful.client.floating.get(clients[2])) then
                c.border_width = 0
            else
                c.border_width = beautiful.border_width
            end
        end
    end
end)
end
-- }}}

-- vim: foldenable foldmethod=marker
