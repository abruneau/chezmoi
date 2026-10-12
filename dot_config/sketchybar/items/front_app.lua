local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

local icon_color = colors.grey
local icon_string = "?"

-- Swift helper built from aizigao/sketchybar_apple_memu_via_swift@622bb2a
local app_menu = "$CONFIG_DIR/plugins/SketchyBarAppleMenu.app"

local front_app = sbar.add("item", "front_app", {
  display = "active",
  click_script = string.format(
    '/usr/bin/open -g "%s" --args --item-name front_app --background-color 0x%08x --border-color 0x%08x --foreground-color 0x%08x',
    app_menu, colors.popup.bg, colors.popup.border, colors.white
  ),
  icon = { drawing = false },
  label = {
    font = {
      style = settings.font.style_map["Black"],
      size = 12.0,
    },
  },
  updates = true,
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({ 
    label = {
     string = env.INFO,
    },
  })
end)
