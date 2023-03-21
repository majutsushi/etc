---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, MrMagne <mr.magne@yahoo.fr>
--  * (c) 2010, Mic92 <jthalheim@gmail.com>
--  * (c) 2013, Jan Larres <jan@majutsushi.net>
---------------------------------------------------

local utils = require("eldritch.utils")

-- Pulse: provides volume levels of requested pulseaudio sinks and methods to
-- change them
local pulse = {}

-- {{{ Helper functions
local function pactl(args)
    local f = io.popen("pactl " .. args)
    local out = f:read("*all")
    f:close()
    return utils.trim(out)
end

local function escape(text)
    local special_chars = { ["."] = "%.", ["-"] = "%-" }
    return text:gsub("[%.%-]", special_chars)
end

local function round(num)
    return math.floor(num + 0.5)
end
-- }}}

-- {{{ Pulseaudio widget type
local function worker(format)
    -- If mute return 0 (not "Mute") so we don't break progressbars
    if string.find(pactl("get-sink-mute @DEFAULT_SINK@"), "Mute: yes") then
        return {0, "off"}
    end

    local out = pactl("get-sink-volume @DEFAULT_SINK@")
    local vol = tonumber(string.match(out, "([%d]+)%%"))
    if vol == nil then vol = 0 end

    return { vol, "on"}
end
-- }}}

-- {{{ Volume control helper
function pulse.add(percent)
    local s
    if percent > 0 then
        s = "+" .. percent
    else
        s = tostring(percent)
    end
    pactl("set-sink-volume @DEFAULT_SINK@ " .. s .. "%")
end

function pulse.toggle()
    pactl("set-sink-mute @DEFAULT_SINK@ toggle")
end
-- }}}

function pulse.toggle_mic()
    pactl("set-source-mute @DEFAULT_SOURCE@ toggle")
end

setmetatable(pulse, { __call = function(_, ...) return worker(...) end })

return pulse
