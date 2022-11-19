local beautiful = require("beautiful")
local utils = require("eldritch.utils")
local wibox = require("wibox")

local inhibitwidget = {}

local enabled = false

local function get_root_win_id()
    local out = utils.trim(utils.exec("xwininfo -root | grep -E '^xwininfo:'"))
    return out:match("Window id: (0x[0-9a-f]+) ")
end

local function new()
    local icon = wibox.widget.imagebox(beautiful.widget_inhibit)

    local widget = wibox.widget {
        icon,
        right  = 7,
        widget = wibox.container.margin
    }

    local window_id = get_root_win_id()
    if window_id ~= nil then
        icon:connect_signal("button::press", function()
            if enabled then
                if os.execute("xdg-screensaver resume " .. window_id) then
                    enabled = false
                    icon:set_image(beautiful.widget_inhibit)
                end
            else
                if os.execute("xdg-screensaver suspend " .. window_id) then
                    enabled = true
                    icon:set_image(beautiful.widget_inhibit_active)
                end
            end
        end)
    end

    return widget
end

return setmetatable(inhibitwidget, { __call = function(_, ...) return new() end })
