local network = sbar.add("item", "network", {
	position = "right",
	icon = {
		string = icons.wifi.down,
		background = {
			color = colors.purple
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

local popup_width = 110

local ip = sbar.add("item", {
	position = "popup." .. network.name,
	icon = {
		string = icons.ip,
		align = "left"
	},
	label = {
		string = "???.???.???.???",
		align = "left"
	},
	width = popup_width,
	padding_right = 0
})

local stgs = sbar.add("item", {
	position = "popup." .. network.name,
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

local toggle = sbar.add("item", {
	position = "popup." .. network.name,
	icon = {
		string = icons.toggle,
		align = "left"
	},
	label = {
		string = "Toggle WiFi",
		align = "left"
	},
	width = popup_width,
	padding_right = 0
})

network:subscribe("network_update", function(env)
	local connected = env.connected == "true"

	network:set({
		icon = { 
			string = connected and icons.wifi.up or icons.wifi.down,
			background = {
				color = connected and colors.purple or colors.bg2
			}
		},
		label = {
			padding_left = connected and settings.layout_1x or 0,
			padding_right = connected and settings.layout_1x or 0
		}
	})

	if connected then
		sbar.exec("networksetup -getairportnetwork en0 | awk -F': ' '{print $2}'", function(result)
			network:set({ label = result })
		end)
	else
		network:set({ label = "" })
	end
end)

local function hide_details()
	network:set({ 
		popup = {
			drawing = false
		}
	})
end

local function toggle_details()
	local should_draw = network:query().popup.drawing == "off"

	if should_draw then
		network:set({
			popup = {
				drawing = true
			}
		})
		sbar.exec("ipconfig getifaddr en0", function(result)
			ip:set({ label = result })
		end)
	else
		hide_details()
	end
end

network:subscribe("mouse.clicked", function(env)
	toggle_details()
end)

local function animate_network(show)
	sbar.animate("tanh", 30, function()
		network:set({
			label = {
				width = show and "dynamic" or 0
			}
		})
	end)
end

network:subscribe("mouse.entered", function(env)
	animate_network(true)
end)

network:subscribe("mouse.exited", function(env)
	animate_network(false)
end)

toggle:subscribe("mouse.clicked", function(env)
	toggle_details()
	sbar.exec([[networksetup -setairportpower airport $(networksetup -getairportpower en0 | grep -o 'On\|Off' | grep -q '^On$' && echo "Off" || echo "On")]])
end)

stgs:subscribe("mouse.clicked", function(env)
	toggle_details()
	sbar.exec([[open /System/Library/PreferencePanes/Network.prefPane]])
end)

