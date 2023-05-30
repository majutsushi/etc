
--[[

     Awesome-Freedesktop
     Freedesktop.org compliant desktop entries and menu

     Menu section

     Licensed under GNU General Public License v2
      * (c) 2016, Luke Bonham
      * (c) 2014, Harvey Mittens

     https://github.com/copycat-killer/awesome-freedesktop

--]]

local awful_menu = require("awful.menu")
local menu_gen   = require("menubar.menu_gen")
local menu_utils = require("menubar.utils")
local icon_theme = require("menubar.icon_theme")()

local lgi = require("lgi")
local gio = lgi.Gio

local os         = { execute = os.execute,
                     getenv  = os.getenv }
local pairs      = pairs
local string     = { byte    = string.byte,
                     format  = string.format }
local table      = { insert  = table.insert,
                     remove  = table.remove,
                     sort    = table.sort }

-- Remove non existent paths in order to avoid issues
local existent_paths = {}
for k, v in pairs(menu_gen.all_menu_dirs) do
    if gio.File.query_exists(gio.File.new_for_path(v)) then
        table.insert(existent_paths, v)
    end
end
menu_gen.all_menu_dirs = existent_paths

-- Expecting a wm_name of awesome omits too many applications and tools
menu_utils.wm_name = ""

-- Menu
local xdg_menu = {}

-- Use MenuBar parsing utils to build a menu for Awesome
-- @return awful.menu
function xdg_menu.build(args)
    local args      = args or {}
    local icon_size = args.icon_size
    local width     = args.width
    local before    = args.before or {}
    local after     = args.after or {}

    local result = {}
    local _menu  = awful_menu({ items = before, width = width })

    menu_gen.generate(function(entries)
        -- Add category icons
        for k, v in pairs(menu_gen.all_categories) do
            table.insert(result, { k, {}, v.icon })
        end

        -- Get items table
        for k, v in pairs(entries) do
            for _, cat in pairs(result) do
                if cat[1] == v.category then
                    table.insert(cat[2], { v.name, v.cmdline, v.icon })
                    break
                end
            end
        end

        -- Cleanup things a bit
        for i = #result, 1, -1 do
            local v = result[i]
            if #v[2] == 0 then
                -- Remove unused categories
                table.remove(result, i)
            else
                --Sort entries alphabetically (by name)
                table.sort(v[2], function (a, b) return string.byte(a[1]) < string.byte(b[1]) end)
                -- Replace category name with nice name
                v[1] = menu_gen.all_categories[v[1]].name
            end
        end

        -- Sort categories alphabetically also
        table.sort(result, function(a, b) return string.byte(a[1]) < string.byte(b[1]) end)

        -- Add items to menu
        for _, v in pairs(result) do _menu:add(v) end
        for _, v in pairs(after)  do _menu:add(v) end
    end)

    -- Set icon size
    if icon_size then
        for _,v in pairs(menu_gen.all_categories) do
            v.icon = icon_theme:find_icon_path(v.icon_name, icon_size)
        end
    end

    return _menu
end

return xdg_menu
