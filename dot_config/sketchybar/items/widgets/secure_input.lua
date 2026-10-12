local colors = require("colors")
local settings = require("settings")

-- Secure Input blocks global hotkeys (all aerospace bindings) while an app holds it
local secure_input = sbar.add("item", "widgets.secure_input", {
  position = "right",
  drawing = false,
  updates = true,
  update_freq = 10,
  icon = {
    string = "􀎡",
    color = colors.red,
  },
  label = {
    color = colors.red,
    font = { family = settings.font.numbers },
  },
})

local secure_input_bracket = sbar.add("bracket", "widgets.secure_input.bracket", { secure_input.name }, {
  background = {
    color = colors.bg1,
    border_color = colors.red,
    border_width = 1,
  },
  drawing = false,
})

local secure_input_padding = sbar.add("item", "widgets.secure_input.padding", {
  position = "right",
  width = settings.group_paddings,
  drawing = false,
})

local function render(app)
  local active = app ~= nil
  secure_input:set({ drawing = active, label = app or "" })
  secure_input_bracket:set({ drawing = active })
  secure_input_padding:set({ drawing = active })
end

-- Depth 1 holds IOConsoleUsers, which carries the PID; a full `ioreg -l` dump is ~15x slower
secure_input:subscribe({ "forced", "routine", "system_woke" }, function()
  sbar.exec("ioreg -l -w 0 -d 1", function(ioreg)
    local pid = ioreg:match('"kCGSSessionSecureInputPID"=(%d+)')
    if not pid then
      render(nil)
      return
    end
    sbar.exec("ps -p " .. pid .. " -o comm= | xargs basename", function(name)
      render(name:match("[^\r\n]+") or ("pid " .. pid))
    end)
  end)
end)

secure_input:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Activity Monitor'")
end)
