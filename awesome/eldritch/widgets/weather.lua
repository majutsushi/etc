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
    temp    = "N/A",
    humid   = "N/A",
    wind = {
        deg = "N/A",
        aim = "N/A",
        kmh = "N/A"
    },
    sunrise = "N/A",
    sunset  = "N/A",
    icon    = nil,
}

local function worker(format, warg)
    if not warg then return end

    -- Get weather forceast using the city ID code, from:
    -- * OpenWeatherMap.org
    local url = "http://api.openweathermap.org/data/2.5/weather?id=" .. warg .. "&mode=json&units=metric"
    local f = io.popen("curl --connect-timeout 1 -fsm 3 '" .. url .. "'")
    local jsondata = f:read("*all")
    f:close()

    -- Check if there was a timeout or a problem with the station
    if jsondata == nil then return _wdata end

    local data = json:decode(jsondata)
    if data == nil then return _wdata end

    _wdata.city    = data.name or _wdata.city
    _wdata.updated = os.date('%c', data.dt) or _wdata.updated
    _wdata.sky     = data.weather[1].description or _wdata.sky
    _wdata.temp    = data.main.temp or _wdata.temp
    _wdata.humid   = data.main.humidity or _wdata.humid

    _wdata.wind.kmh = data.wind.speed * 3.6 or _wdata.wind.kmh
    _wdata.wind.deg = tonumber(data.wind.deg)

    if (_wdata.wind.deg / 45) % 1 == 0 then
        _wdata.wind.aim = _wdirs[_wdata.wind.deg / 45 + 1]
    else
        _wdata.wind.aim =
            _wdirs[math.ceil(_wdata.wind.deg / 45) + 1] .. "/" ..
            _wdirs[math.floor(_wdata.wind.deg / 45) + 1]
    end

    _wdata.sunrise = data.sys.sunrise or _wdata.sunrise
    _wdata.sunset  = data.sys.sunset or _wdata.sunset
    _wdata.icon    = data.weather[1].icon or _wdata.icon

    return _wdata
end

return setmetatable(weather, { __call = function(_, ...) return worker(...) end })
