-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples
-- Put general config stuff here
-- Hyprland Lua config

hl.gesture({
    fingers = 4,
    direction = "swipe",
    action = "move"
})

hl.gesture({
    fingers = 4,
    direction = "pinch",
    action = "float"
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

hl.gesture({
    fingers = 3,
    direction = "up",
    action = function()
        hl.dispatch(hl.dsp.global("quickshell:overviewWorkspacesToggle"))
    end
})

hl.gesture({
    fingers = 3,
    direction = "down",
    action = function()
        hl.dispatch(hl.dsp.global("quickshell:overviewWorkspacesClose"))
    end
})

local default_gesture = hl.gesture
local skipped_default_gestures = {
    ["4:horizontal"] = true,
    ["4:up"] = true,
    ["4:down"] = true,
}

hl.gesture = function(gesture)
    local key = tostring(gesture.fingers) .. ":" .. tostring(gesture.direction)
    if skipped_default_gestures[key] then
        return
    end

    return default_gesture(gesture)
end
