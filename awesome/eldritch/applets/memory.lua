local beautiful = require("beautiful")
local tooltip = require("eldritch.tooltip")
local vicious = require("vicious")
local wibox = require("wibox")

local memwidget = {}

local function new()
    local bar = wibox.widget {
        background_color = beautiful.bg_widget,
        border_color     = nil,
        color            = beautiful.fg_widget,
        widget           = wibox.widget.progressbar,
    }

    local widget = wibox.widget {
        {
            wibox.widget.imagebox(beautiful.widget_mem),
            {
                {
                    bar,
                    forced_width = 8,
                    direction    = 'east',
                    widget       = wibox.container.rotate,
                },
                top    = 1,
                bottom = 1,
                widget = wibox.container.margin,
            },
            layout = wibox.layout.fixed.horizontal,
        },
        right  = 7,
        widget = wibox.container.margin
    }

    bar.tooltip = tooltip("Memory",
                          { "Memory", "Swap" },
                          { widget })

    vicious.register(bar, vicious.widgets.mem, function(widget, args)
        widget.tooltip:update({
            string.format("%d / %d MB", args[2], args[3]),
            string.format("%d / %d MB", args[6], args[7])
        })
        return args[1]
    end, 13)

    return widget
end

return setmetatable(memwidget, { __call = function(_, ...) return new(...) end })
