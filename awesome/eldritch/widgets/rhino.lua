local awful = require("awful")
local beautiful = require("beautiful")
local vicious = require("vicious")
local wibox = require("wibox")
local workers = require("eldritch.workers")

local rhinowidget = {}

local function new()
    local icon = wibox.widget.imagebox(beautiful.widget_rhino)

    local widget = wibox.widget {
        icon,
        right  = 7,
        widget = wibox.container.margin
    }

    icon.tooltip = awful.tooltip({ objects = { widget } })

    vicious.register(icon, workers.rhino, function(widget, args)
        if #args == 0 then
            icon:set_image(beautiful.widget_rhino)
        else
            icon:set_image(beautiful.widget_rhino_active)
        end
        icon.tooltip:set_markup(table.concat(args, "\n"))
        return ""
    end, 31)

    return widget
end

return setmetatable(rhinowidget, { __call = function(_, ...) return new(...) end })
