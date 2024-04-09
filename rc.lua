local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

require("awful.autofocus")

local theme = require("theme")
local battery = require("battery")
local media = require("media")


local modkey = "Mod4"

local terminal = os.getenv("TERMINAL") or "xterm"


awful.layout.layouts = {
    awful.layout.suit.max,
    awful.layout.suit.tile,
    awful.layout.suit.floating,
}


local mysystray = wibox.widget.systray()
local mybattery = battery()
local myseparator = wibox.widget.textbox("|")
local mytextclock = wibox.widget.textclock()


local taglist_buttons = gears.table.join(
    awful.button({        }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1,
        function(t) if client.focus then client.focus:move_to_tag(t) end end),
    awful.button({        }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3,
        function(t) if client.focus then client.focus:toggle_tag(t) end end)
)


local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", {raise = true})
        end
    end)
)


local layoutbox_buttons = gears.table.join(
    awful.button({ }, 1, function () awful.layout.inc( 1) end),
    awful.button({ }, 3, function () awful.layout.inc(-1) end)
)


screen.connect_signal("property::geometry", theme.set_wallpaper)


awful.screen.connect_for_each_screen(function(s)
    theme.set_wallpaper(s)

    awful.tag({"1", "2", "3", "4", "5", "6", "7", "8", "9"}, s,
        awful.layout.layouts[1])
    mytaglist = awful.widget.taglist{screen = s,
        filter = awful.widget.taglist.filter.all, buttons = taglist_buttons}
    s.mypromptbox = awful.widget.prompt()

    mytasklist = awful.widget.tasklist{screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons}

    mylayoutbox = awful.widget.layoutbox(s)
    mylayoutbox:buttons(layoutbox_buttons)

    mywibox = awful.wibar{position = "top", screen = s}
    mywibox:setup{
        { mytaglist, s.mypromptbox,
            layout = wibox.layout.fixed.horizontal },
        mytasklist,
        { mysystray, mybattery, myseparator, mytextclock, mylayoutbox,
            layout = wibox.layout.fixed.horizontal },
        layout = wibox.layout.align.horizontal
    }
end)


-- Key bindings
local globalkeys = gears.table.join(
    -- Media controls
    awful.key({}, "XF86AudioRaiseVolume", media.volume_up,
        {description = "increase volume", group = "media"}),
    awful.key({}, "XF86AudioLowerVolume", media.volume_down,
        {description = "decrease volume", group = "media"}),

    -- Tags
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
        {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
        {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
        {description = "go back", group = "tag"}),

    -- Client focus
    awful.key({ modkey,           }, "j",
        function () awful.client.focus.byidx( 1) end,
        {description = "focus next by index", group = "client"}),
    awful.key({ modkey,           }, "k",
        function () awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j",
        function () awful.screen.focus_relative( 1) end,
        {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k",
        function () awful.screen.focus_relative(-1) end,
        {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", {raise = true}
                )
            end
        end,
        {description = "restore minimized", group = "client"}),

    -- Client layout
    awful.key({ modkey, "Shift"   }, "j",
        function () awful.client.swap.byidx(  1) end,
        {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k",
        function () awful.client.swap.byidx( -1) end,
        {description = "swap with previous client by index", group = "client"}),

    -- Awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}),

    -- Layouts
    awful.key({ modkey,           }, "space",
        function () awful.layout.inc(1) end,
        {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space",
        function () awful.layout.inc(-1) end,
        {description = "select previous", group = "layout"}),

    -- Adjust layout
    awful.key({ modkey,           }, "l",
    	function () awful.tag.incmwfact(0.05) end,
        {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",
        function () awful.tag.incmwfact(-0.05) end,
        {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",
        function () awful.tag.incnmaster(1, nil, true) end,
        {description = "increase number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",
        function () awful.tag.incnmaster(-1, nil, true) end,
        {description = "decrease number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",
        function () awful.tag.incncol( 1, nil, true) end,
        {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",
        function () awful.tag.incncol(-1, nil, true) end,
        {description = "decrease the number of columns", group = "layout"}),

    -- Execute
    awful.key({ modkey }, "Return",
        function () awful.spawn(terminal) end,
        {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey }, "r",
        function () awful.screen.focused().mypromptbox:run() end,
        {description = "run prompt", group = "launcher"}),
    awful.key({ modkey }, "x",
        function ()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        {description = "lua execute prompt", group = "awesome"})
)

for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "view tag #"..i, group = "tag"}
        ),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "toggle tag #" .. i, group = "tag"}
        ),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
               end
            end,
            {description = "move focused client to tag #"..i, group = "tag"}
        ),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            {description = "toggle focused client on tag #"..i, group = "tag"}
	    )
    )
end

root.keys(globalkeys)


local clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",
        function (c) c:kill() end,
        {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",
        awful.client.floating.toggle,
        {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return",
        function (c) c:swap(awful.client.getmaster()) end,
        {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",
        function (c) c:move_to_screen() end,
        {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",
        function (c) c.ontop = not c.ontop end,
        {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c) c.minimized = true end,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            if not c.maximized then awful.titlebar.hide(c) end
            c.maximized = not c.maximized
            c:raise()
        end,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            if not c.maximized_vertical then awful.titlebar.hide(c) end
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        {description = "(un)maximize horizontally", group = "client"})
)


local clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)


awful.rules.rules = {
    {   rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap
                + awful.placement.no_offscreen,
    }   },
    {   rule_any = { type = { "dialog" } },
        properties = {
            floating = true,
    }   },
    {   rule_any = { class = { "XTerm" } },
        properties = {
            floating = true,
    }   },
    {   rule_any = { class = { "XConsole" } },
        properties = {
            floating = true,
    }   },
    {   rule_any = { class = { "mpv" } },
        properties = {
            floating = true,
    }   },
}


client.connect_signal("manage", function (c)
    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position
    then
        awful.placement.no_offscreen(c)
    end
end)


local function switch_titlebar(c)
    if c.floating and not c.maximized and not c.maximized_vertical
        and not c.requests_no_titlebar
    then
        awful.titlebar.show(c)
    else
        awful.titlebar.hide(c)
    end
end

client.connect_signal("property::floating", switch_titlebar)
client.connect_signal("property::maximized", switch_titlebar)
client.connect_signal("property::maximized_vertical", switch_titlebar)

client.connect_signal("request::titlebars", function(c)
    local titlebar_buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )
    awful.titlebar(c):setup{
        {   awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            layout = wibox.layout.fixed.horizontal },
        { { align = "center", widget = awful.titlebar.widget.titlewidget(c) },
            buttons = titlebar_buttons,
            layout = wibox.layout.flex.horizontal },
        {   awful.titlebar.widget.minimizebutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal() },
        layout = wibox.layout.align.horizontal
    }
end)

client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus",
    function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus",
    function(c) c.border_color = beautiful.border_normal end)
