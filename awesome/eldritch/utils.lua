local awful = require("awful")
local naughty = require("naughty")
local osd = require("eldritch.osd")

local utils = {}

function utils.brightness(change)
    awful.util.pread("xbacklight -inc " .. change)
    local value = math.floor(awful.util.pread("xbacklight -get"))

    osd.notify("Brightness", value)
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
function utils.bold(text)
  return '<span font_weight="bold">' .. tostring(text) .. '</span>'
end

return utils
