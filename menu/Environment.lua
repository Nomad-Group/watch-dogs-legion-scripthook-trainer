-- Environment.Time
local function TimeMenu()
	local menu = UI.SimpleMenu()

	-- Title Update
	menu:OnUpdate(function()
		menu:SetTitle("Time (" .. string.format("%02d:%02d", GetTimeOfDayHour(), GetTimeOfDayMinute()) .. ")")
	end)

	-- Menu 
	menu:AddButton("+1h", "+1 Hour", function()
		SetTimeOfDayHourAndMinute(GetTimeOfDayHour() + 1, GetTimeOfDayMinute())
	end)
	menu:AddButton("-1h", "-1 Hour", function(menu, text, hint, index)
		SetTimeOfDayHourAndMinute(GetTimeOfDayHour() - 1, GetTimeOfDayMinute())
	end)

	menu:AddButton("+1m", "+1 Minute", function()
		SetTimeOfDayHourAndMinute(GetTimeOfDayHour(), GetTimeOfDayMinute() + 1)
	end)
	menu:AddButton("-1m", "-1 Minute", function(menu, text, hint, index)
		SetTimeOfDayHourAndMinute(GetTimeOfDayHour(), GetTimeOfDayMinute() - 1)
	end)

	return menu
end

local function TimeScaleMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Time Scale")

	local idx = menu:AddList("Time Scale", function(_,_,_,_, idx, val)
		SetTimeScale(tonumber(val))
	end)

	for _,v in pairs({ 0, 1, 2, 3, 5, 10, 25, 50, 100, 250, 500, 1000, 2000 }) do
		menu:AddListEntry(idx, tostring(v))
	end

	menu:AddButton("Reset", function()
		menu:SelectListEntryByValue(idx, tostring(1))
	end)

	return menu
end

local function TimeShiftMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Time Shift")

	local idx = menu:AddList("Time Shift", function(_,_,_,_, idx, val)
		ScriptHook.StartTimeShiftTransition(tonumber(val), 0.5, 1.0, 1.0)
	end)

	for _,v in pairs({ 0.1, 0.2, 0.3, 0.5, 1.0, 2.0, 5.0, 10.0 }) do
		menu:AddListEntry(idx, tostring(v))
	end

	menu:AddButton("Reset", function()
		menu:SelectListEntryByValue(idx, tostring(1.0))
	end)

	return menu
end

local function SpawnerMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("World Spawner")
	
	-- Menu 
	local idxWorldSpawner = menu:AddCheckbox("World Spawner", "Toggles if traffic is enabled", function()
		ScriptHook.SetWorldSpawnerEnabled(not ScriptHook.IsWorldSpawnerEnabled())
	end)

	local idxWorldImpostor = menu:AddCheckbox("World Impostor", "Toggles if far away (fake) traffic is enabled", function()
		ScriptHook.SetWorldImpostorEnabled(not ScriptHook.IsWorldImpostorEnabled())
	end)

	-- Update
	menu:OnUpdate(function() 
		menu:SetChecked(idxWorldSpawner, ScriptHook.IsWorldSpawnerEnabled())
		menu:SetChecked(idxWorldImpostor, ScriptHook.IsWorldImpostorEnabled())
	end)

	return menu
end

-- Environment.Weather
local function SetWeather(menu, text, name)
	PushEnvironmentWeatherOverride(WeatherIDs[name], 1)
end

local function WeatherMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Weather")
	
	for k,v in pairsByKeys(WeatherIDs) do
		menu:AddButton(k:sub(0, 48), k, SetWeather)
	end

	return menu
end

local function LoadLayer(name)
	LoadLMALayer(name, "0", 0, function()
		--print("Loaded")
	end, "")

	if Script():IsNotificationEnabled("wluSpawns") then
		ScriptHook.ShowNotification(1, "Loaded World Unit", name)
	end
end

local function UnloadLayer(name)
	UnloadLMALayer(name, function()
		--print("Unloaded")
	end, "")

	if Script():IsNotificationEnabled("wluSpawns") then
		ScriptHook.ShowNotification(1, "Unloaded World Unit", name)
	end
end

local function OpenWorldLoadingUnitCategoryItemMenu(name)
	local menu = UI.SimpleMenu()
	menu:SetTitle("WLU " .. name)

	menu:AddButton("Load", "Loads the world loading unit", function(menu, text, hint, index) 
		LoadLayer(name)
	end)

	menu:AddButton("Unload", "Unloads the world loading unit", function(menu, text, hint, index) 
		UnloadLayer(name)
	end)

	return menu
