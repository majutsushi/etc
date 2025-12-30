--- @sync entry
return {
    entry = function()
        if #cx.tabs > 1 then
            ya.mgr_emit("close", {})
            return
        end
        ya.mgr_emit("quit", { no_cwd_file = true })
    end,
}
