--- @sync entry
return {
    entry = function()
        if #cx.tabs > 1 then
            ya.emit("close", {})
            return
        end
        ya.emit("quit", { no_cwd_file = true })
    end,
}
