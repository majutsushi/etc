-- Based on https://awesome.naquadah.org/wiki/Rman%27s_Simple_Volume_Widget

local awful   = require("awful")
local vicious = require("vicious")
local naughty = require("naughty")
local pulse   = require("pulse.pulse")
local beautiful = require("beautiful")
local eldritch = require("eldritch")

local colors = {}
local pulsewidget = {}

function pulsewidget:set_current_level(level)
    self.current_level = level
end

function pulsewidget:set_muted(state)
    self.muted = state
    if self.muted then
        self:set_color(colors.muted)
        self.tooltip:update({ "[Muted]" })
    else
        self:set_color(colors.unmuted)
        self.tooltip:update({ self.current_level .. "%" })
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
    eldritch.osd.notify("Volume", self.current_level)
end

local function new(icon)
    colors = { unmuted = beautiful.fg_widget, muted = "#FF5656" }

    local widget = awful.widget.progressbar()

    widget:set_width(8)
    widget:set_vertical(true)
    widget:set_background_color(beautiful.bg_widget)
    widget:set_color(colors.unmuted)

    for k, v in pairs(pulsewidget) do
        if type(v) == "function" then
            widget[k] = v
        end
    end

    widget.current_level = 0
    widget.muted = false
    widget.tooltip = eldritch.tooltip("Volume", { "Level" }, { widget, icon })

    return widget
end

setmetatable(pulsewidget, { __call = function(_, ...) return new(...) end })

return pulsewidget
