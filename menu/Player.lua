-- God
local function PlayerHasGod()
	return Script().StateWatcher:GetState("god") == true
end
local function PlayerSetGod(on)
	local playerid = GetLocalPlayerEntityId()
	Script().StateWatcher:SetState("god", on)

	if on then
		ActivateInvincibility(playerid)
		SetPawnImmuneToDeath(playerid, 1)
		ScriptHook.ShowNotification(1, "Player God Mode", "ON")
	else
		RemoveInvincibility(playerid)
		SetPawnImmuneToDeath(playerid, 0)
		ScriptHook.ShowNotification(1, "Player God Mode", "OFF")
	end
end

-- Unlimited Ammo
local function PlayerHasUnlimitedAmmo()
	return Script().StateWatcher:GetState("unlimitedAmmo") == true
end
local function PlayerSetUnlimitedAmmo(on)
	Script().StateWatcher:SetState("unlimitedAmmo", on)
	Script().StateWatcher:UnlimitedAmmo()
end

-- Noclip
local function ToggleNoclip()
	ScriptHook.SetLocalPlayerNoclip(not ScriptHook.HasLocalPlayerNoclip())
end

-- Invisible
local function PlayerIsInvisible()
	return Script().StateWatcher:GetState("invisible") == true
end

-- Player
local function PlayerMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Player")

	-- Items
	local godIdx = menu:AddCheckbox("God Mode", "Toggle invincibility", function()
		PlayerSetGod(not PlayerHasGod())
	end)

	local invisibleIdx = menu:AddCheckbox("Invisible Mode", "Toggle visibility", function()
		Script().StateWatcher:SetState("invisible", not PlayerIsInvisible())
		ScriptHook.SetEntityIsVisible(GetLocalPlayerEntityId(), not PlayerIsInvisible(), 0)
	end)

	local unlAmmoIdx = menu:AddCheckbox("Unlimited Ammo", "No reload, always full clips", function()
		PlayerSetUnlimitedAmmo(not PlayerHasUnlimitedAmmo())
	end)

	-- Noclip
	local noclipIdx = menu:AddCheckbox("Noclip / Fly", "Enable/Disable flying", ToggleNoclip)

	-- Noclip Speed
	local speedIdx = menu:AddList("Noclip Speed", function(_,_,_,_, idx, speed)
		Script():ApplyCameraSpeed("noclip", "normal", speed)
	end)

	for _,v in pairs({ 0.5, 1, 2, 3, 5, 10, 15, 20, 25, 50, 75, 100 }) do
		menu:AddListEntry(speedIdx, tostring(v))
	end

	-- Noclip Shift Speed
	local shiftSpeedIdx = menu:AddList("Noclip Shift Speed", function(_,_,_,_, idx, speed)
		Script():ApplyCameraSpeed("noclip", "shift", speed)
	end)

	for _,v in pairs({ 5, 10, 25, 50, 75, 100, 150, 200, 250, 350, 450 }) do
		menu:AddListEntry(shiftSpeedIdx, tostring(v))
	end

	-- Persistent
	local speedData = Script():ReadCameraSpeeds("noclip")
	menu:SelectListEntryByValue(speedIdx, tostring(speedData.normal))
	menu:SelectListEntryByValue(shiftSpeedIdx, tostring(speedData.shift))
	speedData.ready = true

	-- Update
	menu:OnUpdate(function()
		menu:SetChecked(godIdx, PlayerHasGod())
		menu:SetChecked(invisibleIdx, PlayerIsInvisible())
		menu:SetChecked(unlAmmoIdx, PlayerHasUnlimitedAmmo())

		menu:SetChecked(noclipIdx, ScriptHook.HasLocalPlayerNoclip())
		menu:SetEntryEnabled(noclipIdx, not ScriptHook.HasLocalPlayerFreeCamera())
	end)

	return menu
end

table.insert(SimpleTrainerMenuItems, { "Player", "Godmode, noclip, unlimited ammo", Script():CacheMenu(PlayerMenu) })