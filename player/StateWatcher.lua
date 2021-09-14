-- StateWatcher is a watchdog for the local player's entity. Its used to store variables ("states") of the player
-- V2: We no longer reset the states when a player dies - otherwise features may be disabled after cutscenes, etc. 
local StateWatcher = {
	EventIDs = {},
	State = {},
	TimeNextUpdate = 0
}

Script().StateWatcher = StateWatcher

-- Init/Shutdown
function StateWatcher:Init()
end

function StateWatcher:Shutdown()
end

-- Timer
function StateWatcher:OnUpdate(time)
	local curPlyId = GetLocalPlayerEntityId()
	self.PlayerId = curPlyId

	-- States
	if time >= self.TimeNextUpdate then
		-- Apply every few second, not every frame

		if self:GetState("god") then
			self:GodMode()
		end

		self.TimeNextUpdate = time + 3
	end

	if self:GetState("unlimitedAmmo") then
		self:UnlimitedAmmo()
	end
end

-- State
function StateWatcher:SetState(key, val)
	self.State[key] = val
end
function StateWatcher:GetState(key)
	return self.State[key]
end

-- Unlimited Ammo
function StateWatcher:UnlimitedAmmo()
	for i = 0, 5, 1 do
		ModifyBulletsInClip(GetLocalPlayerEntityId(), i, 999, 9999)
	end
end

-- God
function StateWatcher:GodMode()
	local playerid = GetLocalPlayerEntityId()

	ActivateInvincibility(playerid)
	SetPawnImmuneToDeath(playerid, 1)
end