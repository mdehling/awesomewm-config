--
-- Theme
--
theme = {}

local gears = require("gears")
local beautiful = require("beautiful")


beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.font = "DejaVu Sans Mono 9"
beautiful.wallpaper = nil


function theme.set_wallpaper(s)
    if beautiful.wallpaper then
        gears.wallpaper.centered(beautiful.wallpaper, s, "black")
    else
        gears.wallpaper.set("black")
    end
end


return theme
