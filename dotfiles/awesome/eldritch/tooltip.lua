local awful = require("awful")
local beautiful = require("beautiful")
local utils = require("eldritch.utils")

local tooltip = {}

local _tooltip = {
    titlecolor = beautiful.tooltip_title_color or "#f0e68c",
    keycolor = beautiful.tooltip_key_color or "#98fb98"
}

function _tooltip:update(values)
    local title = " " .. utils.bold(self.title)
    local title = utils.fgcolor(self.titlecolor, title) .. "\n\n"

    local body = ""
    for i, key in ipairs(self.keys) do
        body = body .. key .. tostring(values[i]) .. " \n"
    end

    self.tooltip:set_markup(utils.font("monospace 10", title .. body))
end

local function new(title, keys, objects)
    local o = setmetatable({}, { __index = _tooltip })

    o.tooltip = awful.tooltip({ objects = objects })
    o.title = title

    local maxlen = 0
    for _, key in ipairs(keys) do
        if key:len() > maxlen then
            maxlen = key:len()
        end
    end
    o.keys = {}
    for i, key in ipairs(keys) do
        local text = " " .. utils.fgcolor(o.keycolor, key)
        text = text .. string.rep(" ", maxlen - key:len()) .. " : "
        o.keys[i] = text
    end

    return o
end

setmetatable(tooltip, { __call = function(_, ...) return new(...) end })

return tooltip