end

local function OpenWorldLoadingUnitCategoryMenu(title, tbl)
	local menu = UI.SimpleMenu()
	menu:SetTitle(title)

	local activeTable = tbl
	menu:AddButton("__Load all__", "Loads all WLUs from the category", function(menu, text, hint, index) 
		for k,v in pairsByKeys(activeTable) do
			LoadLayer(v)
		end

		if Script():IsNotificationEnabled("wluSpawns") then
			ScriptHook.ShowNotification(1, "Loaded WLUs", "For WLU category " .. title)
		end
	end)

	menu:AddButton("__Unload all__", "Unload all WLUs from the category", function(menu, text, hint, index) 
		for k,v in pairsByKeys(activeTable) do
			UnloadLayer(v)
		end

		if Script():IsNotificationEnabled("wluSpawns") then
			ScriptHook.ShowNotification(1, "Unloaded WLUs", "For WLU category " .. title)
		end
	end)

	for k,v in pairsByKeys(tbl) do
		menu:AddButton(v, Script():CacheMenu(function()
			return OpenWorldLoadingUnitCategoryItemMenu(v)
		end))
	end

	return menu
end

local WorldLoadingUnit_Categories = {
	{ "Bareknuckle", WorldLoadingUnits["Bareknuckle"] },
	{ "Story Locations", WorldLoadingUnits["Story Locations"] }
}

local function WorldLoadingUnitsMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("World Loading Units")

	local enableNotificationsSettingIdx = menu:AddCheckbox("Enable Notifications", "Toggle message window for object spawns", function()
		Script():SetNotificationEnabled("wluSpawns", not Script():IsNotificationEnabled("wluSpawns"))
	end)

	menu:SetChecked(enableNotificationsSettingIdx, Script():IsNotificationEnabled("wluSpawns"))

	for _,v in pairsByKeys(WorldLoadingUnit_Categories) do
		local name, tbl = unpack(v)

		menu:AddButton(name, Script():CacheMenu(function()
			return OpenWorldLoadingUnitCategoryMenu(name, tbl)
		end))
	end

	return menu
end

-- spawn objects
local entitiesSpawnCounter = 0
local function SpawnObject(menu, text, archetype, id)
	local pos = GetReticleHitLocation()
	if pos[1] == 0 or pos[2] == 0 or pos[3] == 0 then
		ScriptHook.ShowNotification(15, "Failed to spawn entity", "The selected spawn position is invalid or too far away")
		return
	end

	local obj = SpawnEntityFromArchetype(archetype, pos[1], pos[2], pos[3], 0, 0, 0)
	if obj == GetInvalidEntityId() then
		ScriptHook.ShowNotification(15, "Failed to spawn entity", "Entity archetype " .. archetype .. " is invalid or not spawnable")
		return
	end
	
	if Script():IsNotificationEnabled("objectSpawns") then
		entitiesSpawnCounter = entitiesSpawnCounter + 1
		if not timer.Get("entitiesSpawnTimer") then
			timer.Create("entitiesSpawnTimer", 3, 1, function()
				if entitiesSpawnCounter > 1 then
					ScriptHook.ShowNotification(1, tostring(entitiesSpawnCounter) .. " entities spawned", "")
				else
					ScriptHook.ShowNotification(1, "Entity spawned", "")
				end
				entitiesSpawnCounter = 0
			end)
		end
	end

	return obj
end

local AnimalLibrary_Categories = {
	{ "Birds", ObjectLibrary["simplebird"] },
	{ "Rat", ObjectLibrary["simplerat"] },
	{ "Sea Lions", ObjectLibrary["simplesealion"] },
}

