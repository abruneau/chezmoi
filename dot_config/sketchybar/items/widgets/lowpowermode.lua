local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local label = icons.error
local color = colors.orange
local modeValue = 0

local lowpowermode = sbar.add("item", "widgets.lowpowermode", {
  position = "right",
  icon = { drawing = false },
  label = { 
    font = { family = settings.font.numbers },
    string = label,
    color = color,
    padding_left = 8,
    padding_right= 8,
  },
})

local lowpowermodebracket = sbar.add("bracket", "widgets.lowpowermode.bracket", { lowpowermode.name }, {
  background = { 
    color = colors.bg1,
    border_color = color,
    border_width = 1,
  }
})

local function render(v)
  modeValue = v
  if v == 1 then
    label = icons.slow
    color = colors.green
  else
    label = icons.fast
    color = colors.red
  end
  lowpowermode:set({
    label = {
      string = label,
      color = color,
    },
  })
  lowpowermodebracket:set({
    background = {
      border_color = color,
    }
  })
end

local function refresh()
  sbar.exec("pmset -g | grep -w powermode", function(mode_info)
    local found, _, enabled = mode_info:find("(%d+)")
    if found then
      render(tonumber(enabled))
    end
  end)
end

lowpowermode:subscribe({"forced", "power_source_change", "system_woke"}, refresh)

lowpowermode:subscribe("mouse.clicked", function()
  local target = modeValue == 1 and 0 or 1
  -- Prompts for an admin password; sudo would fail silently without a TTY
  sbar.exec("osascript -e 'do shell script \"pmset -a powermode " .. target .. "\" with administrator privileges'", refresh)
end)

sbar.add("item", "widgets.lowpowermode.padding", {
  position = "right",
  width = settings.group_paddings,
})
