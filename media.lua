--
-- Media controls
--
local media = {}

local awful = require("awful")


function media.volume_up()
    awful.util.spawn("mixerctl -w outputs.master+=4")
end

function media.volume_down()
    awful.util.spawn("mixerctl -w outputs.master-=4")
end


return media
