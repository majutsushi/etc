--- @sync entry
return {
    entry = function(st, job)
        local R = rt.mgr.ratio

        st.parent = st.parent or R.parent
        st.current = st.current or R.current
        st.preview = st.preview or R.preview

        local parent = tonumber(job.args[1])
        local current = tonumber(job.args[2])
        local preview = tonumber(job.args[3])

        if parent ~= R.parent or current ~= R.current or preview ~= R.preview then
            rt.mgr.ratio = { parent, current, preview }
        else
            rt.mgr.ratio = { st.parent, st.current, st.preview }
        end

        ya.emit("app:resize", {})
    end,
}
