---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, MrMagne <mr.magne@yahoo.fr>
--  * (c) 2010, Mic92 <jthalheim@gmail.com>
--  * (c) 2013, Jan Larres <jan@majutsushi.net>
---------------------------------------------------

local vicious = require("vicious")

-- Pulse: provides volume levels of requested pulseaudio sinks and methods to
-- change them
local pulse = {}

-- {{{ Helper functions
local function pacmd(args)
    local f = io.popen("pacmd " .. args)
    local out = f:read("*all")
    f:close()
    return out
end

local function escape(text)
    local special_chars = { ["."] = "%.", ["-"] = "%-" }
    return text:gsub("[%.%-]", special_chars)
end

local default_sink = ""
local cached_sinks = {}

local function get_sink_name(sink)
    if type(sink) == "string" then return sink end
    if sink == nil then return default_sink end

    local key = sink + 1

    -- Cache requests
    if not cached_sinks[key] then
        local line = pacmd("list-sinks")
        for s in string.gmatch(line, "name: <(.-)>") do
            table.insert(cached_sinks, s)
        end
    end

    return cached_sinks[key]
end
-- }}}

-- {{{ Pulseaudio widget type
local function worker(format, sink)
    sink = get_sink_name(sink)
    if sink == nil then return {0, "unknown"} end

    -- Get sink data
    local data = pacmd("dump")

    -- If mute return 0 (not "Mute") so we don't break progressbars
    if string.find(data,"set%-sink%-mute " .. escape(sink) .. " yes") then
    return {0, "off"}
    end

    local vol = tonumber(string.match(data, "set%-sink%-volume " .. escape(sink) .. " (0x[%x]+)"))
    if vol == nil then vol = 0 end

    return { math.floor(vol / 0x10000 * 100), "on"}
end
-- }}}

-- {{{ Volume control helper
function pulse.add(percent, sink)
    sink = get_sink_name(sink)
    if sink == nil then return end

    local data = pacmd("dump")

    local pattern = "set%-sink%-volume " .. escape(sink) .. " (0x[%x]+)"
    local initial_vol =  tonumber(string.match(data, pattern))

    local vol = initial_vol + percent / 100 * 0x10000
    if vol > 0x10000 then vol = 0x10000 end
    if vol < 0 then vol = 0 end

    local cmd = string.format("set-sink-volume %s 0x%x >/dev/null", sink, vol)
    pacmd(cmd)
    vicious.force({ pulse })
end

function pulse.toggle(sink)
    sink = get_sink_name(sink)
    if sink == nil then return end

    local data = pacmd("dump")
    local pattern = "set%-sink%-mute " .. escape(sink) .. " (%a%a%a?)"
    local mute = string.match(data, pattern)

    -- 0 to enable a sink or 1 to mute it.
    local state = { yes = 0, no = 1}
    local cmd = string.format("set-sink-mute %s %d", sink, state[mute])
    pacmd(cmd)
    vicious.force({ pulse })
end
-- }}}

default_sink = string.match(pacmd("dump"), "set%-default%-sink ([^\n]+)")

setmetatable(pulse, { __call = function(_, ...) return worker(...) end })

return pulse
