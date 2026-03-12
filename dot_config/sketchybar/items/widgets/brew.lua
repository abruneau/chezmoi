local settings = require("settings")
local colors = require("colors")

local user_home = os.getenv("HOME") or ("/Users/" .. (os.getenv("USER") or ""))
local brew_bin = "/opt/homebrew/bin/brew"
local brew_outdated_cmd = "/bin/zsh -lc 'export HOME=\"" ..
user_home ..
"\"; export PATH=\"/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin\"; HOMEBREW_NO_AUTO_UPDATE=1 " ..
brew_bin .. " outdated --quiet 2>/dev/null'"

local brew = sbar.add("item", "widgets.brew", {
    position = "right",
    icon = {
        font = {
            style = settings.font.style_map["Regular"],
            size = 19.0,
        },
        string = '󰏗'
    },
    label = { font = { family = settings.font.numbers } },
    update_freq = 180,
    popup = { align = "center" }
})

local function render_bar_item(count)
    local color
    if count >= 30 and count <= 59 then
        color = colors.peach
    elseif count >= 10 and count <= 29 then
        color = colors.yellow
    elseif count >= 1 and count <= 9 then
        color = colors.white
    elseif count == 0 then
        color = colors.green
        count = "􀆅"
    end
    brew:set({ label = { string = tostring(count) }, icon = { color = color } })
end

local packages_rendered = false

local function render_popup(packages)
    if packages_rendered then
        sbar.remove('/widgets.brew.package.*/')
    end
    packages_rendered = true
    for i, package in ipairs(packages) do
        sbar.add("item", "widgets.brew.package." .. i, {
            position = "popup." .. brew.name,
            label = {
                string = package,
                width = 200,
                align = "left",
            },
            icon = {
                drawing = "off"
            },
        })
    end
end

brew:subscribe({ "routine", "forced", "brew", "brew_update" }, function(env)
    sbar.exec(brew_outdated_cmd, function(brew_info)
        local count = 0
        local packages = {}
        for line in brew_info:gmatch("[^\r\n]+") do
            if line ~= "" then
                count = count + 1
                table.insert(packages, line)
            end
        end

        render_bar_item(count)
        render_popup(packages)
    end)
end)

brew:subscribe("mouse.clicked", function()
    local drawing = brew:query().popup.drawing
    brew:set({ popup = { drawing = "toggle" } })
end)

sbar.add("bracket", "widgets.brew.bracket", { brew.name }, {
    background = { color = colors.bg1 }
})

sbar.add("item", "widgets.brew.padding", {
    position = "right",
    width = settings.group_paddings
})
