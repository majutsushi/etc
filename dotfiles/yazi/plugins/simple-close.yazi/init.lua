return {
    entry = function()
        if #cx.tabs > 1 then
            ya.manager_emit("close", {})
            return
        end
        ya.manager_emit("quit", { no_cwd_file = true })
    end,
}
