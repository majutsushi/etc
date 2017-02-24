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
function utils.fontsize(size, text)
    return '<span font_size="' .. tostring(size) .. '">' .. tostring(text) ..'</span>'
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

function utils.merge_tables(t1, t2)
    local ret = awful.util.table.clone(t1)

    for k, v in pairs(t2) do
        if type(v) == "table" and ret[k] and type(ret[k]) == "table" then
            ret[k] = utils.merge_tables(ret[k], v)
        else
            ret[k] = v
        end
    end

    return ret
end

-- https://awesomewm.org/wiki/FullScreens
function utils.fullscreens(c)
    c.floating = not c.floating
    if c.floating then
        local clientX = screen[1].workarea.x
        local clientY = screen[1].workarea.y
        local clientWidth = 0
        -- look at http://www.rpm.org/api/4.4.2.2/llimits_8h-source.html
        local clientHeight = 2147483640
        for s = 1, screen.count() do
            clientHeight = math.min(clientHeight, screen[s].workarea.height)
            clientWidth = clientWidth + screen[s].workarea.width
        end
        local t = c:geometry({x = clientX, y = clientY, width = clientWidth, height = clientHeight})
    else
        --apply the rules to this client so he can return to the right tag if there is a rule for that.
        awful.rules.apply(c)
    end
    -- focus our client
    client.focus = c
end

return utils
