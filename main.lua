-- Commands
include("commands/weather.lua")

-- Settings
include("settings/NoclipFreeCam.lua")
include("settings/Notifications.lua")

-- Menu
include("menu/menu.lua")

-- Events
include("events/OnWorldReady.lua")

-- Player
include("player/StateWatcher.lua")

local script = Script()
script.Entities = {}

function script:OnWorldReady()
	print("OnWorldReady")
	self:OnWorldReadyCb()
end

function script:OnLoad()
	print("Script trainer main loaded!")
	
	self:ApplyCameraSpeeds()
	self:ApplyNotificationSettings()
end

function script:OnUpdate(time, dt)
	self.StateWatcher:OnUpdate(time)
	
	self:UpdateCinematic(time, dt)
	self:ProcessVehicleMenuGameUpdate(time, dt)
end

function script:OnRender()
end

function script:InitCallbacks()
    self.StateWatcher:Init()
end

function script:OnUnload()
    self.StateWatcher:Shutdown()

    for _,v in pairs(self.Entities) do
        RemoveEntity(v)
    end
end