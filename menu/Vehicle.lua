-- Utility
local function IsPlayerInVehicle()
	local plyId = GetLocalPlayerEntityId()
	return GetCurrentVehicleEntityId(plyId) ~= GetInvalidEntityId() 
end

-- Spawn Vehicle
Script().WarpIntoSpawnedVehicles = true

local function SpawnVehicleInternal(archetype)
	local pos = GetReticleHitLocation()
	if pos[1] == 0 or pos[2] == 0 or pos[3] == 0 then
		ScriptHook.ShowNotification(15, "Failed to spawn entity", "The selected spawn position is invalid or too far away")
		return nil
	end

	local veh = SpawnEntityFromArchetype(archetype, pos[1], pos[2], pos[3], 0, 0, 0)
	if veh == GetInvalidEntityId() then
		ScriptHook.ShowNotification(15, "Failed to spawn entity", "Entity archetype " .. archetype .. " is invalid or not spawnable")
		return nil
	end

	return veh
end

local vehiclesSpawnCounter = 0
local function SpawnVehicle(menu, text, archetype, id)
	local veh = SpawnVehicleInternal(archetype)
	if veh == nil then
		return
	end
	
	SetVehicleLockState(veh, 1)

	if Script().WarpIntoSpawnedVehicles then
		ScriptHook.PutPlayerInVehicleDelayed(veh, 200)
	end
	
	vehiclesSpawnCounter = vehiclesSpawnCounter + 1
	if not timer.Get("vehiclesSpawnTimer") then
		timer.Create("vehiclesSpawnTimer", 3, 1, function()
			if vehiclesSpawnCounter > 1 then
				ScriptHook.ShowNotification(1, tostring(vehiclesSpawnCounter) .. " vehicles spawned", "")
			else
				ScriptHook.ShowNotification(1, "Vehicle spawned", "")
			end
			vehiclesSpawnCounter = 0
		end)
	end
end

local VehicleLibrary_Categories = {
	{ "Drones", VehicleLibrary["Drones"] },
	{ "WheeledVehicles", VehicleLibrary["WheeledVehicles"] },
	{ "Boats", VehicleLibrary["Boats"] },
	{ "MotorCycles", VehicleLibrary["MotorCycles"] },
	{ "RC", VehicleLibrary["RC"] },
	{ "LiftRC", VehicleLibrary["LiftRC"] }
}

local function OpenVehicleCategoryMenu(title, tbl)
	local menu = UI.SimpleMenu()
	menu:SetTitle(title)
	menu:AddSearch("Search", "Start typing to filter")

	for k,v in pairsByKeys(tbl) do
		menu:AddButton(k, v, SpawnVehicle)
	end

	return menu
end

local function SpawnVehicleMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Spawn Vehicle")

	for _,v in pairsByKeys(VehicleLibrary_Categories) do
		local name, tbl = unpack(v)

		menu:AddButton(name, Script():CacheMenu(function()
			return OpenVehicleCategoryMenu(name, tbl)
		end))
	end

	return menu
end

-- Repair
local function RepairVehicle()
	if not IsPlayerInVehicle() then
		ScriptHook.ShowNotification(15, "Vehicle Repair Failed", "You do not seem to be in a vehicle")
		return
	end

	local plyId = GetLocalPlayerEntityId()
	local vehId = GetCurrentVehicleEntityId(plyId) 

	ScriptHook.RepairVehicle(vehId)
	ScriptHook.ShowNotification(1, "Vehicle Repair Successful", "")
end

-- God
local function VehicleSetGod(on)
	if not IsPlayerInVehicle() then
		return
	end

	local plyId = GetLocalPlayerEntityId()
	local vehId = GetCurrentVehicleEntityId(plyId)

	if on then
		CDominoManager_GetInstance():SendRegisteredEventToEntity(vehId, "CVehicle", "SetAsIndestructable")
		ScriptHook.ShowNotification(1, "Vehicle God Mode", "ON")
	else
		CDominoManager_GetInstance():SendRegisteredEventToEntity(vehId, "CVehicle", "SetAsDestructable")
		ScriptHook.ShowNotification(1, "Vehicle God Mode", "OFF")
	end
end

local script = Script()
script.RewarpVehicleEntityId = nil

local function LocalVehiclePaintJobMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Vehicle Paint Job")

	for k,v in pairsByKeys(VehicleMaterialOverrideIds) do
		menu:AddButton(k, function()
			local plyId = GetLocalPlayerEntityId()
			local vehId = GetCurrentVehicleEntityId(plyId) 

			script.RewarpVehicleEntityId = vehId
			ScriptHook.SetVehicleMaterialOverride(vehId, VehicleMaterialOverrideIds[k])
		end)
	end
	
	return menu
end

local function LocalVehicleMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Vehicle")

	local repairIdx = menu:AddButton("Repair", RepairVehicle)
	local licenseIdx = menu:AddButton("License Plate", function()
		UI.SimpleTextInput("License Plate", function(success, text)
			if success then
				local plyId = GetLocalPlayerEntityId()
				local vehId = GetCurrentVehicleEntityId(plyId) 
				
				ScriptHook.SetVehicleLicensePlateText(vehId, text)
			end
		end, "Maximum 7 Characters", 7)
	end)

	menu:AddButton("Paint Job", Script():CacheMenu(LocalVehiclePaintJobMenu))

	return menu
end

-- Vehicle
local function VehicleMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Vehicle")

	-- Items
	local warpIdx = menu:AddCheckbox("Warp into Spawned Vehicles", function(menu, text, hint, idx, enabled)
		Script().WarpIntoSpawnedVehicles = enabled
	end)
	
	menu:AddButton("Spawn", "Spawn vehicle", Script():CacheMenu(SpawnVehicleMenu))	
	local localVehicleIdx = menu:AddButton("Local Vehicle", "Control the vehicle you are in",  Script():CacheMenu(LocalVehicleMenu))

	menu:OnUpdate(function()
		menu:SetChecked(warpIdx, Script().WarpIntoSpawnedVehicles)
		menu:SetEntryEnabled(localVehicleIdx, IsPlayerInVehicle())
	end)

	return menu
end

function script:ProcessVehicleMenuGameUpdate(time, dt)
	if script.RewarpVehicleEntityId ~= nil and script.RewarpVehicleEntityId ~= GetInvalidEntityId() then
		--local plyId = GetLocalPlayerEntityId()
		--local vehId = GetCurrentVehicleEntityId(plyId) 
		--if vehId == nil then
			local isAddedToWorld = ScriptHook.IsEntityAddedToWorld(script.RewarpVehicleEntityId)
			local isInitialized = ScriptHook.IsEntityInitialized(script.RewarpVehicleEntityId)
			local isLoaded = ScriptHook.IsEntityLoaded(script.RewarpVehicleEntityId)
			if isAddedToWorld == true and isInitialized == true and isLoaded == true then
				ScriptHook.PutPlayerInVehicleDelayed(script.RewarpVehicleEntityId, 1000)
				script.RewarpVehicleEntityId = nil
			end
		--else
			--script.RewarpVehicleEntityId = nil
		--end
	end
end

table.insert(SimpleTrainerMenuItems, { "Vehicle", "Spawn vehicles, modify them", Script():CacheMenu(VehicleMenu) })