local thumbnailers = {
    epub = "gnome-epub-thumbnailer",
    mobi = "gnome-mobi-thumbnailer",
    papers = "papers-thumbnailer"
}

local M = {}

function M:peek(job)
    local start, cache = os.clock(), ya.file_cache(job)
    if not cache then
        return
    end

    local ok, err = self:preload(job)
    if not ok or err then
        return ya.preview_widget(job, err)
    end

    ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

    local _, err = ya.image_show(cache, job.area)
    ya.preview_widget(job, err)
end

function M:seek() end

function M:preload(job)
    local cache = ya.file_cache(job)
    if not cache or fs.cha(cache) then
        return true
    end

    -- Required to fulfill AppArmor restrictions for papers
    local temp_file = "/tmp/gnome-desktop-yazi-" .. tostring(math.random())

    -- stylua: ignore
    local output, err = Command(thumbnailers[job.args[1]])
        :arg({
            "-s", "560",
            tostring(job.file.url),
            temp_file,
        })
        :stderr(Command.PIPED)
        :output()

    if not output then
        return true, Err("Failed to start thumbnailer, error: %s", err)
    elseif not output.status.success then
        return true, Err("Failed to convert document to image, stderr: %s", output.stderr)
    end

    local ok, err = os.rename(temp_file, tostring(cache))
    if ok then
        return true
    else
        return false, Err("Failed to rename `%s` to `%s`, error: %s", temp_file, cache, err)
    end
end

return M
