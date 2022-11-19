local awful = require("awful")
local naughty = require("naughty")
local utils = require("eldritch.utils")

local mpris = {}

local function get_first_player()
    local out = utils.exec(
        "dbus-send " ..
        "--session " ..
        "--dest=org.freedesktop.DBus " ..
        "--type=method_call " ..
        "--print-reply=literal " ..
        "/org/freedesktop/DBus " ..
        "org.freedesktop.DBus.ListNames"
    )

    for instance in out:gmatch("org.mpris.MediaPlayer2.[^ ]+") do
        out = utils.exec(
            "dbus-send " ..
            "--session " ..
            "--type=method_call " ..
            "--print-reply=literal " ..
            "--dest=" .. instance .. " " ..
            "/org/mpris/MediaPlayer2 " ..
            "org.freedesktop.DBus.Properties.Get " ..
            "string:org.mpris.MediaPlayer2.Player " ..
            "string:PlaybackStatus"
        )
        if out:find("Playing") ~= nil or out:find("Paused") ~= nil then
            return instance
        end
    end

    return nil
end

function mpris.send_cmd(cmd)
    local player = get_first_player()
    if player == nil then
        naughty.notify({ text = "No running player found" })
        return
    end
    awful.spawn(
        "dbus-send " ..
        "--type=method_call " ..
        "--dest=" .. player .. " " ..
        "/org/mpris/MediaPlayer2 " ..
        "org.mpris.MediaPlayer2.Player." .. cmd
    )
    naughty.notify({ title = cmd, text = player })
end

return mpris
