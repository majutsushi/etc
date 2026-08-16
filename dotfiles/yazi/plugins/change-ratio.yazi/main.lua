--- @sync entry
return {
    entry = function(st, job)
        local R = rt.mgr.ratio

        st.parent = st.parent or R[1]
        st.current = st.current or R[2]
        st.preview = st.preview or R[3]

        local parent = tonumber(job.args[1])
        local current = tonumber(job.args[2])
        local preview = tonumber(job.args[3])

        if parent ~= R[1] or current ~= R[2] or preview ~= R[3] then
            rt.mgr.ratio = { parent, current, preview }
        else
            rt.mgr.ratio = { st.parent, st.current, st.preview }
        end

        ya.emit("app:resize", {})
    end,
}
