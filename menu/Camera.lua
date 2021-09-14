include("Camera.Cinematic.lua")

local function ToggleFreeCam()
	ScriptHook.SetLocalPlayerFreeCamera(not ScriptHook.HasLocalPlayerFreeCamera())
end

local function CameraMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Camera")

	menu:AddButton("Cinematic", "Create camera scenes in Cinematic mode", Script():CacheMenu(function()
		return Script():CinematicMenu()
	end))

    local freecamIdx = menu:AddCheckbox("Freecam", "Enable/Disable Freecam", ToggleFreeCam)

	-- Freecam Speed
	local speedIdx = menu:AddList("Freecam Speed", function(_,_,_,_, idx, speed)
		Script():ApplyCameraSpeed("freecam", "normal", speed)
	end)

	for _,v in pairs({ 0.5, 1, 2, 3, 5, 10, 15, 20, 25, 50, 75, 100 }) do
		menu:AddListEntry(speedIdx, tostring(v))
	end

	-- Freecam Shift Speed
	local shiftSpeedIdx = menu:AddList("Freecam Shift Speed", function(_,_,_,_, idx, speed)
		Script():ApplyCameraSpeed("freecam", "shift", speed)
	end)

	for _,v in pairs({ 5, 10, 25, 50, 75, 100, 150, 200, 250, 350, 450 }) do
		menu:AddListEntry(shiftSpeedIdx, tostring(v))
	end

	-- Persistent
	local speedData = Script():ReadCameraSpeeds("freecam")
	menu:SelectListEntryByValue(speedIdx, tostring(speedData.normal))
	menu:SelectListEntryByValue(shiftSpeedIdx, tostring(speedData.shift))
	speedData.ready = true

	-- Reset
	menu:AddButton("Reset to player", function()
		ScriptHook.ResetCamera()
	end)

	-- Camera Spots
	for _, v in pairs(CameraSpots) do
		local name, pos = unpack(v)

		menu:AddButton(name, function(menu, text, hint, index)
			ScriptHook.SetCustomCamera(pos[1], pos[2], pos[3], pos[4], pos[5], pos[6])
		end)
	end

	-- Update
	menu:OnUpdate(function()
		menu:SetChecked(freecamIdx, ScriptHook.HasLocalPlayerFreeCamera())
        menu:SetEntryEnabled(freecamIdx, not ScriptHook.HasLocalPlayerNoclip())
	end)

	return menu
end

table.insert(SimpleTrainerMenuItems, { "Camera", "Camera & UI Options", Script():CacheMenu(CameraMenu) })