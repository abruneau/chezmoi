local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local caffeinate = sbar.add("item", "widgets.caffeinate", {
    position = "right",
    icon = { drawing = false },
    label = {
        font = {
            family = settings.font.numbers
        },
        padding_left = 8,
        padding_right = 8,
    }
})

sbar.add("bracket", "widgets.caffeinate.bracket", {caffeinate.name}, {
    background = {
        color = colors.bg1,
    }
})

sbar.add("item", "widgets.caffeinate.padding", {
    position = "right",
    width = settings.group_paddings
})

local function update_caffeinate_state()
    sbar.exec("pmset -g assertions | grep 'caffeinate' | awk '{print $2}' | cut -d '(' -f1 | head -n 1",
        function(result)
            if result == "" then
                caffeinate:set({
                    label = {
                        string = icons.caffeinate.off
                    }
                })
            else
                caffeinate:set({
                    label = {
                        string = icons.caffeinate.on
                    }
                })
            end
        end)
end

local function toggle_caffeinate()
    sbar.exec("pmset -g assertions | grep 'caffeinate' | awk '{print $2}' | cut -d '(' -f1 | head -n 1",
        function(result)
            if result == "" then
                sbar.exec("caffeinate -id &")
                caffeinate:set({
                    label = {
                        string = icons.caffeinate.on
                    }
                })
            else
                sbar.exec("kill -9 " .. result)
                caffeinate:set({
                    label = {
                        string = icons.caffeinate.off
                    }
                })
            end
        end)
end

caffeinate:subscribe("mouse.clicked", toggle_caffeinate)
caffeinate:subscribe("system_woke", update_caffeinate_state)
caffeinate:subscribe("system_will_sleep", update_caffeinate_state)

-- Initial state
update_caffeinate_state()

