require("items.apple")
require("items.spaces")
require("items.front_app")
require("items.calendar")
require("items.widgets")
-- require("items.media")

-- macOS 27: a click on empty bar space raises the bar's blurred background
-- window above every item window. This invisible full-width bracket sits
-- between them and gets raised instead.
-- https://github.com/FelixKratz/SketchyBar/issues/850
sbar.add("bracket", "click_shield", { "apple.padding", "calendar.padding" }, {
  background = {
    drawing = true,
    color = 0x00000000,
    border_width = 0,
    height = 40,
  },
})