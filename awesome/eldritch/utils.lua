local awful = require("awful")
local naughty = require("naughty")

local utils = {}

function utils.brightness(change)
    awful.util.pread("xbacklight -inc " .. change)
    local value = math.floor(awful.util.pread("xbacklight -get"))

    local bar_size = 19
    local preset =
    {
        height = 75,
        width = 300,
        font = "Monospace 11",
        icon = "/usr/share/icons/Faenza-Dark/status/scalable/display-brightness-symbolic.svg",
        icon_size = 48,
    }

    local int = math.modf(value / 100 * bar_size)
    preset.title = value .. "%"
    preset.text = "[" .. string.rep("|", int) .. string.rep(" ", bar_size - int) .. "]"

    if notifyid ~= nil then
        notifyid = naughty.notify({
            replaces_id = notifyid.id,
            preset = preset
        })
    else
        notifyid = naughty.notify({ preset = preset })
    end
end

function utils.font(font, text)
  return '<span font="' .. tostring(font) .. '">' .. tostring(text) ..'</span>'
end
function utils.fgcolor(color, text)
  return '<span fgcolor="' .. tostring(color) .. '">' .. tostring(text) .. '</span>'
end
function utils.bgcolor(color, text)
  return '<span bgcolor="' .. tostring(color) .. '">' .. tostring(text) .. '</span>'
end

return utils
