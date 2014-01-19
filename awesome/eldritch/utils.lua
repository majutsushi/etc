local awful = require("awful")
local naughty = require("naughty")
local osd = require("eldritch.osd")

local utils = {}

function utils.exec(cmd)
    local f = io.popen(cmd)
    local out = f:read("*all")
    f:close()
    return out
end

function utils.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end

    local t = {}
    local i = 1

    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end

    return t
end

function utils.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

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
