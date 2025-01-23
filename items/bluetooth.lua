local bluetooth = sbar.add("item", "bluetooth", {
	position = "right",
	icon = {
		string = icons.bluetooth,
		background = {
			color = colors.blue
		}
	},
	label = {
		padding_left = 0,
		padding_right = 0,
		max_chars = 10,
		width = 0
	},
	popup = {
		align = "right"
	}
})

local stgs = sbar.add("item", {
	position = "popup." .. bluetooth.name,
	icon = {
		string = icons.settings,
		align = "left"
	},
	label = {
		string = "Open Settings",
		align = "left"
	},
	width = popup_width,
	padding_right = 0
})

local function hide_details()
	bluetooth:set({ 
		popup = {
			drawing = false
		}
	})
end

local function toggle_details()
	local should_draw = bluetooth:query().popup.drawing == "off"

	if should_draw then
		bluetooth:set({
			popup = {
				drawing = true
			}
		})
	else
		hide_details()
	end
end

bluetooth:subscribe("bluetooth_update", function(env)
	local enabled = env.enabled == "true"
	bluetooth:set({
		icon = { 
			background = {
				color = enabled and colors.blue or colors.bg2
			}
		}
	})
end)

bluetooth:subscribe("mouse.clicked", function(env)
	toggle_details()
end)

stgs:subscribe("mouse.clicked", function(env)
	toggle_details()
	sbar.exec([[open /System/Library/PreferencePanes/Bluetooth.prefPane]])
end)

