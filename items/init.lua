sbar.exec("killall sketchybar_events >/dev/null; $HOME/.config/sketchybar/helpers/events/bin/sketchybar_events")

-- left
require("items.apple")
require("items.spaces")

-- center
require("items.calendar")
require("items.media")

-- right
require("items.power")
require("items.network")
require("items.bluetooth")
require("items.stats")

