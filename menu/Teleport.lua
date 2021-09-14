local script = Script()
local SavedPos = {}
local PrevPos = {}

local function TeleportBack()
	if (PrevPos.x ~= nil) then
		ScriptHook.Teleport(PrevPos.x, PrevPos.y, PrevPos.z)
		ScriptHook.ShowNotification(1, "Teleported", "Back")
		PrevPos = {}
	end
end

local function TeleportSaved()
	local entityId = GetLocalPlayerEntityId()
	PrevPos.x = GetEntityPosition(entityId, 0)
	PrevPos.y = GetEntityPosition(entityId, 1)
	PrevPos.z = GetEntityPosition(entityId, 2)
	ScriptHook.Teleport(SavedPos.x, SavedPos.y, SavedPos.z)
	ScriptHook.ShowNotification(1, "Teleported", "To X: " .. tostring(SavedPos.x) .. " Y: " .. tostring(SavedPos.y) .. " Z: " .. tostring(SavedPos.z))
end

local function WorldTeleportMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Teleport")

	local saveButton = menu:AddButton("Save position", function()
		local entityId = GetLocalPlayerEntityId()
		SavedPos.x = GetEntityPosition(entityId, 0)
		SavedPos.y = GetEntityPosition(entityId, 1)
		SavedPos.z = GetEntityPosition(entityId, 2)
		ScriptHook.ShowNotification(1, "Saved", "Position")
	end)
	
	local savedButton = menu:AddButton("Teleport to saved", "Teleport to the saved position", TeleportSaved)
	local returnButton = menu:AddButton("Teleport back", TeleportBack)

	for _,v in pairs(TeleportSpots) do
		local name, pos = unpack(v)
		menu:AddButton(name, function(menu, text, hint, index)
			local entityId = GetLocalPlayerEntityId()
			PrevPos.x = GetEntityPosition(entityId, 0)
			PrevPos.y = GetEntityPosition(entityId, 1)
			PrevPos.z = GetEntityPosition(entityId, 2)
			ScriptHook.ShowNotification(1, "Teleported", "To " .. text)
			ScriptHook.Teleport(pos[1], pos[2], pos[3])
		end)
	end
	
	menu:OnUpdate(function()
		menu:SetEntryEnabled(returnButton, (PrevPos.x ~= nil))
		menu:SetEntryEnabled(savedButton, (SavedPos.x ~= nil))
	end)

	return menu
end

table.insert(SimpleTrainerMenuItems, { "Teleport", "Teleport to anywhere within the world", Script():CacheMenu(WorldTeleportMenu) })