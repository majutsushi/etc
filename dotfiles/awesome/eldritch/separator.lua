local wibox = require("wibox")

local separator = wibox.widget.base.make_widget()

function separator.fit(sep, width, height)
    return width, 10
end

function separator.draw(sep, wibox, cr, width, height)
    cr:move_to(width / 4, height / 2)
    cr:line_to(width * 3 / 4, height / 2)
    cr:set_line_width(3)
    cr:stroke()
end

return separator
