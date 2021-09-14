-- Store Noclip / FreeCam Speeds
local script = Script()
local SpeedSettings = {
	freecam = {
		normal = 25,
		shift = 100,

		func = ScriptHook.SetFreeCameraSpeeds,
		ready = false
	},
	
	noclip = {
		normal = 25,
		shift = 100,

		func = ScriptHook.SetNoclipSpeeds,
		ready = false
	}
}

function script:ReadCameraSpeeds(name)
	local data = SpeedSettings[name]

	local normal = self:GetConfigOption(name .. ".speed.normal")
	if normal then
		data.normal = tonumber(normal)
	end

	local shift = self:GetConfigOption(name .. ".speed.shift")
	if shift then
		data.shift = tonumber(shift)
	end

	return data
end

function script:ApplyCameraSpeed(name, type, speed)
	local data = SpeedSettings[name]
	if not data.ready then
		return
	end

	if type and speed then
		data[type] = tonumber(speed)
	end
	data.func(data.normal, data.shift)

	if type and speed then
		self:SetConfigOption(name .. ".speed." .. type, tonumber(speed))
	end
end

function script:ApplyCameraSpeeds()
	self:ReadCameraSpeeds("freecam")
	self:ApplyCameraSpeed("freecam")
	self:ReadCameraSpeeds("noclip")
	self:ApplyCameraSpeed("noclip")
end

-- Binds
ScriptHook.RegisterKeyHandler("freecam", function()
	ScriptHook.SetLocalPlayerFreeCamera(not ScriptHook.HasLocalPlayerFreeCamera())
end)

ScriptHook.RegisterKeyHandler("noclip", function()
	ScriptHook.SetLocalPlayerNoclip(not ScriptHook.HasLocalPlayerNoclip())
end)