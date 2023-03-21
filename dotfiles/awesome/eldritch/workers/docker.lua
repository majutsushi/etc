local docker = {}

local function worker(format, warg)
    local f = io.popen("docker ps -q")

    local images = {}
    for line in f:lines() do images[#images + 1] = line end

    f:close()

    return images
end

return setmetatable(docker, { __call = function(_, ...) return worker(...) end })
