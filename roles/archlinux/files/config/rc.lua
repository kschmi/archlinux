-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local scratch = require("scratch")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local common  = require("awful.widget.common")
-- alttab = require("alttab")
require("awful.hotkeys_popup.keys")

local test_keys = {
    ["Vim"] = {
        modifiers = { "Mod1" },
        keys = {
            c = "Copy",
            v = "Paste"
        }
    }
}
hotkeys_popup.add_hotkeys(test_keys)

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- Calendar widget


-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init("/usr/share/awesome/themes/kschmi/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "roxterm"
editor = os.getenv("EDITOR") or "vi"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
--tags = {}
--for s = 1, screen.count() do
--    -- Each screen has its own tag table.
--    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
--end

tags = {
         settings = {
             {
                 name   = { ""       , ""        ,""        ,""        ,""        ,""        ,""         },
                 layout = { layouts[2], layouts[12], layouts[2], layouts[1], layouts[1], layouts[1], layouts[1] }
             },
             {
                 name   = { ""             , ""               , ""               , ""           ,""        , ""       , ""       , ""       , ""        },
                 layout = { layouts[1]      , layouts[4]        , layouts[1]        , layouts[1]    , layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] }
             }
         }
       }

for s =1, screen.count() do
    tags[s] = awful.tag(tags.settings[s].name, s, tags.settings[s].layout)
end
-- }}}

awful.util.spawn_with_shell("xcompmgr &")
awful.util.spawn_with_shell("xscreensaver -no-splash &")

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit },
   { "Gedit", "gedit .config/awesome/rc.lua" },
}

-- mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal },
                                    { "Monitor Conf", "arandr" },
                                    { "Screenshots", "shutter" },
                                    { "Wireshark", "wireshark" },
                                    { "Wireshark", "wireshark" }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Battery Widget
batteryicon = wibox.widget.imagebox()
batterywidget = wibox.widget.textbox()
batterytooltip = awful.tooltip({ objects = {} })
batterywidget:set_text(" | Battery | ")
batterywidgettimer = timer({ timeout = 5 })
batterywidgettimer:connect_signal("timeout",
  function()
    fd = io.popen("acpi -a | cut -d' ' -f 3", "r")
    status = fd:read("*l")
    io.close(fd)

    fh = assert(io.popen("acpi | cut -d, -f 2 - | sed 's/%//'", "r"))
    percentage = tonumber(fh:read("*l"))
    fh:close()

    fp = assert(io.popen("acpi | cut -d, -f 3 -", "r"))
    remaining = fp:read("*l")
    fp:close()

    batterytooltip:add_to_object(batterywidget)
    batterytooltip:add_to_object(batteryicon)

    if percentage >= 90 then
        capacity = "full"
        color = "green"
    elseif percentage >= 30 then
        capacity = "good"
        color = "lightblue"
    else
        capacity = "low"
        color = "red"
    end

    if string.find(status,"on") then
        if percentage >= 100 then
            state = "-charged"
            batterytooltip:remove_from_object(batterywidget)
            batterytooltip:remove_from_object(batteryicon)
        else
            state = "-charging"
        end
    else
        state = ""
    end

    batteryicon:set_image(awful.util.getdir("config") .. "/battery-" .. capacity .. state .. ".png")
    batterywidget:set_markup("<span color='" .. color .. "'>" .. percentage .. "%</span>")
    batterytooltip:set_text("\n  " .. remaining .. "  \n")

  end
)
batterywidgettimer:start()

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock(" %a %b %d, %H:%M:%S ",1)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mymargin = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

function list_update(w, buttons, label, data, objects)
    -- call default widget drawing function
    common.list_update(w, buttons, label, data, objects)
    -- set widget size
    w:set_max_widget_size(100)
