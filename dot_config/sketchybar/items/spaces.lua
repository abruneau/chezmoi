local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local item_order = ""
local spaces = {}

local workspace_state_cmd = "aerospace list-workspaces --all --format 'W|%{workspace}|%{monitor-appkit-nsscreen-screens-id}';"
  .. " aerospace list-windows --all --format 'A|%{workspace}|%{app-name}';"
  .. " aerospace list-workspaces --focused --format 'F|%{workspace}'"

-- Hides empty workspaces (except the focused one) and puts each workspace on
-- its monitor's bar; aerospace's appkit screen id matches sketchybar's display id
local function refresh()
  sbar.exec(workspace_state_cmd, function(out)
    local monitors, apps, focused = {}, {}, nil
    for kind, name, value in out:gmatch("(%u)|([^|\r\n]+)|?([^\r\n]*)") do
      if kind == "W" then
        monitors[name] = value
      elseif kind == "A" then
        apps[name] = apps[name] or {}
        table.insert(apps[name], value)
      elseif kind == "F" then
        focused = name
      end
    end

    for name, space in pairs(spaces) do
      local icon_line = ""
      for _, app in ipairs(apps[name] or {}) do
        icon_line = icon_line .. " " .. (app_icons[app] or app_icons["default"])
      end
      if icon_line == "" then
        icon_line = " —"
      end

      local visible = apps[name] ~= nil or name == focused
      local display = monitors[name] or "active"
      space.item:set({ drawing = visible, display = display })
      space.padding:set({ drawing = visible, display = display })
      sbar.animate("tanh", 10, function()
        space.item:set({ label = icon_line })
      end)
    end
  end)
end

sbar.exec("aerospace list-workspaces --all", function(workspaces)
  for space_name in workspaces:gmatch("[^\r\n]+") do
    local space = sbar.add("item", "space." .. space_name, {
      -- Hidden spaces must still receive events so they highlight when focused
      updates = true,
      icon = {
        font = { family = settings.font.numbers },
        string = string.sub(space_name, 3),
        padding_left = 7,
        padding_right = 3,
        color = colors.white,
        highlight_color = colors.red,
      },
      label = {
        padding_right = 12,
        color = colors.grey,
        highlight_color = colors.white,
        font = "sketchybar-app-font:Regular:16.0",
        y_offset = -1,
      },
      padding_right = 1,
      padding_left = 1,
      background = {
        color = colors.bg1,
        border_width = 1,
        height = 26,
        border_color = colors.black,
      }
    })

    local space_bracket = sbar.add("bracket", { space.name }, {
      background = {
        color = colors.transparent,
        border_color = colors.bg2,
        height = 28,
        border_width = 2
      }
    })

    -- Padding space
    local space_padding = sbar.add("item", "space.padding." .. space_name, {
      script = "",
      width = settings.group_paddings,
    })

    space:subscribe("aerospace_workspace_change", function(env)
      local selected = env.FOCUSED_WORKSPACE == space_name
      space:set({
        icon = { highlight = selected, },
        label = { highlight = selected },
        background = { border_color = selected and colors.black or colors.bg2 }
      })
      space_bracket:set({
        background = { border_color = selected and colors.grey or colors.bg2 }
      })
    end)

    space:subscribe("mouse.clicked", function()
      sbar.exec("aerospace workspace " .. space_name)
    end)

    spaces[space_name] = { item = space, padding = space_padding }
    item_order = item_order .. " " .. space.name .. " " .. space_padding.name
  end

  local updater = sbar.add("item", "spaces.updater", { drawing = false, updates = true })
  updater:subscribe(
    { "aerospace_workspace_change", "space_windows_change", "display_change", "system_woke" },
    refresh
  )

  sbar.exec("sketchybar --reorder apple " .. item_order .. " front_app")
  refresh()
  sbar.exec("sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)")
end)
