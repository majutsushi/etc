local awful = require("awful")
local beautiful = require("beautiful")
local utils = require("eldritch.utils")
local wibox = require("wibox")


local notifhist = {}

notifhist.notifications = {}


function notifhist.add_notification(data)
    if not data.title and not data.text then return end

    table.insert(notifhist.notifications, {
        title = data.title or data.appname,
        text = data.text,
        urgency = data.freedesktop_hints and data.freedesktop_hints.urgency
    })

    -- Remove the oldest notification if we are over the limit
    if #notifhist.notifications > 10 then
        table.remove(notifhist.notifications, 1)
    end
end


function notifhist.new()
    local icon = wibox.widget.imagebox(beautiful.widget_notifhist)

    local widget = wibox.widget {
        icon,
        widget = wibox.container.margin
    }

    icon.tooltip = awful.tooltip({ objects = { widget } })
    function icon.tooltip.update()
        local items = {}

        for _, val in ipairs(notifhist.notifications) do
            if val.title then
                text = utils.bold(val.title)
                -- Print the title of critical notifications in red
                if val.urgency == "\2" then
                    text = utils.fgcolor("#ff0000", text)
                end
            end
            if text and val.text then
                text = text .. "\n" .. val.text
            elseif val.text then
                text = val.text
            end
            table.insert(items, utils.font(beautiful.notification_font, text))
        end

        local separator = utils.fgcolor("#999999", "\n     ——————————     \n")
        text = table.concat(items, separator)

        icon.tooltip:set_markup(text)
    end
    icon.tooltip:update()

    widget:connect_signal("mouse::enter", icon.tooltip.update)

    return widget
end


return notifhist
