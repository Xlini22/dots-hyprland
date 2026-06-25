-- Put the second monitor on workspace 10 whenever it is connected.
hl.on("hyprland.start", function()
    hl.exec_cmd("$HOME/.config/hypr/custom/scripts/second-monitor-workspace.sh")
end)
