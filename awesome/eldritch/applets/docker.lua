local awful = require("awful")
local beautiful = require("beautiful")
local utils = require("eldritch.utils")
local vicious = require("vicious")
local wibox = require("wibox")
local workers = require("eldritch.workers")

local dockerwidget = {}

local function new()
    local icon = wibox.widget.imagebox(beautiful.widget_docker)

    local widget = wibox.widget {
        icon,
        right  = 7,
        widget = wibox.container.margin
    }

    icon.tooltip = awful.tooltip({ objects = { widget } })

    vicious.register(icon, workers.docker, function(widget, args)
        if #args == 0 then
            icon:set_image(beautiful.widget_docker)
        else
            icon:set_image(beautiful.widget_docker_active)
        end
        local text = table.concat(args, "\n")
        text = string.format(utils.font("monospace 10", "%s"), text)
        icon.tooltip:set_markup(text)
        return ""
    end, 13)

    return widget
end

return setmetatable(dockerwidget, { __call = function(_, ...) return new(...) end })