local ObjectLibrary_Categories = {
	{ "animatedobject", ObjectLibrary["animatedobject"] },
	{ "animatedphysicsobject", ObjectLibrary["animatedphysicsobject"] },
	{ "bollards", ObjectLibrary["bollards"] },
	{ "breakableentitywithlights", ObjectLibrary["breakableentitywithlights"] },
	{ "breakableinfrareddetector", ObjectLibrary["breakableinfrareddetector"] },
	{ "breakablemusicpoint", ObjectLibrary["breakablemusicpoint"] },
	{ "breakableobject-commercial", ObjectLibrary["breakableobject-commercial"] },
	{ "breakableobject-construction", ObjectLibrary["breakableobject-construction"] },
	{ "breakableobject-signs", ObjectLibrary["breakableobject-signs"] },
	{ "breakableobject-fences", ObjectLibrary["breakableobject-fences"] },
	{ "breakableobject-containers", ObjectLibrary["breakableobject-containers"] },
	{ "breakableobject-flags", ObjectLibrary["breakableobject-flags"] },
	{ "breakableobject-furniture", ObjectLibrary["breakableobject-furniture"] },
	{ "breakableobject-generic", ObjectLibrary["breakableobject-generic"] },
	{ "breakableobject-misc", ObjectLibrary["breakableobject-misc"] },
	{ "capsulelight", ObjectLibrary["capsulelight"] },
	{ "collidabledecal", ObjectLibrary["collidabledecal"] },
	{ "debrisphysicsobject", ObjectLibrary["debrisphysicsobject"] },
	{ "hologram", ObjectLibrary["hologram"] },
	{ "discoverableobjectinteractive", ObjectLibrary["discoverableobjectinteractive"] },
	{ "dronedockentityv2", ObjectLibrary["dronedockentityv2"] },
	{ "dronepickabledelivery", ObjectLibrary["dronepickabledelivery"] },
	{ "emptyentity", ObjectLibrary["emptyentity"] },
	{ "exteriordoor", ObjectLibrary["exteriordoor"] },
	{ "frustumlight", ObjectLibrary["frustumlight"] },
	{ "hackablebreakableentity", ObjectLibrary["hackablebreakableentity"] },
	{ "hackableentity", ObjectLibrary["hackableentity"] },
	{ "hackablekineticentity", ObjectLibrary["hackablekineticentity"] },
	{ "hackablelightdoor", ObjectLibrary["hackablelightdoor"] },
	{ "hackablelightgate", ObjectLibrary["hackablelightgate"] },
	{ "hackablestaticobject", ObjectLibrary["hackablestaticobject"] },
	{ "interactivefloortile", ObjectLibrary["interactivefloortile"] },
	{ "kinematicmovableentity", ObjectLibrary["kinematicmovableentity"] },
	{ "materialswapentity", ObjectLibrary["materialswapentity"] },
	{ "movablebreakableentity", ObjectLibrary["movablebreakableentity"] },
	{ "movableentity", ObjectLibrary["movableentity"] },
	{ "movablehackableentity", ObjectLibrary["movablehackableentity"] },
	{ "newparticleseffect", ObjectLibrary["newparticleseffect"] },
	{ "nophyshackablegateentity", ObjectLibrary["nophyshackablegateentity"] },
	{ "nophyshackableremotecontrolledentity", ObjectLibrary["nophyshackableremotecontrolledentity"] },
	{ "omnilight", ObjectLibrary["omnilight"] },
	{ "physicsobject", ObjectLibrary["physicsobject"] },
	{ "pickupobject", ObjectLibrary["pickupobject"] },
	{ "pickupweaponobject", ObjectLibrary["pickupweaponobject"] },
	{ "projectilewithtimer", ObjectLibrary["projectilewithtimer"] },
	{ "proximitytrigger", ObjectLibrary["proximitytrigger"] },
	{ "raycastobject", ObjectLibrary["raycastobject"] },
	{ "redbarrel", ObjectLibrary["redbarrel"] },
	{ "ringofsteeldynamiclight", ObjectLibrary["ringofsteeldynamiclight"] },
	{ "ringofsteeldynamiclightwitheffect", ObjectLibrary["ringofsteeldynamiclightwitheffect"] },
	{ "ringofsteelhologram", ObjectLibrary["ringofsteelhologram"] },
	{ "roadspikes", ObjectLibrary["roadspikes"] },
	{ "rocketprojectile", ObjectLibrary["rocketprojectile"] },
	{ "securitycamera", ObjectLibrary["securitycamera"] },
	{ "shop", ObjectLibrary["shop"] },
	{ "simpledoor", ObjectLibrary["simpledoor"] },
	{ "spotlight", ObjectLibrary["spotlight"] },
	{ "staticobject", ObjectLibrary["staticobject"] },
	{ "staticobjectwithcollisionmask", ObjectLibrary["staticobjectwithcollisionmask"] },
	{ "staticobjectwithsound", ObjectLibrary["staticobjectwithsound"] },
	{ "turret", ObjectLibrary["turret"] },
	{ "unbreakabledynamicmediaobject", ObjectLibrary["unbreakabledynamicmediaobject"] },
	{ "unbreakableringofsteelscreen", ObjectLibrary["unbreakableringofsteelscreen"] },
	{ "visualobject", ObjectLibrary["visualobject"] }
}