end
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons,nil,list_update)
    -- Create the wibox
    mywibox[s] = awful.wibox({
        position = "top",
        screen = s,
        -- height = 40,
     })
    -- mywibox[s].border_color = "#00968800"
    -- mywibox[s].border_width = 1

    mylaunchermargin = wibox.container.margin(mylauncher)

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylaunchermargin)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])


    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
        right_layout:add(wibox.widget.systray())
	    right_layout:add(batteryicon)
	    right_layout:add(batterywidget)
    end
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    -- Margin container wrapping the layout widget
    mymargin[s] = wibox.container.margin(layout)
    mymargin[s].bottom = beautiful.border_width
    mymargin[s].color = beautiful.border_focus

    mywibox[s]:set_widget(mymargin[s])
    mywibox[s].opacity = 0.9
    mylaunchermargin.margins = 4
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey,           }, "F1",    function () awful.screen.focus(1)         end),
    awful.key({ modkey,           }, "F2",    function () awful.screen.focus(2)         end),
    awful.key({ modkey, "Control" }, "l",
        function ()
            awful.util.spawn("xscreensaver-command -lock")
        end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),
    awful.key({ modkey, "Mod1"     }, "a", function () awful.util.spawn_with_shell("mono /opt/KeePass2/KeePass.exe --auto-type") end),
    awful.key({ modkey, "Mod1"     }, "s", function () awful.util.spawn_with_shell("mono /opt/KeePass2/KeePass.exe --show") end),
    --awful.key({ modkey, "Mod1"     }, "a", function () awful.util.spawn_with_shell("echo 'test' >> /home/kschmi/test.txt") end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),

    -- Alt-Tab
    -- awful.key({ "Mod1",}, "Tab",
    --        function ()
    --           alttab.switch(1, "Alt_L", "Tab", "ISO_Left_Tab")
    --        end
    --    ),

    awful.key({ "Mod1", "Shift" }, "Tab",
        function ()
           alttab.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab")
        end
    ),
    awful.key({ }, "XF86AudioRaiseVolume", function ()
        awful.util.spawn("audio up") end),
    awful.key({ }, "XF86AudioLowerVolume", function ()
        awful.util.spawn("audio down") end),
    awful.key({ }, "XF86AudioMute", function ()
        awful.util.spawn("audio off") end),
    awful.key({ modkey }, "c", function ()
        scratch.drop("galculator", "top", "center", "250", "250", true) end),
        --scratch.drop("roxterm", "top", "center", "100%", "500", true) end)
    awful.key({ modkey,}, "i", hotkeys_popup.show_help)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "g",      function (c) c.maximized = not c.maximized            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
    { rule = { class = "XTerm" },
      properties = {
          opacity = 1,
          size_hints_honor = false } }, -- Ignore WM_NORMAL_HINTS resize hints
    { rule = { class = "Gnome-terminal" },
      properties = {
          floating= true, size_hints_honor = false } }, -- Ignore WM_NORMAL_HINTS resize hints
    { rule = { class = "KeePass2" },
      properties = { floating = true } },
    { rule = { class = "Main.py" },
      properties = { floating = true } },
    { rule = { class = "Roxterm" },
      properties = {
          opacity = 0.9,
          maximized_horizontal = false,
          height = 600,
          width = 1200,
          size_hints_honor = false,
          honor_padding = false,
          floating = false,
      }
    },
    { rule = { class = "Atom" },    properties = { opacity = 0.9 } },
    { rule = { class = "Slack" },   properties = { opacity = 0.8 } },
    { rule = { class = "HipChat" }, properties = { opacity = 0.8 } },
    { rule = { name = "WhatsApp" }, properties = { opacity = 0.8 } },
    { rule = { class = "Nm-connection-editor" }, properties = { floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
--

awful.util.spawn("run_once nm-applet") -- networkManager applet
awful.util.spawn("dropbox start") -- Dropbox
awful.util.spawn("run_once pasystray") -- Sound Control

naughty.config.defaults.position = "top_right"
naughty.config.defaults.icon_size = 32
naughty.config.defaults.timeout = 5
naughty.config.defaults.hover_timeout = 10

awful.tag.incmwfact(0.10,awful.tag:find_by_name(''))
awful.tag.incmwfact(0.15,awful.tag:find_by_name("3"))
