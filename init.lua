-- Require the sketchybar module
sbar = require("sketchybar")

-- Require the resources module
require("resources")

-- Bundle the entire initial configuration into a single message to sketchybar
sbar.begin_config()
require("configs")
sbar.end_config()

-- Run the event loop of the sketchybar module (without this there will be no
-- callback functions executed in the lua module)
sbar.event_loop()

