-- Based on https://awesome.naquadah.org/wiki/Rman%27s_Simple_Volume_Widget

local awful   = require("awful")
local vicious = require("vicious")
local naughty = require("naughty")
local pulse   = require("pulse.pulse")

local colors = { unmuted = "#AECF96", muted = "#FF5656" }
local notifyid = nil

local notifications = {
    icons = {
        -- the first item is the 'muted' icon
        "/usr/share/icons/Faenza-Dark/status/48/audio-volume-muted.png",
        -- the rest of the items correspond to intermediate volume levels - you can have as many as you want (but must be >= 1)
        "/usr/share/icons/Faenza-Dark/status/48/audio-volume-low.png",
        "/usr/share/icons/Faenza-Dark/status/48/audio-volume-medium.png",
        "/usr/share/icons/Faenza-Dark/status/48/audio-volume-high.png"
    },
    font = "Monospace 11", -- must be a monospace font for the bar to be sized consistently
    icon_size = 48,
    bar_size = 19 -- adjust to fit your font if the bar doesn't fit
}

local pulsewidget = {}

function pulsewidget:set_current_level(level)
    self.current_level = level
end

function pulsewidget:set_muted(state)
    self.muted = state
    if self.muted then
        self:set_color(colors.muted)
        self.tooltip:set_text(" [Muted] ")
    else
        self:set_color(colors.unmuted)
        self.tooltip:set_text(" " .. self.current_level .. "% ")
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
    local preset =
    {
        height = 75,
        width = 300,
        font = notifications.font
    }
    local i = 1;
    while notifications.icons[i + 1] ~= nil do
        i = i + 1
    end
    if i >= 2 then
        preset.icon_size = notifications.icon_size
        if self.muted or self.current_level == 0 then
            preset.icon = notifications.icons[1]
        elseif self.current_level == 100 then
            preset.icon = notifications.icons[i]
        else
            local int = math.modf(self.current_level / 100 * (i - 1))
            preset.icon = notifications.icons[int + 2]
        end
    end
    if self.muted then
        preset.title = "Muted"
    elseif self.current_level == 0 then
        preset.title = "0% (muted)"
        preset.text = "[" .. string.rep(" ", notifications.bar_size) .. "]"
    elseif self.current_level == 100 then
        preset.title = "100% (max)"
        preset.text = "[" .. string.rep("|", notifications.bar_size) .. "]"
    else
        local int = math.modf(self.current_level / 100 * notifications.bar_size)
        preset.title = self.current_level .. "%"
        preset.text = "[" .. string.rep("|", int) .. string.rep(" ", notifications.bar_size - int) .. "]"
    end
    if notifyid ~= nil then
        notifyid = naughty.notify({
            replaces_id = notifyid.id,
            preset = preset
        })
    else
        notifyid = naughty.notify({ preset = preset })
    end
end

local function new()
    local widget = awful.widget.progressbar()

    widget:set_width(8)
    widget:set_vertical(true)
    widget:set_background_color("#494B4F")
    widget:set_color(colors.unmuted)

    for k, v in pairs(pulsewidget) do
        if type(v) == "function" then
            widget[k] = v
        end
    end

    widget.current_level = 0
    widget.muted = false
    widget.tooltip = awful.tooltip({ objects = { widget } })

    return widget
end

setmetatable(pulsewidget, { __call = function(_, ...) return new(...) end })

return pulsewidget
