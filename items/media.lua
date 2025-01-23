sbar.add("item", { 
	position = "center", 
	icon = {
		drawing = false
	},
	label = {
		drawing = false
	},
	padding_left = 0
})

local media_control = sbar.add("item", "media_control", {
	position = "center",
	icon = {
		string = icons.media.pause,
		background = {
			color = colors.red
		},
		padding_left = settings.layout_1x + 2,
		padding_right = settings.layout_1x + 2
	},
	label = {
		drawing = false
	},
	padding_left = 0,
	padding_right = 0
})

local media_title = sbar.add("item", "media_title", {
	position = "center",
	label = {
		align = "left",
		width = 0,
		y_offset = -settings.layout_1x, 
		max_chars = 15,
		font = {
			size = settings.font_3x
		}
	},
	icon = {
		drawing = false
	},
	width = 0,
	padding_left = 0,
	padding_right = 0
})

local media_author = sbar.add("item", "media_author", {
	position = "center",
	label = {
		align = "left",
		width = 0,
		y_offset = settings.layout_1x,
		max_chars = 15,
		font = {
			size = settings.font_3x
		}
	},
	icon = {
		drawing = false
	},
	width = 0,
	padding_left = 0,
	padding_right = 0
})

local media_bracket = sbar.add("bracket", "media_bracket", {
	media_control.name,
	media_title.name,
	media_author.name
}, {
	drawing = true
})

media_bracket:subscribe("media_update_is_playing", function(env)
	local is_playing = env.is_playing == "true"
	media_control:set({
		icon = is_playing and icons.media.pause or icons.media.play
	})
end)

local interrupt_content = 0

local function animate_content(show)
	if (not show) then interrupt_content = interrupt_content - 1 end
	if interrupt_content > 0 and (not show) then return end

	sbar.animate("tanh", 30, function()
		media_title:set({
			label = {
				width = show and "dynamic" or 0
			}
		})
		media_author:set({
			label = {
				width = show and "dynamic" or 0
			}
		})
	end)
end

media_bracket:subscribe("media_update_content", function(env)
	local has_title = not (env.title == "")
	local has_author = not (env.author == "")
	local has_content = has_title or has_author

	media_title:set({
		label = {
			string = env.title,
			y_offset = has_author and -settings.layout_1x or 0
		}
	})

	media_author:set({
		label = {
			string = env.author,
			y_offset = has_title and settings.layout_1x or 0,
		}
	})

	if has_content then
		animate_content(true)
		interrupt_content = interrupt_content + 1
		sbar.delay(15, function()
			animate_content(false)
		end)
	end
end)

media_control:subscribe("mouse.entered", function(env)
	interrupt_content = interrupt_content + 1
	animate_content(true)
end)

media_control:subscribe("mouse.exited", function(env)
	animate_content(false)
end)

media_control:subscribe("mouse.clicked", function(env)
	sbar.exec([[osascript -e 'tell application "Spotify" to playpause']])
end)

