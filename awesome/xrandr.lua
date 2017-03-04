--- Separating Multiple Monitor functions as a separated module (taken from awesome wiki)

local awful   = require("awful")
local naughty = require("naughty")

-- A path to a fancy icon
local icon_path = ""

-- Get active outputs
local function outputs()
    local outputs = {}
    local xrandr = io.popen("xrandr -q --current")

    if xrandr then
        for line in xrandr:lines() do
            local output = line:match("^([%w-]+) connected ")
            if output then
                outputs[#outputs + 1] = output
            end
        end
        xrandr:close()
    end

    return outputs
end

local function arrange(out)
    -- We need to enumerate all permutations of horizontal outputs.

    local choices  = {}
    local previous = { {} }
    for i = 1, #out do
        -- Find all permutation of length 'i': we take the permutation
        -- of length 'i-1' and for each of them, we create new
        -- permutations by adding each output at the end of it if it is
        -- not already present.
        local new = {}
        for _, p in pairs(previous) do
            for _, o in pairs(out) do
                if not awful.util.table.hasitem(p, o) then
                    new[#new + 1] = awful.util.table.join(p, {o})
                end
            end
        end
        choices = awful.util.table.join(choices, new)
        previous = new
    end

    return choices
end

-- Create a command to mirror the primary display to the other ones
local function get_mirror_cmd()
    local primary_w, primary_h
    local outputs = {}
    local xrandr = io.popen("xrandr -q --current")

    if xrandr then
        for line in xrandr:lines() do
            local w, h = line:match("^[%w-]+ connected primary (%d+)x(%d+)")
            if w then
                primary_w = w
                primary_h = h
            end

            local name = line:match("^([%w-]+) connected ")
            if name then
                outputs[#outputs + 1] = name
            end
        end
        xrandr:close()
    end

    if not primary_w then
        return nil
    end

    local cmd = "xrandr"
    for _, o in pairs(outputs) do
        cmd = cmd .. " --output " .. o .. " --mode " .. primary_w .. "x" .. primary_h .. " --pos 0x0 --rotate normal"
    end

    return cmd
end

-- Build available choices
local function menu()
    local menu = {}
    local out = outputs()
    local choices = arrange(out)

    for _, choice in pairs(choices) do
        local cmd = "xrandr"
        -- Enabled outputs
        for i, o in pairs(choice) do
            cmd = cmd .. " --output " .. o .. " --auto"
            if i > 1 then
                cmd = cmd .. " --right-of " .. choice[i-1]
            end
        end
        -- Disabled outputs
        for _, o in pairs(out) do
            if not awful.util.table.hasitem(choice, o) then
                cmd = cmd .. " --output " .. o .. " --off"
            end
        end

        local label = ""
        if #choice == 1 then
            label = 'Only <span weight="bold">' .. choice[1] .. '</span>'
        else
            for i, o in pairs(choice) do
                if i > 1 then label = label .. " + " end
                label = label .. '<span weight="bold">' .. o .. '</span>'
            end
        end

        menu[#menu + 1] = { label, cmd }
    end

    if #out > 1 then
        local mirror_cmd = get_mirror_cmd()
        if mirror_cmd then
            menu[#menu + 1] = { "Mirror displays", mirror_cmd }
        end
    end

    return menu
end

-- Display xrandr notifications from choices
local state = { cid = nil }

local function naughty_destroy_callback(reason)
    if reason == naughty.notificationClosedReason.expired or
        reason == naughty.notificationClosedReason.dismissedByUser then
        local action = state.index and state.menu[state.index - 1][2]
        if action then
            awful.spawn(action, false)
            state.index = nil
        end
    end
end

local function xrandr()
    -- Build the list of choices
    if not state.index then
        state.menu = menu()
        state.index = 1
    end

    -- Select one and display the appropriate notification
    local label, action
    local next  = state.menu[state.index]
    state.index = state.index + 1

    if not next then
        label = "Keep the current configuration"
        state.index = nil
    else
        label, action = unpack(next)
    end
    state.cid = naughty.notify({ text = label,
                                 -- icon = icon_path,
                                 timeout = 5,
                                 screen = mouse.screen,
                                 replaces_id = state.cid,
                                 destroy = naughty_destroy_callback}).id
end

return {
    outputs = outputs,
    arrange = arrange,
    menu = menu,
    xrandr = xrandr
}
