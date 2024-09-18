package.path = package.path .. ";" .. os.getenv("DOTFILES") .. "/lua/?.lua"
package.cpath = package.cpath .. ";" .. os.getenv("DOTFILES") .. "/lua/?.so"

-- inspect = require("inspect")

-- https://yazi-rs.github.io/docs/dds/#session.lua
require("session"):setup {
    sync_yanked = true,
}

require("git"):setup({ order = 500 })
require("starship"):setup()

-- https://github.com/sxyazi/yazi/blob/shipped/yazi-plugin/preset/components/linemode.lua
function Linemode:ctime()
    local time = (self._file.cha.created or 0) // 1
    if time == 0 then
        return ui.Line("")
    else
        return ui.Line(os.date("%Y-%m-%d %H:%M", time))
    end
end
function Linemode:mtime()
    local time = (self._file.cha.modified or 0) // 1
    if time == 0 then
        return ui.Line("")
    else
        return ui.Line(os.date("%Y-%m-%d %H:%M", time))
    end
end

-- https://github.com/sxyazi/yazi/blob/shipped/yazi-plugin/preset/components/header.lua
Header:children_add(function()
    local h = cx.active.current.hovered
    if not h then
        return ui.Line {}
    end

    local icon = h:icon()
    local icon_span = ui.Span(" " .. icon.text .. " "):style(icon.style)
    local linked = ""
    if h.link_to ~= nil then
        linked = " -> " .. tostring(h.link_to)
    end
    return ui.Line({icon_span, ui.Span(h.name .. linked)})
end, 1500, Header.LEFT)

-- https://github.com/sxyazi/yazi/blob/shipped/yazi-plugin/preset/components/status.lua
Status:children_add(function()
    local h = cx.active.current.hovered
    if not h then
        return ui.Line {}
    end

    local time = (h.cha.modified or 0) // 1
    if time == 0 then
        return ui.Line("")
    else
        return ui.Line(" " .. os.date("%Y-%m-%d %H:%M", time))
    end
end, 1500, Status.RIGHT)
