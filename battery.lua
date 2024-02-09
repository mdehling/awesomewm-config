--
-- Battery monitor widget
--
local battery = {}

local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")
local naughty = require("naughty")


local charge_symbol = { [-1] = '-', [0] = '', [1] = '+' }
setmetatable(charge_symbol, { __index = function () return '?' end })


local function new(refresh, critical)
    local refresh = refresh or 15
    local critical = critical or 10

    local widget = textbox()
    local _private = widget._private

    _private.update = function ()
        local status = { level = -1, charging = 2 }

        local handle = io.popen("batstat", "r")
        if handle then
            local output = handle:read("*all")
            -- Read (key, value) pairs from 'batstat' output.
            for k, v in string.gmatch(output, "(%a+)%s*=%s*([+-]?%d+)") do
                status[k] = tonumber(v) or status[k]
            end
            handle:close()
        end

        widget:set_markup(string.format(" %d%%%s ",
            status.level, charge_symbol[status.charging]))

        -- NOTE: Comparison with nil is an error which will stop the timer.
        if status.level < critical and status.charging < 1 then
            naughty.notify{
                preset = naughty.config.presets.critical,
                title = "Critical battery level!",
                text = "Your battery level is critically low!",
            }
        end

        return true
    end

    -- NOTE: Active timers are never garbage collected and this timer is part
    -- of a reference cycle: timer -> update -> widget -> _private -> timer.
    -- To ensure the widget can be garbage collected once it is no longer in
    -- use, this timer holds a weak reference to the update function and
    -- automatically stops itself once the update function is garbage
    -- collected. The reference cycle widget -> _private -> update -> widget
    -- can be garbage collected as soon as there are no outside references.
    _private.timer = timer.weak_start_new(refresh, _private.update)
    _private.update()

    return widget
end


setmetatable(battery, {
    __call = function(self, ...) return new(...) end,
})

return battery
