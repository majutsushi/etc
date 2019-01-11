local awful = require("awful")
local beautiful = require("beautiful")
local glib = require("lgi").GLib
local utils = require("eldritch.utils")
local vicious = require("vicious")
local wibox = require("wibox")
local workers = require("eldritch.workers")

local dockerwidget = {}

local imagecolor = beautiful.tooltip_title_color or "#f0e68c"
local headercolor = beautiful.tooltip_key_color or "#98fb98"

local function gettags(image)
    local f = io.popen("docker image inspect --format='{{.RepoTags}}' " .. image)

    local tags = f:read()

    f:close()

    tags = tags:sub(2, -2)

    local rv = {}

    for _, tag in pairs(utils.split(tags, " ")) do
        if tag:find("amazonaws.com") then
            local slash = tag:find("/")
            if slash then
                tag = "ECR" .. tag:sub(slash)
            end
        end
        rv[#rv + 1] = tag
    end

    return rv
end

local function new()
    local icon = wibox.widget.imagebox(beautiful.widget_docker)

    local widget = wibox.widget {
        icon,
        right  = 7,
        widget = wibox.container.margin
    }

    icon.tooltip = awful.tooltip({ objects = { widget } })

    function icon.tooltip.update()
        local f = io.popen("docker ps --format='{{.Image}}\t{{.Command}}\t{{.Names}}' --no-trunc")

        local data = {}

        for line in f:lines() do
            local linedata = utils.split(line, "\t")

            local image = linedata[1]
            local command = glib.markup_escape_text(linedata[2], -1)
            local names = linedata[3]

            local tags = gettags(image)

            local text = utils.bold(utils.fgcolor(imagecolor, image))
            text = text .. utils.fgcolor(headercolor, "\n  Command") .. ": " .. command
            text = text .. utils.fgcolor(headercolor, "\n  Names") .. ": " .. names
            text = text .. utils.fgcolor(headercolor, "\n  Tags") .. ":"
            for _, tag in pairs(tags) do
                text = text .. "\n    " .. tag
            end

            data[#data + 1] = utils.font("monospace 10", text)
        end

        icon.tooltip:set_markup(table.concat(data, "\n\n"))
    end

    widget:connect_signal("mouse::enter", icon.tooltip.update)

    vicious.register(icon, workers.docker, function(widget, args)
        if #args == 0 then
            icon:set_image(beautiful.widget_docker)
        else
            icon:set_image(beautiful.widget_docker_active)
        end
        return ""
    end, 13)

    return widget
end

return setmetatable(dockerwidget, { __call = function(_, ...) return new(...) end })
