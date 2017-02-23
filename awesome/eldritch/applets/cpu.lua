local beautiful = require("beautiful")
local tooltip = require("eldritch.tooltip")
local vicious = require("vicious")
local wibox = require("wibox")

local cpuwidget = {}

local function getnprocs()
    local f = io.popen("grep -c processor /proc/cpuinfo")
    local nprocs = f:read("*all")
    f:close()

    return nprocs
end

local function getcpucolours(nprocs)
    local colours = { "#ffffff" }
    local step = math.floor(0xff / nprocs)

    for i = nprocs - 2, 1, -1 do
        local curval = step * i
        local newcolour = string.format("#%x%x%x", curval, curval, curval)
        colours[#colours + 1] = newcolour
    end

    colours[#colours + 1] = "#000000"

    return colours
end

local function getcpukeys(nprocs)
    local keys = { "Total" }

    for i = 1, nprocs do
        table.insert(keys, "CPU " .. i)
    end

    return keys
end

local function new()
    local nprocs = getnprocs()

    local graph = wibox.widget {
        forced_width     = 50,
        stack            = true,
        max_value        = 100,
        background_color = beautiful.bg_normal,
        stack_colors     = getcpucolours(nprocs),
        widget           = wibox.widget.graph
    }

    local textbox = wibox.widget.textbox()
    textbox.graph = graph

    local widget = wibox.widget {
        {
            wibox.widget.imagebox(beautiful.widget_cpu),
            {
                graph,
                reflection = { horizontal = true, vertical = false },
                widget     = wibox.container.mirror,
            },
            layout = wibox.layout.fixed.horizontal,
        },
        right  = 7,
        widget = wibox.container.margin
    }

    textbox.tooltip = tooltip("CPU", getcpukeys(nprocs), { widget })

    vicious.register(textbox, vicious.widgets.cpu, function(widget, args)
        local values = { args[1] .. "%" }
        for i = 2, #args do
            table.insert(values, args[i] .. "%")
            widget.graph:add_value(args[i], i - 1)
        end
        widget.tooltip:update(values)
        return args[1]
    end)

    return widget
end

return setmetatable(cpuwidget, { __call = function(_, ...) return new(...) end })
