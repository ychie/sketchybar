sbar.add("item", { 
	position = "right", 
	icon = {
		drawing = false
	},
	label = {
		drawing = false
	},
	padding_left = 0
})

local ssd_label = sbar.add("item", "ssd_label", {
	position = "right",
	icon = {
		drawing = false
	},
	label = {
		string = "SSD",
		width = "dynamic",
		font = {
			size = settings.font_3x
		},
		padding_left = 0
	},
	width = 0,
	y_offset = settings.layout_1x,
	padding_left = 0,
	padding_right = 0
})

local ssd_value = sbar.add("item", "ssd_value", {
	position = "right",
	icon = {
		drawing = false
	},
	label = {
		string = "??%",
		wisth = "dynamic",
		font = {
			size = settings.font_3x
		},
		padding_left = 0
	},
	background = {
		color = colors.transparent
	},
	y_offset = -settings.layout_1x,
	padding_left = 0,
	padding_right = 0
})

local ram_label = sbar.add("item", "ram_label", {
	position = "right",
	icon = {
		drawing = false
	},
	label = {
		string = "RAM",
		width = "dynamic",
		font = {
			size = settings.font_3x
		},
		padding_left = 0
	},
	width = 0,
	y_offset = settings.layout_1x,
	padding_left = 0,
	padding_right = 0
})

local ram_value = sbar.add("item", "ram_value", {
	position = "right",
	icon = {
		drawing = false
	},
	label = {
		string = "??%",
		wisth = "dynamic",
		font = {
			size = settings.font_3x
		},
		padding_left = 0
	},
	background = {
		color = colors.transparent
	},
	y_offset = -settings.layout_1x,
	padding_right = 0,
	padding_left = 0
})

local cpu_label = sbar.add("item", "cpu_label", {
	position = "right",
	icon = {
		drawing = false
	},
	label = {
		string = "CPU",
		width = "dynamic",
		font = {
			size = settings.font_3x
		},
		padding_left = 0
	},
	width = 0,
	y_offset = settings.layout_1x,
	padding_left = 0,
	padding_right = 0
})

local cpu_value = sbar.add("item", "cpu_value", {
	position = "right",
	icon = {
		drawing = false
	},
	label = {
		string = "??%",
		wisth = "dynamic",
		font = {
			size = settings.font_3x
		}
	},
	background = {
		color = colors.transparent
	},
	y_offset = -settings.layout_1x,
	padding_right = 0,
	padding_left = 0
})

local stats = sbar.add("item", "stats", {
	position = "right",
	icon = {
		string = icons.stats,
		background = {
			color = colors.orange
		},
		padding_left = settings.layout_1x - 2,
		padding_right = settings.layout_1x - 2
	},
	label = {
		drawing = false
	},
	padding_left = 0,
	padding_right = 0
})

local stats_bracket = sbar.add("bracket", "stats_bracket", {
	ssd_label.name,
	ssd_value.name, 
	ram_label.name,
	ram_value.name,
	cpu_label.name,
	cpu_value.name,
	stats.name
}, {
	drawing = true
})

stats_bracket:subscribe("stats_update", function(env)
	ssd_value:set({
		label = env.ssd .. "%"
	})
	ram_value:set({
		label = env.ram .. "%"
	})
	cpu_value:set({
		label = env.cpu .. "%"
	})
end)


