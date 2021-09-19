local script = Script()
local hostilies = {
["Kill All Humans"] = 0,
["Kill All Enemies"] = 1,
}

local function KillHumans(menu, text, name)
	local player = GetLocalPlayerEntityId()
	local entities = CAIAgentManager_GetInstance():GetAIAgentsOfGroupFromLUA_v2("Human", 0, "", 0, hostilies[text])
	
	for k,v in pairs(entities) do
		SendDamageToEntity(v, player, 16, 100, 512)
	end
end

local function DestroyDrones()
	local drones = CAIAgentManager_GetInstance():GetAIDronesFromLUA("All", "", 0)
	
	for k,v in pairs(drones) do
		ExplodeVehicle(v)
	end
end

local function HackingMenu()
	local menu = UI.SimpleMenu()

	menu:SetTitle("Hacking")
	menu:AddButton("Kill All Humans", KillHumans)
	menu:AddButton("Kill All Enemies", KillHumans)
	menu:AddButton("Explode All Drones", DestroyDrones)
	
	
	return menu
end

table.insert(SimpleTrainerMenuItems, { "Hacking", "", Script():CacheMenu(HackingMenu) })