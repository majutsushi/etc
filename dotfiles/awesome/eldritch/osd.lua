local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local osd = {}

local _osd = {}

local current = nil

function _osd:die()
    self.tmr:stop()
    naughty.destroy(self.notification)
    self.notification = nil
    current = nil
end

local function new(title)
    local o = setmetatable({}, { __index = _osd })

    local titlecolor = beautiful.tooltip_title_color or "#f0e68c"
    title = '<span font_weight="bold" fgcolor="' .. titlecolor .. '">' .. title .. '</span>'
    local titlebox = wibox.widget.textbox(title)
    local title_m = wibox.container.margin(titlebox, 5, 5, 5, 5)

    o.percent = wibox.widget.textbox()
    local percent_m = wibox.container.margin(o.percent, 5, 5, 5, 5)

    o.progress = wibox.widget {
        max_value        = 100,
        forced_width     = 150,
        color            = beautiful.fg_widget,
        background_color = beautiful.bg_widget,
        widget           = wibox.widget.progressbar
    }
    local progress_m = wibox.container.margin(o.progress, 5, 5, 5, 5)

    local layout_bottom = wibox.layout.fixed.horizontal()
    layout_bottom:add(progress_m)
    layout_bottom:add(percent_m)

    local layout = wibox.layout.align.vertical()
    layout:set_top(title_m)
    layout:set_bottom(layout_bottom)
    layout:buttons(awful.util.table.join(awful.button({}, 1, function() o:die() end)))

    o.tmr = gears.timer({ timeout = 2 })
    o.tmr:connect_signal("timeout", function() o:die() end)

    o.notification = naughty.notify({ height = 50, width = 205, timeout = 0 })
    o.notification.box:set_widget(layout)

    return o
end

function osd.notify(title, value)
    if not current then
        current = new(title)
    else
        current.tmr:stop()
    end

    current.percent:set_markup(value .. "%")
    current.progress:set_value(value)
    current.tmr:start()
end

return osd
