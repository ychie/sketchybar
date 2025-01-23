sbar.default({
	updates = "when_shown",
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = settings.font_4x
		},
		background = {
			height = settings.layout_4x
		},
		color = colors.white,
		padding_left = settings.layout_1x,
		padding_right = settings.layout_1x,
	},
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = settings.font_3x
		},
		color = colors.white,
		padding_left = settings.layout_1x,
		padding_right = settings.layout_1x
	},
	background = {
		height = settings.layout_4x,
		color = colors.bg1
	},
	padding_right = 4,
	padding_left = 4,
	scroll_texts = true
})
