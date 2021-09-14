local function WorldTeleportMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Teleport")

	menu:AddButton("Print position", function()
		ScriptHook.PrintPlayerPosition()
	end)

	for _,v in pairs(TeleportSpots) do
		local name, pos = unpack(v)

		menu:AddButton(name, function(menu, text, hint, index) 
			ScriptHook.ShowNotification(1, "Teleported", "To " .. text)
			ScriptHook.Teleport(pos[1], pos[2], pos[3])
		end)
	end

	return menu
end

table.insert(SimpleTrainerMenuItems, { "Teleport", "Teleport to anywhere within the world", Script():CacheMenu(WorldTeleportMenu) })