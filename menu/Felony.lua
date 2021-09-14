local selectedFraction = "Police"
local targetEntity = nil

-- 
local function GetFelonyTargetEntity()
    local entity = nil
    if targetEntity ~= nil then
        entity = targetEntity
    else
        entity = GetLocalPlayerEntityId()
    end

    return entity
end

local function GetFelonyTypeID(felonyTypeName)
	return FelonyTypes[felonyTypeName]
end

local function StartFelonySearch(fraction)
	local felonyType = GetFelonyTypeID(fraction)

	ScriptHook.StartFelonySearch(GetFelonyTargetEntity(), felonyType)
end

local function StartFelonyChase(level, fraction, behaviour)
	local target = GetFelonyTargetEntity()
	local felonyType = GetFelonyTypeID(fraction)
	local felonyLevel = level
	local startAction = 2

	if behaviour == "search" then
		startAction = 4
	end
	
	FelonyStartChase(target, felonyType, felonyLevel, startAction)
end

-- Player Wanted
local function FractionWantedMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Select a fraction")

	for k,v in pairsByKeys(FelonyTypes) do
		menu:AddButton(k, function(menu, text, hint, index) 
			selectedFraction = text
			ScriptHook.ShowNotification(1, "Changed felony system", "To fraction " .. selectedFraction)
		end)
	end

	return menu
end

local function IsPoliceFractionSelected()
	return GetFelonyTypeID(selectedFraction) == 0
end

local function FelonyMenu()
	local menu = UI.SimpleMenu()

    local fraction = selectedFraction
	menu:SetTitle("Felony - " .. selectedFraction)

    local menuTargetEntity = nil

    --local targetBtn = menu:AddButton("Target Entity: Local Player", "", function()
    --    local selectEntity = GetReticleHitEntity()
    --    if selectEntity ~=GetInvalidEntityId() then
    --        targetEntity = selectEntity
    --        ScriptHook.ShowNotification(1, "Felony Target updated", "You targeted the felony to the selected entity")
    --    else
    --        targetEntity = nil
    --        ScriptHook.ShowNotification(14, "Felony Target updated failed", "Reset back to local player")
    --    end
    --end)

	-- menu:AddButton("Change fraction", "Select a fraction that chases you", Script():CacheMenu(FractionWantedMenu))

	local felonyEnableBtn = menu:AddCheckbox("Felony System Enabled", "", function()
		ScriptHook.SetFelonySystemEnabled(not ScriptHook.IsFelonySystemEnabled())
		ScriptHook.ShowNotification(1, "Felony system updated", "")
	end)
	
	--local searchButton = menu:AddButton("Start search", function()
	--	StartFelonySearch(selectedFraction)
	--	ScriptHook.ShowNotification(1, "Search started", selectedFraction .. " is looking for you")
	--end)
	
	menu:AddButton("Start chase", function()
		StartFelonyChase(2, selectedFraction, "chase")
		ScriptHook.ShowNotification(1, "Felony started", selectedFraction .. " is chasing you")
	end)

	--menu:AddButton("Start escape", function()
	--	StartFelonyChase(1, selectedFraction, "search")
	--	ScriptHook.ShowNotification(1, "Escape started", selectedFraction .. " is searching for you")
	--end)
	
	menu:AddButton("Clear", function()
		FelonyEndChaseOrSearch(GetFelonyTargetEntity(), GetFelonyTypeID(selectedFraction), 1)
		ScriptHook.ClearFelonyHeatLevel(GetFelonyTypeID(selectedFraction))
		ScriptHook.ShowNotification(1, "Felony clear", selectedFraction .. " have lost interest in you")

		TriggerInitialSpawn()
	end)

	menu:OnUpdate(function()
        if fraction ~= selectedFraction then
            fraction = selectedFraction
            menu:SetTitle("Felony - " .. selectedFraction)
        end

        --if targetEntity ~= menuTargetEntity then
        --    menuTargetEntity = targetEntity

        --    if menuTargetEntity == nil then
        --        menu:SetEntryText(targetBtn, "Target Entity: Local Player")
        --    else
        --        menu:SetEntryText(targetBtn, "Target Entity: Selected Entity")
        --    end
        --end

		-- menu:SetEntryEnabled(searchButton, IsPoliceFractionSelected())
		menu:SetChecked(felonyEnableBtn, ScriptHook.IsFelonySystemEnabled())
	end)
	
	return menu
end

table.insert(SimpleTrainerMenuItems, { "Felony", "", Script():CacheMenu(FelonyMenu) })