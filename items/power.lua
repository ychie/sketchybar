local power = sbar.add("item", "power", {
	position = "right",
	icon = {
		string = icons.power,
		background = {
			color = colors.yellow
		}
	},
	label = {
		string = "?%"
	},
	update_freq = 100
})

power:subscribe({"routine", "power_source_change", "system_woke"}, function()
	sbar.exec("pmset -g batt", function(info)
		local charging, _, _ = info:find("AC Power")

		power:set({
			drawing = not charging
		})

		if charging then return end

		local found, _, charge = info:find("(%d+)%%")
		local label = "?%"

		if found then
			label = tonumber(charge) .. "%"
		end

		power:set({
			label = label
		})
	end)
end)

