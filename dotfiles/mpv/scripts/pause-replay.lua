function pause_replay()
    if mp.get_property_native("pause") == true then
        if mp.get_property("eof-reached") == "yes" then
            mp.command("seek 0 absolute")
        end
        mp.set_property("pause", "no")
    else
        mp.set_property("pause", "yes")
    end
end
mp.register_script_message("pause-replay", pause_replay)
