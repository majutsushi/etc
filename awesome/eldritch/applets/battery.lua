local beautiful = require("beautiful")
local tooltip = require("eldritch.tooltip")
local vicious = require("vicious")
local wibox = require("wibox")

local batwidget = {}

local function new()
    local textbox = wibox.widget.textbox()

    local widget = wibox.widget {
        {
            wibox.widget.imagebox(beautiful.widget_bat),
            textbox,
            layout = wibox.layout.fixed.horizontal,
        },
        right  = 7,
        widget = wibox.container.margin
    }

    textbox.tooltip = tooltip(
        "Battery charge",
        { "State", "Charge", "Time left" },
        { widget }
    )

    vicious.register(textbox, vicious.widgets.bat, function(widget, args)
        local text = ""
        if args[1] == "-" or args[1] == "−" then
            text = text .. '<span fgcolor="#D75F5F">↓</span>'
        elseif args[1] == "+" then
            text = text .. '<span fgcolor="#87FF87">↑</span>'
        else
            text = args[1]
        end
        if args[1] == "-" or args[1] == "−" or args[1] == "+" then
            if args[2] < 20 then
                text = text .. string.format('<span fgcolor="#D75F5F">%d</span>%%', args[2])
            elseif args[2] < 50 then
                text = text .. string.format('<span fgcolor="#FFD700">%d</span>%%', args[2])
            else
                text = text .. string.format('<span fgcolor="#87FF87">%d</span>%%', args[2])
            end
        end
        widget.tooltip:update({ args[1], args[2] .. "%", args[3] })
        return text
    end, 61, "BAT0")

    return widget
end

return setmetatable(batwidget, { __call = function(_, ...) return new() end })
