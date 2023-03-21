local awful = require("awful")
local naughty = require("naughty")
local utils = require("eldritch.utils")

local mpris = {}

function mpris.send_cmd(cmd)
    utils.exec("playerctl " .. cmd)
    local status = utils.trim(utils.exec("playerctl -f '{{playerName}}: {{status}}' status"))
    naughty.notify({ title = cmd, text = status })
end

return mpris
