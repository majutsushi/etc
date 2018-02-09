local utils = require("eldritch.utils")

local docker = {}

local function worker(format, warg)
    local f = io.popen("docker ps --format='{{.Image}}'")

    local images = {}

    while true do
        local line = f:read()
        if line == nil then break end

        if line:find(":") then
            local data = utils.split(line, ":")

            local repo = data[1]
            local slash = repo:find("/")
            if slash then
                repo = repo:sub(slash + 1)
            end

            local tag = data[2]

            images[#images + 1] = repo .. ":" .. tag
        else
            images[#images + 1] = line
        end
    end

    f:close()

    return images
end

return setmetatable(docker, { __call = function(_, ...) return worker(...) end })
