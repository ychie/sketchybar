local calendar = sbar.add("item", "calendar", {
	position = "center",
	icon = {
		string = icons.calendar,
		background = {
			color = colors.blue
		}
	},
	update_freq = 30,
	click_script = "open -a 'Calendar'"
})

calendar:subscribe({ "force", "routine", "system_woke" }, function()
	calendar:set({ 
		label = os.date("%d/%b | %H:%M") 
	})
end)

