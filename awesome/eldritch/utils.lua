local awful = require("awful")
awful.widget.common = require("awful.widget.common")
local beautiful = require("beautiful")
local naughty = require("naughty")
local osd = require("eldritch.osd")
local wibox = require("wibox")

local utils = {}

function utils.exec(cmd)
    local f = io.popen(cmd)
    local out = f:read("*all")
    f:close()
    return out
end

function utils.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end

    local t = {}
    local i = 1

    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end

    return t
end

function utils.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function utils.brightness(change)
    local arg
    if change < 0 then
        arg = "-U"
    else
        arg = "-A"
    end

    awful.spawn.easy_async(
        "light " .. arg .. " " .. tostring(math.abs(change)),
        function(stdout, stderr, reason, exit_code)
            awful.spawn.easy_async(
                "light -G",
                function(stdout, stderr, reason, exit_code)
                    osd.notify("Brightness", math.floor(tonumber(stdout) + 0.5))
                end
            )
        end
    )
end

function utils.font(font, text)
    return '<span font="' .. tostring(font) .. '">' .. tostring(text) ..'</span>'
end
function utils.fontsize(size, text)
    return '<span font_size="' .. tostring(size) .. '">' .. tostring(text) ..'</span>'
end
function utils.fgcolor(color, text)
    return '<span fgcolor="' .. tostring(color) .. '">' .. tostring(text) .. '</span>'
end
function utils.bgcolor(color, text)
    return '<span bgcolor="' .. tostring(color) .. '">' .. tostring(text) .. '</span>'
end
function utils.bold(text)
    return '<span font_weight="bold">' .. tostring(text) .. '</span>'
end

function utils.merge_tables(t1, t2)
    local ret = awful.util.table.clone(t1)

    for k, v in pairs(t2) do
        if type(v) == "table" and ret[k] and type(ret[k]) == "table" then
            ret[k] = utils.merge_tables(ret[k], v)
        else
            ret[k] = v
        end
    end

    return ret
end

-- https://awesomewm.org/wiki/FullScreens
function utils.fullscreens(c)
    c.floating = not c.floating
    if c.floating then
        local clientX = screen[1].workarea.x
        local clientY = screen[1].workarea.y
        local clientWidth = 0
        -- look at http://www.rpm.org/api/4.4.2.2/llimits_8h-source.html
        local clientHeight = 2147483640
        for s = 1, screen.count() do
            clientHeight = math.min(clientHeight, screen[s].workarea.height)
            clientWidth = clientWidth + screen[s].workarea.width
        end
        local t = c:geometry({ x      = clientX,
                               y      = clientY,
                               width  = clientWidth - beautiful.border_width * 2,
                               height = clientHeight - beautiful.border_width * 2 })
    else
        -- apply the rules to this client so he can return to the right tag
        -- if there is a rule for that.
        awful.rules.apply(c)
    end
    -- focus our client
    client.focus = c
end

function utils.tasklist_update(w, buttons, label, data, objects)
    local dpi = beautiful.xresources.apply_dpi

    -- update the widgets, creating them if needed
    w:reset()
    for i, o in ipairs(objects) do
        local cache = data[o]
        local ib, tb, bgb, tbm, ibm, l, tt
        if cache then
            ib = cache.ib
            tb = cache.tb
            bgb = cache.bgb
            tbm = cache.tbm
            ibm = cache.ibm
            tt = cache.tt
        else
            ib = wibox.widget.imagebox()
            tb = wibox.widget.textbox()
            bgb = wibox.container.background()
            tbm = wibox.container.margin(tb, dpi(4), dpi(4))
            ibm = wibox.container.margin(ib, dpi(4))
            l = wibox.layout.fixed.horizontal()
            tt = awful.tooltip({ objects = { l } })

            -- All of this is added in a fixed widget
            l:fill_space(true)
            l:add(ibm)
            l:add(tbm)

            -- And all of this gets a background
            bgb:set_widget(l)

            bgb:buttons(awful.widget.common.create_buttons(buttons, o))

            data[o] = {
                ib  = ib,
                tb  = tb,
                bgb = bgb,
                tbm = tbm,
                ibm = ibm,
                tt  = tt,
            }
        end

        local text, bg, bg_image, icon, args = label(o, tb)
        args = args or {}

        -- The text might be invalid, so use pcall.
        if text == nil or text == "" then
            tbm:set_margins(0)
        else
            if not tb:set_markup_silently(text) then
                tb:set_markup("<i>&lt;Invalid text&gt;</i>")
            end
        end
        bgb:set_bg(bg)
        if type(bg_image) == "function" then
            -- TODO: Why does this pass nil as an argument?
            bg_image = bg_image(tb,o,nil,objects,i)
        end
        bgb:set_bgimage(bg_image)
        if icon then
            ib:set_image(icon)
        else
            ibm:set_margins(0)
        end
        tt:set_markup(text)

        bgb.shape              = args.shape
        bgb.shape_border_width = args.shape_border_width
        bgb.shape_border_color = args.shape_border_color

        w:add(bgb)
    end
end

return utils
