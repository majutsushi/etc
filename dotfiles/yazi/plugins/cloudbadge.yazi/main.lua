-- Based on https://github.com/yazi-rs/plugins/blob/main/git.yazi/main.lua

local add = ya.sync(function(st, cwd, changed)
    for path, badge in pairs(changed) do
        st.paths[path] = badge
    end
    ui.render()
end)

local function setup(st, opts)
    st.paths = {}

    opts = opts or {}
    opts.order = opts.order or 1500

    Linemode:children_add(function(self)
        if not self._file.in_current then
            return ""
        end
        local url = self._file.url
        local badge = st.paths[tostring(url)]
        if badge == "" then
            return ""
        else
            return ui.Line { " ", st.paths[tostring(url)] }
        end
    end, opts.order)
end

local function fetch(_, job)
    local cwd = job.files[1].url.base or job.files[1].url.parent

    local paths = {}
    for _, file in ipairs(job.files) do
        paths[#paths + 1] = tostring(file.url)
    end
    local script = os.getenv("DOTFILES") .. "/yazi/plugins/cloudbadge.yazi/get-sync-status"

    local output, err = Command(script)
        :cwd(tostring(cwd))
        :arg(paths)
        :output()
    if not output then
        return true, Err("Cannot spawn `get-sync-status` command, error: %s", err)
    end

    paths = {}
    for line in output.stdout:gmatch("[^\r\n]+") do
        local badge, path = line:match("([^\t]*)\t(.*)")
        paths[path] = badge
    end

    add(tostring(cwd), paths)

    return false
end

return { setup = setup, fetch = fetch }
