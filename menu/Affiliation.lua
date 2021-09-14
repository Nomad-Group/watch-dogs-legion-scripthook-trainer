local script = Script()

local targetEntity = nil

local function SetAffiliationRelationshipMenu(name, id)
	local menu = UI.SimpleMenu()
	menu:SetTitle("Set realtionship to " .. name)

	for k,v in pairsByKeys(AgentRelationship) do
		menu:AddButton(k, function(menu, text, hint, index) 
            local affid = AgentRelationship[k]

            local entity = nil
            if targetEntity ~= nil then
                entity = targetEntity
            else
                entity = GetLocalPlayerEntityId()
            end

			SetSquadRelationship(id, affid, entity)
			ScriptHook.ShowNotification(1, "Relationship updated", "Your relationship to " .. name .. " is now " .. k)
		end)
	end

	return menu
end

local function AffiliationMenu()
	local menu = UI.SimpleMenu()

	menu:SetTitle("Affiliation")

    local menuTargetEntity = nil

    --local targetBtn = menu:AddButton("Target Entity: Local Player", "", function()
    --    local selectEntity = GetReticleHitEntity()
    --    if selectEntity ~=GetInvalidEntityId() then
    --        targetEntity = selectEntity
    --        ScriptHook.ShowNotification(1, "Affiliation Target updated", "You are now targeting an entity")
    --    else
    --        targetEntity = nil
    --        ScriptHook.ShowNotification(14, "Affiliation Target updated failed", "Now reset back to local player")
    --    end
    --end)

	for k,v in pairsByKeys(AgentAffiliation) do
		menu:AddButton(k, Script():CacheMenu(function()
			return SetAffiliationRelationshipMenu(k, AgentAffiliation[k])
		end))
	end

    --menu:OnUpdate(function()
    --    if targetEntity ~= menuTargetEntity then
    --        menuTargetEntity = targetEntity

    --        if menuTargetEntity == nil then
    --            menu:SetEntryText(targetBtn, "Target Entity: Local Player")
    --        else
    --            menu:SetEntryText(targetBtn, "Target Entity: Selected Entity")
    --        end
    --    end
    --end)
	
	return menu
end

table.insert(SimpleTrainerMenuItems, { "Affiliation", "", Script():CacheMenu(AffiliationMenu) })