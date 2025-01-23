sbar.add("item", { 
	position = "left", 
	icon = {
		drawing = false
	},
	label = {
		drawing = false
	},
	padding_left = 0
})

local spaces = {}

local function add_space(i)
	local space = sbar.add("space", "space." .. i, {
		space = i,
		icon = {
			drawing = true,
			string = string.format("%02d", i),
			font = {
				family = settings.font.numbers,
				style = settings.font.style_map["Semibold"],
				size = settings.font_3x
			}
		},
		label = {
			drawing = false,
			padding_left = 0
		},
		background = {
			padding_left = 0,
			padding_right = 0
		}
	})

	return space
end

local function add_space_popup(space)
	return sbar.add("item", {
		position = "popup." .. space.name
	})
end

local function subscribe_to_space_events(space, space_popup)
	space:subscribe("space_change", function(env)
		local selected = env.SELECTED == "true"

		space:set({
			background = {
				color = selected and colors.bg2 or colors.bg1
			}
		})
	end)
end

for i = 1, 9 do
	local space = add_space(i)
	local popup = add_space_popup(space)

	spaces[i] = space
	subscribe_to_space_events(space, popup)
end

local space_window_observer = sbar.add("item", {
	drawing = false,
	updates = true
})

space_window_observer:subscribe("space_windows_change", function(env)
	local icon_line = ""
	local no_app = true

	for app, count in pairs(env.INFO.apps) do
		no_app = false
		local lookup = icons.apps[app]
		local icon = ((lookup == nil) and icons.apps["Default"] or lookup)
		icon = ((icon_line == "") and icon or (" " .. icon))
		icon_line = icon_line .. icon
	end

	spaces[env.INFO.space]:set({
		label = {
			drawing = not no_app,
			string = icon_line
		}
	})
end)