local function OpenObjectCategoryMenu(title, tbl)
	local menu = UI.SimpleMenu()
	menu:SetTitle(title)
	menu:AddSearch("Search", "Start typing to filter")

	for k,v in pairsByKeys(tbl) do
		menu:AddButton(k, v, SpawnObject)
	end

	return menu
end

local function SpawnObjectMenu(title, category)
	local menu = UI.SimpleMenu()
	menu:SetTitle("Spawn " .. title)
	menu:AddSearch("Search", "Start typing to filter")

	for _,v in pairsByKeys(category) do
		local name, tbl = unpack(v)

		menu:AddButton(name, Script():CacheMenu(function()
			return OpenObjectCategoryMenu(name, tbl)
		end))
	end

	return menu
end

local function SpawnObjectCategoryMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Spawn Entity by Category")

	local enableNotificationsSettingIdx = menu:AddCheckbox("Enable Notifications", "Toggle message window for object spawns", function()
		Script():SetNotificationEnabled("objectSpawns", not Script():IsNotificationEnabled("objectSpawns"))
	end)

	menu:SetChecked(enableNotificationsSettingIdx, Script():IsNotificationEnabled("objectSpawns"))

	menu:AddButton("Spawn world objects", "Spawn static and dynamic world objects", Script():CacheMenu(function()
		return SpawnObjectMenu("World Objects", ObjectLibrary_Categories)
	end))
	menu:AddButton("Spawn animals", "Spawn animals", Script():CacheMenu(function()
		return SpawnObjectMenu("Animals", AnimalLibrary_Categories)
	end))
	
	return menu
end

local function LondonEyeMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("London Eye")

	local speedIdx = menu:AddList("Rotation Speed", function(_,_,_,_, idx, val)
		ScriptHook.SetLondonEyeRotationSpeed(tonumber(val), false)
	end)

	for _,v in pairs({ 0, 1, 2, 3, 5, 10, 25, 50, 100, 250, 500, 1000, 5000 }) do
		menu:AddListEntry(speedIdx, tostring(v))
	end

	menu:AddButton("Reset", function()
		menu:SelectListEntryByValue(speedIdx, tostring(0))
	end)

	menu:OnUpdate(function()
		menu:SelectListEntryByValue(speedIdx, tostring(ScriptHook.GetLondonEyeRotationSpeed()))
	end)

	return menu
end

local function PlayBroadCast(menu, text, name)
	ScriptHook.PlayBroadcast(BroadcastsTypes["Default"], Broadcasts[name])
	ScriptHook.PlayBroadcast(BroadcastsTypes["NoSignal"], Broadcasts[name])
	ScriptHook.PlayBroadcast(BroadcastsTypes["Narrative"], Broadcasts[name])
	ScriptHook.PlayBroadcast(BroadcastsTypes["Custom"], Broadcasts[name])
	ScriptHook.ShowNotification(1, "Playing broadcast", name)
end

local function MediaBroadcastMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Media Broadcast")

	menu:AddButton("Reset the default", "Resets the world broadcast to default", function()
		ScriptHook.ResetBroadcastToDefault()
		ScriptHook.ShowNotification(1, "Broadcast reset", "Reset the world broadcast to default")
	end)
	
	for k,v in pairsByKeys(Broadcasts) do
		menu:AddButton(k, k, PlayBroadCast)
	end

	return menu
end

-- Environment
local function EnvironmentMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Environment")
	
	-- Items
	menu:AddButton("Time", TimeMenu)
	menu:AddButton("Time Scale", TimeScaleMenu)
	menu:AddButton("Time Shift (slowmow/flash)", TimeShiftMenu)
	menu:AddButton("Weather", Script():CacheMenu(WeatherMenu))
	menu:AddButton("Media Broadcast", Script():CacheMenu(MediaBroadcastMenu))
	menu:AddButton("World Spawner", Script():CacheMenu(SpawnerMenu))
	menu:AddButton("World Loading Units", Script():CacheMenu(WorldLoadingUnitsMenu))
	menu:AddButton("Spawn Entity By Category", Script():CacheMenu(SpawnObjectCategoryMenu))
	menu:AddButton("London Eye", Script():CacheMenu(LondonEyeMenu))

	return menu
end

table.insert(SimpleTrainerMenuItems, { "Environment", "Control time, weather", Script():CacheMenu(EnvironmentMenu) })