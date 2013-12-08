local json = require("JSON")

local weather = {}

local _wdirs = { "N", "NE", "E", "SE", "S", "SW", "W", "NW", "N" }
local _wdata = {
    ["{city}"]      = "N/A",
    ["{wind deg}"]  = "N/A",
    ["{wind aim}"]  = "N/A",
    ["{wind mps}"]  = "N/A",
    ["{wind kmh}"]  = "N/A",
    ["{sky}"]       = "N/A",
    ["{weather}"]   = "N/A",
    ["{temp c}"]    = "N/A",
    ["{humid}"]     = "N/A",
    ["{press}"]     = "N/A"
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

    return json:decode(jsondata)
end

return setmetatable(weather, { __call = function(_, ...) return worker(...) end })
