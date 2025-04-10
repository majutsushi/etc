local M = {}

function M:peek(job)
    local dotfiles = os.getenv("DOTFILES")
    local child = Command(dotfiles .. "/less/lessfilter")
        :args({
            tostring(job.file.url),
        })
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :spawn()

    if not child then
        return self:print_error(job)
    end

    local limit = job.area.h
    local i, lines = 0, ""
    repeat
        local next, event = child:read_line()
        if event == 2 then
            break
        end

        i = i + 1
        if i > job.skip then
            lines = lines .. next
        end
    until i >= job.skip + limit

    child:start_kill()
    if job.skip > 0 and i < job.skip + limit then
        ya.manager_emit("peek", { math.max(0, i - limit), only_if = tostring(job.file.url), upper_bound = true })
    else
        lines = lines:gsub("\t", string.rep(" ", rt.preview.tab_size))
        ya.preview_widgets(job, { ui.Text.parse(lines):area(job.area):wrap(rt.preview.wrap == "yes" and ui.Text.WRAP or ui.Text.WRAP_NO) })
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

function M:print_error(job)
    p = ui.Text({
        ui.Line {
            ui.Span("Failed to spawn `lessfilter` command"),
        },
    }):area(job.area)

    ya.preview_widgets(job, { p:wrap(ui.Text.WRAP) })
end

return M
