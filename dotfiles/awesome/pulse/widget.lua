-- Based on https://awesome.naquadah.org/wiki/Rman%27s_Simple_Volume_Widget

local wibox   = require("wibox")
local beautiful = require("beautiful")
local eldritch = require("eldritch")

local colors = {}
local pulsewidget = {}

function pulsewidget:set_current_level(level)
    self.curlevel = level
end

function pulsewidget:set_muted(state)
    self.is_muted = state
    if self.is_muted then
        self:get_children_by_id("bar")[1]:set_color(colors.muted)
        self.tooltip:update({ "[Muted]" })
    else
        self:get_children_by_id("bar")[1]:set_color(colors.unmuted)
        self.tooltip:update({ self.curlevel .. "%" })
    end
end

function pulsewidget:update(args, notify)
    self:set_current_level(args[1])

    if args[2] == "off" then
        self:set_muted(true)
        return 100
    end

    self:set_muted(false)

    return args[1]
end

function pulsewidget:notify()
    eldritch.osd.notify("Volume", self.curlevel)
end

local function new(icon)
    colors = { unmuted = beautiful.fg_widget, muted = "#FF5656" }

    local widget = wibox.widget {
        {
            id               = "bar",
            background_color = beautiful.bg_widget,
            color            = colors.unmuted,
            widget           = wibox.widget.progressbar,
        },
        forced_width = 8,
        direction    = "east",
        layout       = wibox.container.rotate,
    }

    for k, v in pairs(pulsewidget) do
        if type(v) == "function" then
            widget[k] = v
        end
    end

    widget.curlevel = 0
    widget.is_muted = false
    widget.tooltip = eldritch.tooltip("Volume", { "Level" }, { widget, icon })

    return widget
end

setmetatable(pulsewidget, { __call = function(_, ...) return new(...) end })

return pulsewidget
