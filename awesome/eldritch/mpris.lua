local awful = require("awful")
local naughty = require("naughty")

local mpris = {}

local function get_first_player()
    local f = io.popen(
        "dbus-send " ..
            "--session " ..
            "--dest=org.freedesktop.DBus " ..
            "--type=method_call " ..
            "--print-reply=literal " ..
            "/org/freedesktop/DBus " ..
            "org.freedesktop.DBus.ListNames"
    )
    local out = f:read("*all")
    f:close()

    for instance in out:gmatch("org.mpris.MediaPlayer2.[^ ]+") do
        f = io.popen(
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
        out = f:read("*all")
        f:close()
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
