-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local icon_theme = require("menubar.icon_theme")()

local vicious = require("vicious")
local eldritch = require("eldritch")
local pulse = require("pulse")
local scratch = require("scratch")

local xrandr = require("xrandr")

-- Load Debian menu entries
require("debian.menu")

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
                         title = "Error",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.get_configuration_dir() .. "themes/desert/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
altkey = "Mod1"
modkey = "Mod4"

local osinfo = vicious.widgets.os()

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
    -- awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.floating,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
awful.menu.menu_keys = {
    up =    { "Up", "k" },
    down =  { "Down", "j" },
    back =  { "Left", "h" },
    enter = { "Right", "l" },
    exec =  { "Return" },
    close = { "Escape", "q" }
}

myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end }
}

mymainmenu = eldritch.xdg_menu.build({
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
    },
    after = {
        { "Debian", debian.menu.Debian_menu.Debian, icon_theme:find_icon_path("emblem-debian") },
        { "Open terminal", terminal, icon_theme:find_icon_path("utilities-terminal") },
    },
    width = 150
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock('<span font_size="smaller" fgcolor="#999999">%a %d %b</span> %H:%M', 1)
eldritch.applets.cal.register(mytextclock)

-- {{{ Pulseaudio volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volbar = pulse.widget(volicon)
-- volbuttons = awful.util.table.join(
--     awful.button({ }, 1, function() pulse.pulse.toggle() vicious.force({volbar}) end),
--     awful.button({ }, 3, function() awful.util.spawn("pavucontrol") end),
--     awful.button({ }, 4, function() pulse.pulse.add( 5) vicious.force({volbar}) end),
--     awful.button({ }, 5, function() pulse.pulse.add(-5) vicious.force({volbar}) end)
-- )
-- volicon:buttons(volbuttons)
-- volbar:buttons(volbuttons)
-- volmargin = wibox.container.margin(volbar, 0, 0, 1, 1)
vicious.register(volbar, pulse.pulse, function(widget, args)
    return widget:update(args)
end, 5)
--- }}}

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local applets = {
    rhino   = osinfo[4] == "vanadis" and eldritch.applets.rhino(),
    battery = eldritch.applets.battery(),
    cpu     = eldritch.applets.cpu(),
    memory  = eldritch.applets.memory(),
    -- weather = eldritch.applets.weather(),
    -- Keyboard map indicator and switcher
    -- keyboardlayout = awful.widget.keyboardlayout()
}

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons, {}, eldritch.utils.tasklist_update)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", height = 22, screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mylayoutbox,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            applets.rhino,
            applets.battery,
            applets.cpu,
            applets.memory,
            -- volicon,
            -- volmargin,
            -- applets.weather,
            -- applets.keyboardlayout,
            wibox.widget.systray(),
            mytextclock,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey }, "s",
              function () scratch.uniqdrop("urxvt", "top", "left", 600, 600) end,
              {description="toggle scratch terminal", group="awesome"}),
    awful.key({ modkey }, "d", function () scratch.pad.toggle() end,
              {description="toggle scratch client", group="awesome"}),
    awful.key({ modkey, "Shift"   }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey, "Control" }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Control" }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Multimedia keys
    awful.key({}, "XF86AudioPlay", function() eldritch.mpris.send_cmd("PlayPause") end,
              {description="toggle play/pause", group="audio"}),
    awful.key({}, "XF86AudioNext", function() eldritch.mpris.send_cmd("Next") end,
               {description="next", group="audio"}),
    awful.key({}, "XF86AudioPrev", function() eldritch.mpris.send_cmd("Previous") end,
               {description="previous", group="audio"}),
    awful.key({}, "XF86AudioRaiseVolume", function()
        pulse.pulse.add( 5)
        vicious.force({volbar})
        volbar:notify()
    end, {description="raise volume", group="audio"}),
    awful.key({}, "XF86AudioLowerVolume", function()
        pulse.pulse.add(-5)
        vicious.force({volbar})
        volbar:notify()
    end, {description="lower volume", group="audio"}),
    awful.key({}, "XF86AudioMute", function()
        pulse.pulse.toggle()
        vicious.force({volbar})
        volbar:notify()
    end, {description="mute", group="audio"}),

    awful.key({}, "XF86Display", function() xrandr.xrandr() end,
              {description="switch between display configs", group="misc"}),

    awful.key({}, "XF86MonBrightnessUp", function () eldritch.utils.brightness(4) end,
              {description="increase brightness", group="misc"}),
    awful.key({}, "XF86MonBrightnessDown", function () eldritch.utils.brightness(-4) end,
              {description="decrease brightness", group="misc"}),

    awful.key({}, "XF86ScreenSaver", function () awful.spawn("slock") end,
              {description="lock screen", group="misc"}),
    awful.key({ altkey, "Control" }, "l", function () awful.spawn("slock") end,
              {description="lock screen", group="misc"}),
    awful.key({ },           "Print", function () awful.spawn("gnome-screenshot") end,
              {description="take screenshot", group="misc"}),
    awful.key({ "Control" }, "Print", function () awful.spawn("gnome-screenshot --interactive") end,
              {description="take screenshot interactive", group="misc"}),

    -- Prompt
    awful.key({ modkey }, "p", function () awful.spawn("rofi -show drun") end,
              {description = "run rofi", group = "launcher"}),
    -- awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
    --           {description = "run prompt", group = "launcher"}),
    awful.key({ modkey }, "r", function () awful.spawn("urxvt -name zshrun -geometry 100x10 -e env ZSHRUN=1 zsh") end,
              {description = "zshrun", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey, "Control" }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Control" }, "f",      function (c) eldritch.utils.fullscreens(c)    end,
              {description="toggle fullscreen all screens", group = "client"}),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "d",      function (c) scratch.pad.set(c, 0.60, 0.60, true) end,
              {description = "set client as scratchpad", group = "client"}),
    awful.key({ modkey,           }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey }, "m",
        function ()
            local m = awful.client.getmaster()
            client.focus = m
            m:raise()
        end, {description = "focus master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey            }, "a",      function (c) c.sticky = not c.sticky          end,
              {description = "toggle sticky", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 12 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer",
          "MPlayer",
          "fs-uae",
          "Minecraft.*"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },

    { rule = { class = "URxvt" },
      properties = { size_hints_honor = false } },

    { rule = { class = "URxvt", instance = "zshrun" },
      properties = { floating = true },
      callback = function (c)
          awful.placement.centered(c, nil)
      end
    },

    { rule = { class = "[pP]lugin%-container" },
      properties = { floating = true },
      callback = function (c)
          c.fullscreen = true
      end
    },

    { rule = { class = "jetbrains.*" },
      except = { type = "dialog" },
      properties = { floating = false }
    },

    -- { rule = { class = "Steam" },
    --   properties = { border_width = 0 } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
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

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    -- If the currently focused client is the IDEA input popup,
    -- don't change focus if the mouse moves over a different client
    -- due to the popup changing size
    local f = client.focus
    if f then
        if f.class and f.class:match("^jetbrains.*") and f.type == "dialog" then
            return
        end
    end

    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("request::urgent", function(c)
    if client.focus ~= c then
        c.border_color = beautiful.fg_urgent
    end
end)

-- Java hack from https://awesome.naquadah.org/bugs/index.php?do=details&task_id=733
client.connect_signal("focus", function(c)
    if c.class and c.class:match("^jetbrains.*") then
        c:raise()
    end
end)

client.connect_signal("property::geometry", function (c)
    local clients = awful.client.visible(c.screen)
    local layout = awful.layout.getname(awful.layout.get(c.screen))

    local should_apply_shape = true

    if c.fullscreen or c.maximized or #clients == 1 or layout == "max" then
        should_apply_shape = false
    end

    if should_apply_shape then
        c.shape = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 5)
        end
    else
        c.shape = nil
    end
end)
-- }}}

-- {{{ Arrange signal handler
awful.screen.connect_for_each_screen(function(s)
    s:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout = awful.layout.getname(awful.layout.get(s))

        -- Fine grained borders and floaters control
        if #clients > 0 then
            for _, c in pairs(clients) do
                -- if c.fullscreen or c.name == "Steam" or
                if c.fullscreen or
                        (c.name ~= nil and c.name:match("[pP]lugin%-container")) then
                    c.border_width = 0
                elseif c.floating or layout == "floating" then
                    c.border_width = beautiful.border_width
                elseif #clients == 1 or layout == "max" or
                    #clients == 2 and (clients[1].floating or clients[2].floating) then
                    c.border_width = 0
                else
                    c.border_width = beautiful.border_width
                end
            end
        end
    end)
end)
-- }}}

-- Temporary until https://github.com/awesomeWM/awesome/pull/1914 is available
awful.tag.object.get_gap = function(t)
    t = t or awful.screen.focused().selected_tag
    if t.layout.name == "max" then
        return 0
    end
    return awful.tag.getproperty(t, "useless_gap") or beautiful.useless_gap or 0
end

-- vim: foldenable foldmethod=marker
