-- http://www.playwithlua.com/?p=64

lua_version = string.gmatch(_VERSION, "Lua ([0-9.]+)")()

local luarocks_path = os.getenv("HOME") .. "/.local/luarocks/share/lua/" .. lua_version
package.path = package.path .. ";" .. os.getenv("DOTFILES") .. "/lua/?.lua" .. ";" .. luarocks_path .. "/?.lua" .. ";" .. luarocks_path .. "/?/init.lua"
package.cpath = package.cpath .. ";" .. os.getenv("DOTFILES") .. "/lua/?.so" .. ";" .. luarocks_path .. "/?.so"

-- https://stackoverflow.com/a/34965917/102250
function prequire(...)
    local status, lib = pcall(require, ...)
    if status then return lib end
    return nil
end

inspect = prequire("inspect")


function string:split(sep)
    if sep == nil then
        sep = "%s"
    end

    local t = {}
    local i = 1

    for str in string.gmatch(self, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end

    return t
end

function string:trim()
    return (self:gsub("^%s*(.-)%s*$", "%1"))
end

function table.clone(t, deep)
    deep = deep == nil and true or deep
    local c = { }
    for k, v in pairs(t) do
        if deep and type(v) == "table" then
            c[k] = table.clone(v)
        else
            c[k] = v
        end
    end
    return c
end

function table.merge(t1, t2)
    local ret = table.clone(t1, true)

    for k, v in pairs(t2) do
        if type(v) == "table" and ret[k] and type(ret[k]) == "table" then
            ret[k] = table.merge(ret[k], v)
        else
            ret[k] = v
        end
    end

    return ret
end
