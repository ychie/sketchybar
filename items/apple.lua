local apple = sbar.add("item", "apple", {
	icon = {
		string = icons.apple,
		background = {
			color = colors.red
		}
	},
	label = {
		drawing = false
	},
	popup = {
		align = "left"
	}
})

local popup_width = 130

local sketchybar = sbar.add("item", "apple.sketchybar", {
	position = "popup." .. apple.name,
	icon = {
		align = "left",
		string = icons.reload
	},
	label = {
		align = "left",
		string = "Reload Sketchybar"
	},
	width = popup_width
})

local activity = sbar.add("item", "apple.activity", {
	position = "popup." .. apple.name,
	icon = {
		align = "left",
		string = icons.activity
	},
	label = {
		align = "left",
		string = "Activity Monitor"
	},
	width = popup_width
})

local sleep = sbar.add("item", "apple.sleep", {
	position = "popup." .. apple.name,
	icon = {
		align = "left",
		string = icons.sleep
	},
	label = {
		align = "left",
		string = "Sleep Mode"
	},
	width = popup_width
})


local function hide_details()
	apple:set({ 
		popup = {
			drawing = false
		}
	})
end

local function toggle_details()
	local should_draw = apple:query().popup.drawing == "off"

	if should_draw then
		apple:set({
			popup = {
				drawing = true
			}
		})
	else
		hide_details()
	end
end

local function reload_sketchybar()
	hide_details()
	sbar.exec("sketchybar --reload")
end

local function open_activity()
	hide_details()
	sbar.exec("open -a 'Activity Monitor'")
end

local function sleep_mode()
	hide_details()
	sbar.exec("pmset displaysleepnow")
end

apple:subscribe("mouse.clicked", toggle_details)
apple:subscribe("mouse.exited.global", hide_details)

sleep:subscribe("mouse.clicked", sleep_mode)
activity:subscribe("mouse.clicked", open_activity)
sketchybar:subscribe("mouse.clicked", reload_sketchybar)

