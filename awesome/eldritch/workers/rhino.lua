local rhino = {}

local function worker(format, warg)
    local f = io.popen("jps | grep -E '^[[:digit:]]+ Rhino$'")
    if f == nil then return {} end
    -- local rhinos = f:read("*all")

    local rhinos = {}

    while true do
        local line = f:read()
        if line == nil then break end
        rhinos[#rhinos + 1] = line
    end

    f:close()

    return rhinos
end

return setmetatable(rhino, { __call = function(_, ...) return worker(...) end })
