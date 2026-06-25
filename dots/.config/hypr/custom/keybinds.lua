-- Custom keybinds

-- Unbind default illogical impulse bindings that conflict with my custom ones
hl.unbind("SUPER + W")               -- default: browser
hl.unbind("SUPER + F")               -- default: fullscreen / or free for browser
hl.unbind("SUPER + J")               -- default: bar
hl.unbind("SUPER + B")               -- use for bar
hl.unbind("SUPER + ALT + Space")     -- default: float/tile or pin
hl.unbind("SUPER + P")               -- default: pin
hl.unbind("SUPER + X")               -- default: text editor / now resize
hl.unbind("SUPER + Return")          -- default: terminal / now fullscreen
hl.unbind("SUPER + T")               -- terminal
hl.unbind("SUPER + C")               -- code editor
hl.unbind("CTRL + SUPER + SHIFT + ALT + W") -- office software
hl.unbind("CTRL + SUPER + Slash")
hl.unbind("CTRL + SUPER + ALT + Slash")
-- Libera scorciatoie terminale
hl.unbind("CTRL + SHIFT + C")
hl.unbind("CTRL + SHIFT + V")

-- Edit shell config
hl.bind(
    "CTRL + SUPER + Slash",
    hl.dsp.exec_cmd("xdg-open ~/.config/illogical-impulse/config.json"),
    { description = "User: Edit shell config" }
)

-- Edit extra keybinds
hl.bind(
    "CTRL + SUPER + ALT + Slash",
    hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"),
    { description = "User: Edit extra keybinds" }
)

-- Cheatsheet / bar
hl.bind(
    "SUPER + H",
    hl.dsp.global("quickshell:cheatsheetToggle"),
    { description = "Shell: Toggle cheatsheet" }
)

hl.bind(
    "SUPER + B",
    hl.dsp.global("quickshell:barToggle"),
    { description = "Shell: Toggle bar" }
)

-- Window
hl.bind(
    "SUPER + Z",
    hl.dsp.window.drag(),
    { mouse = true, description = "Window: Move" }
)

hl.bind(
    "SUPER + X",
    hl.dsp.window.resize(),
    { mouse = true, description = "Window: Resize" }
)

-- Window split ratio
hl.bind(
    "SUPER + J",
    hl.dsp.layout("togglesplit"),
    { description = "Window: Toggle split" }
)

-- Positioning mode
hl.bind(
    "SUPER + W",
    hl.dsp.window.float({ action = "toggle" }),
    { description = "Window: Float/Tile" }
)

hl.bind(
    "SUPER + Return",
    hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
    { description = "Window: Fullscreen" }
)

hl.bind(
    "SUPER + ALT + Space",
    hl.dsp.window.pin(),
    { description = "Window: Pin" }
)

-- Send to workspace left/right
hl.bind(
    "SUPER + ALT + Right",
    hl.dsp.window.move({ workspace = "+1" }),
    { description = "Window: Send to next workspace" }
)

hl.bind(
    "SUPER + ALT + Left",
    hl.dsp.window.move({ workspace = "-1" }),
    { description = "Window: Send to previous workspace" }
)

-- Apps
hl.bind(
    "SUPER + T",
    hl.dsp.exec_cmd(terminal),
    { description = "App: Terminal" }
)

-- Browser spostato da SUPER + W a SUPER + F
hl.bind(
    "SUPER + F",
    hl.dsp.exec_cmd(browser),
    { description = "App: Browser" }
)

hl.bind(
    "SUPER + C",
    hl.dsp.exec_cmd(codeEditor),
    { description = "App: Code editor" }
)

hl.bind(
    "CTRL + SUPER + SHIFT + ALT + W",
    hl.dsp.exec_cmd(officeSoftware),
    { description = "App: Office software" }
)

-- Nota: SUPER + X ora è Resize, quindi textEditor lo sposto su SUPER + U
hl.bind(
    "SUPER + U",
    hl.dsp.exec_cmd(textEditor),
    { description = "App: Text editor" }
)
