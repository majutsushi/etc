-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat monitor widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Widget with circle indicator
-- This is taken from https://github.com/worron/redflat/blob/master/gauge/cirmon.lua
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local utils = require("eldritch.utils")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local cirmon = { mt = {} }
local TPI = math.pi * 2

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
    local style = {
        width        = nil,
        line_width   = 4,
        radius       = 7,
        iradius      = 3,
        color    = { main = beautiful.fg_widget, gray = beautiful.bg_widget, icon = "#a0a0a0" }
    }
    -- return utils.merge_tables(style, utils.check(beautiful, "gauge.cirmon") or {})
    return style
end

-- Create a new monitor widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function cirmon.new(style)

    -- Initialize vars
    --------------------------------------------------------------------------------
    local style = utils.merge_tables(default_style(), style or {})
    local cs = -TPI / 4

    -- updating values
    local data = {
        value = 0,
        width = style.width,
        color = style.color.icon
    }

    -- Create custom widget
    --------------------------------------------------------------------------------
    local widg = wibox.widget.base.make_widget()

    -- User functions
    ------------------------------------------------------------
    function widg:set_value(x)
        data.value = x < 1 and x or 1
        self:emit_signal("widget::updated")
    end

    function widg:set_width(width)
        data.width = width
        self:emit_signal("widget::updated")
    end

    function widg:set_alert(alert)
        data.color = alert and style.color.main or style.color.icon
        self:emit_signal("widget::updated")
    end

    -- Fit
    ------------------------------------------------------------
    function widg:fit(widg, width, height)
        if data.width then
            return data.width, height
        else
            local size = math.min(width, height)
            return size, size
        end
    end

    -- Draw
    ------------------------------------------------------------
    function widg:draw(widg, cr, width, height)

        -- center circle
        cr:set_source(color(data.color))
        cr:arc(width / 2, height / 2, style.iradius, 0, TPI)
        cr:fill()

        -- progress circle
        cr:set_line_width(style.line_width)
        local cd = { TPI, TPI * data.value }
        for i = 1, 2 do
            cr:set_source(color(i > 1 and style.color.main or style.color.gray))
            cr:arc(width / 2, height / 2, style.radius, cs, cs + cd[i])
            cr:stroke()
        end
    end

    --------------------------------------------------------------------------------
    return widg
end

-- Config metatable to call monitor module as function
-----------------------------------------------------------------------------------------------------------------------
function cirmon.mt:__call(...)
    return cirmon.new(...)
end

return setmetatable(cirmon, cirmon.mt)
