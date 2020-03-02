-- License: Public Domain or ISC
-- Authors: Bzed (http://awesome.naquadah.org/wiki/Calendar_widget)
--          Marc Dequènes (Duck) <Duck@DuckCorp.org> (2009-12-29)
--          Jörg Thalheim (Mic92) <jthalheim@gmail.com> (2011)
--          Jan Larres (2013)
--
-- 1. require it in your rc.lua
--      require("cal")
-- 2. attach the calendar to a widget of your choice (ex mytextclock)
--      cal.register(mytextclock)
--
-- # How to Use #
-- Just hover with your mouse over the widget, you register and the calendar popup.
-- On clicking or by using the mouse wheel the displayed month changes.
-- Pressing Shift + Mouse click change the year.

local awful = require("awful")
local beautiful = require("beautiful")
local utils = require("eldritch.utils")

local cal = {}

local tooltip
local state = { month=nil, year=nil }
local current_day_format = utils.bgcolor("#4d4d4d", utils.fgcolor("#98fb98", "%s"))

local function displayMonth(month, year, weekStart)
    local t = os.time({ year=year, month=month+1, day=0 })
    local d = os.date("*t", t)
    local mthDays, stDay = d.day, (d.wday - d.day - weekStart + 1) % 7

    local lines = "    "

    for x = 0, 6 do
        lines = lines .. os.date("%a ", os.time({ year=2006, month=1, day=x+weekStart }))
    end

    lines = lines .. "\n" .. utils.fgcolor("#999999", os.date(" %V", os.time({ year=year, month=month, day=1 })))

    local writeLine = 1
    while writeLine < (stDay + 1) do
        lines = lines .. "    "
        writeLine = writeLine + 1
    end

    for d = 1, mthDays do
        local x = d
        local t = os.time({ year=year, month=month, day=d })
        if writeLine == 8 then
            writeLine = 1
            lines = lines .. "\n" .. utils.fgcolor("#999999", os.date(" %V",t))
        end
        if os.date("%Y-%m-%d") == os.date("%Y-%m-%d", t) then
            x = string.format(current_day_format, d)
        end
        if d < 10 then
            x = " " .. x
        end
        lines = lines .. "  " .. x
        writeLine = writeLine + 1
    end
    if stDay + mthDays < 36 then
        lines = lines .. "\n"
    end
    if stDay + mthDays < 29 then
        lines = lines .. "\n"
    end
    local header = os.date(" %B %Y\n", os.time({ year=year, month=month, day=1 }))
    header = utils.fgcolor(beautiful.tooltip_title_color or "#f0e68c", utils.bold(header))

    return header .. "\n" .. lines
end

local function worldclock()
    -- File format example:
    --   New Zealand|Pacific/Auckland
    local tzfile = io.open(os.getenv("HOME") .. "/.config/etc/timezones")
    if tzfile == nil then
        return ""
    end

    local titlecolor = beautiful.tooltip_title_color or "#f0e68c"
    local localday = utils.trim(utils.exec("date +'%A'"))
    local text = ""

    for line in tzfile:lines() do
        local out = utils.exec("TZ=" .. line .. " date +'%H:%M_%A_%Z'")
        local data = utils.split(utils.trim(out), "_")

        text = text .. "\n " .. utils.fgcolor("#98fb98", line)
        text = text .. "\n " .. data[1]

        local tztext = data[3]

        -- Calculate difference to current time zone
        local tzdiff = utils.exec("TZ=" .. line .. " date +'%z'") - utils.exec("date +'%z'")
        if tzdiff ~= 0 then
            local sign, hours, minutes = string.match(tzdiff, "(-?)(%d?%d)(%d%d)")
            if sign == "" then
                sign = "+"
            end
            tztext = tztext .. " " .. sign .. hours
            if minutes ~= "00" then
                tztext = tztext .. ":" .. minutes
            end
        end

        if data[2] ~= localday then
            tztext = tztext .. " (" .. data[2] .. ")"
        end

        tztext = " " .. utils.fontsize("small", utils.fgcolor("#999999", tztext))

        text = text .. tztext .. "\n"
    end

    return text
end

local function assemble_text(calinfo)
    local text = calinfo
    local separator = utils.fgcolor("#999999", "\n     ——————————————————————     \n")
    text = text .. "\n" .. separator .. worldclock()

    return string.format(utils.font("monospace 10", "%s"), text)
end

local function switchMonth(delta)
    state.month = state.month + (delta or 1)
    local text = assemble_text(displayMonth(state.month, state.year, 2))
    tooltip:set_markup(text)
end

function cal.register(mywidget)
    if not tooltip then
        tooltip = awful.tooltip({})
        function tooltip:update()
            local month, year = os.date('%m'), os.date('%Y')
            state = { month=month, year=year}
            tooltip:set_markup(assemble_text(displayMonth(month, year, 2)))
        end
        tooltip:update()
    end
    tooltip:add_to_object(mywidget)

    mywidget:connect_signal("mouse::enter", tooltip.update)

    mywidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
        switchMonth(-1)
    end),
    awful.button({ }, 2, function()
        state.month = os.date('%m')
        state.year  = os.date('%Y')
        switchMonth(0)
    end),
    awful.button({ }, 3, function()
        switchMonth(1)
    end),
    awful.button({ }, 4, function()
        switchMonth(-1)
    end),
    awful.button({ }, 5, function()
        switchMonth(1)
    end),
    awful.button({ 'Shift' }, 1, function()
        switchMonth(-12)
    end),
    awful.button({ 'Shift' }, 3, function()
        switchMonth(12)
    end),
    awful.button({ 'Shift' }, 4, function()
        switchMonth(-12)
    end),
    awful.button({ 'Shift' }, 5, function()
        switchMonth(12)
    end)))
end

return cal
