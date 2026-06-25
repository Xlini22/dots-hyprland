-- Custom rules
-- Window/layer rules: https://wiki.hyprland.org/Configuring/Window-Rules/
-- Workspace rules: https://wiki.hyprland.org/Configuring/Workspace-Rules/

-- vscode-debug
hl.window_rule({
    name = "vscode-debug",
    match = {
        title = "^(vscode-debug)$"
    },
    float = true,
    center = true,
    size = { 1100, 600 }
})

-- Image/video viewers floating
hl.window_rule({
    match = {
        class = "^(viewnior)$"
    },
    float = true,
    center = true
})

hl.window_rule({
    match = {
        class = "^(mpv)$"
    },
    float = true,
    center = true
})

hl.window_rule({
    match = {
        class = "^(org.gnome.Loupe)$"
    },
    float = true,
    center = true
})

-- Steam - Lista amici
hl.window_rule({
    match = {
        class = "^(steam)$",
        title = "^(Lista amici)$"
    },
    float = true,
    size = { 389, 1023 },
    move = { 1525, 51 }
})

-- Discord floating
hl.window_rule({
    match = {
        class = "^(com.discordapp.Discord)$"
    },
    float = true,
    size = { 1452, 944 },
    center = true
})

-- KCalc floating
hl.window_rule({
    match = {
        class = "^(org.kde.kcalc)$"
    },
    float = true,
    size = { 966, 617 },
    center = true
})
