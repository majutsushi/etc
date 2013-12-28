-- Author: Jan Larres <jan@majutsushi.net>
-- Based on http://git.sysphere.org/vicious/tree/contrib/openweather.lua
-- License: GPLv2

local json = require("JSON")

local weather = {}

local _wdirs = { "N", "NE", "E", "SE", "S", "SW", "W", "NW", "N" }
local _wdata = {
    city    = "N/A",
    updated = "N/A",
    sky     = "N/A",
    temp    = 0/0,
    humid   = "N/A",
    wind = {
        deg = "N/A",
        aim = "N/A",
        kmh = "N/A"
    },
    sunrise = 1,
    sunset  = 1,
    icon    = nil,
}
local wdata = {}

local starttimer = nil
local updatetimer = nil

local function update(id)
    -- Get weather forceast using the city ID code, from:
    -- * OpenWeatherMap.org
    local url = "http://api.openweathermap.org/data/2.5/weather?id=" .. id .. "&mode=json&units=metric"
    local f = io.popen("curl --connect-timeout 1 -fsm 3 '" .. url .. "'")
    local jsondata = f:read("*all")
    f:close()

    -- Check if there was a timeout or a problem with the station
    if jsondata == nil then return end

    local data = json:decode(jsondata)
    if data == nil then return end

    wdata.city    = data.name or _wdata.city
    wdata.updated = os.date('%c', data.dt) or _wdata.updated
    wdata.sky     = data.weather[1].description or _wdata.sky
    wdata.temp    = data.main.temp or _wdata.temp
    wdata.humid   = data.main.humidity or _wdata.humid

    wdata.wind = {
        kmh = data.wind.speed * 3.6 or _wdata.wind.kmh,
        deg = tonumber(data.wind.deg)
    }

    if (wdata.wind.deg / 45) % 1 == 0 then
        wdata.wind.aim = _wdirs[wdata.wind.deg / 45 + 1]
    else
        wdata.wind.aim =
            _wdirs[math.ceil(wdata.wind.deg / 45) + 1] .. "/" ..
            _wdirs[math.floor(wdata.wind.deg / 45) + 1]
    end

    wdata.sunrise = data.sys.sunrise or _wdata.sunrise
    wdata.sunset  = data.sys.sunset or _wdata.sunset
    wdata.icon    = data.weather[1].icon or _wdata.icon
end

local function start_updatetimer(id)
    starttimer:stop()
    update(id)
    updatetimer = timer({ timeout = 601 })
    updatetimer:connect_signal("timeout", function() update(id) end)
    updatetimer:start()
end

local function worker(format, warg)
    if not warg then return end

    -- Start a timer here so an awesome restart is not slowed down by an
    -- update. Also use a "kickstart" timer so the first update doesn't take
    -- 10 minutes.
    if not starttimer and not updatetimer then
        starttimer = timer({ timeout = 30 })
        starttimer:connect_signal("timeout", function() start_updatetimer(warg) end)
        starttimer:start()
        return _wdata
    end

    -- Check whether wdata is still empty
    if next(wdata) == nil then
        return _wdata
    end

    return wdata
end

return setmetatable(weather, { __call = function(_, ...) return worker(...) end })
