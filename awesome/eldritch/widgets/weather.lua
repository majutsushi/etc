local beautiful = require("beautiful")
local tooltip = require("eldritch.tooltip")
local vicious = require("vicious")
local wibox = require("wibox")
local workers = require("eldritch.workers")

local weatherwidget = {}

local function new()
    local textbox = wibox.widget.textbox()

    local widget = wibox.widget {
        {
            wibox.widget.imagebox(beautiful.weather_dir .. "01d.png"),
            textbox,
            layout = wibox.layout.fixed.horizontal,
        },
        right  = 7,
        widget = wibox.container.margin
    }

    textbox.tooltip = tooltip(
        "Weather",
        { "City", "Updated", "Sky", "Temperature", "Humidity", "Wind", "Sunrise", "Sunset" },
        { widget }
    )

    vicious.register(textbox, workers.weather, function(widget, args)
        widget.tooltip:update({
            args.city,
            args.updated,
            args.sky,
            string.format("%s °C", args.temp),
            args.humid .. "%",
            string.format("%s, %s km/h", args.wind.aim, args.wind.kmh),
            string.format(os.date('%H:%M', args.sunrise)),
            string.format(os.date('%H:%M', args.sunset))
        })
        if args.icon then
            weathericon:set_image(beautiful.weather_dir .. args.icon .. ".png")
        end
        return math.floor(args.temp + 0.5) .. "°C"
    end, 60, "2179537")

    return widget
end

return setmetatable(weatherwidget, { __call = function(_, ...) return new(...) end })
