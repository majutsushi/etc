local M = {}

function M:peek(job)
    -- Temporarily change 'skip' as it is used as part of the cache hash
    -- See https://github.com/sxyazi/yazi/issues/2531
    local offset = job.skip or 0
    job.skip = 0
    local cache = ya.file_cache(job)
    job.skip = offset
    if not cache then
        return
    end

    local ok, err = self:preload(job)
    if not ok or err then
        return ya.preview_widget(job, err)
    end

    local limit = job.area.h
    local i, lines = 0, ""
    for line in io.lines(tostring(cache)) do
        i = i + 1
        if i > job.skip + limit then
            break
        end
        if i > job.skip then
            lines = lines .. line .. "\n"
        end
    end

    if job.skip > 0 and i < job.skip + limit then
        ya.emit("peek", { math.max(0, i - limit), only_if = job.file.url, upper_bound = true })
    else
        lines = lines:gsub("\t", string.rep(" ", rt.preview.tab_size))
        ya.preview_widget(job, { ui.Text.parse(lines):area(job.area):wrap(rt.preview.wrap == "yes" and ui.Text.WRAP or ui.Text.WRAP_NO) })
    end
end

function M:seek(job)
    local h = cx.active.current.hovered
    if h and h.url == job.file.url then
        local step = math.floor(job.units * job.area.h / 10)
        ya.manager_emit("peek", {
            math.max(0, cx.active.preview.skip + step),
            only_if = tostring(job.file.url),
        })
    end
end

function M:preload(job)
    local offset = job.skip or 0
    job.skip = 0
    local cache = ya.file_cache(job)
    job.skip = offset
    if not cache or fs.cha(cache) then
        return true
    end

    local dotfiles = os.getenv("DOTFILES")

    -- stylua: ignore
    local output, err = Command(dotfiles .. "/less/lessfilter")
        :arg({
            tostring(job.file.url),
        })
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :output()

    if not output then
        return true, Err("Failed to start `lessfilter`, error: %s", err)
    elseif not output.status.success then
        return true, Err("Failed to run `lessfilter`, stderr: %s", output.stderr)
    end

    local ok, err = fs.write(cache, output.stdout)
    if ok then
        return true
    else
        return false, Err("Failed to lessfilter output to `%s`, error: %s", cache, err)
    end
end

return M
