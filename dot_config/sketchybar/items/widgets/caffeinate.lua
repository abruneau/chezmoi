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

-- Matches only the instance this widget starts, not caffeinate run by other tools
local own_caffeinate = "'caffeinate -id'"

local function render(result)
    caffeinate:set({
        label = {
            string = result == "" and icons.caffeinate.off or icons.caffeinate.on
        }
    })
end

local function update_caffeinate_state()
    sbar.exec("pgrep -fx " .. own_caffeinate, render)
end

local function toggle_caffeinate()
    sbar.exec("pkill -fx " .. own_caffeinate .. " || { (caffeinate -id >/dev/null 2>&1 &); echo on; }", render)
end

caffeinate:subscribe("mouse.clicked", toggle_caffeinate)
caffeinate:subscribe("system_woke", update_caffeinate_state)
caffeinate:subscribe("system_will_sleep", update_caffeinate_state)

-- Initial state
update_caffeinate_state()

