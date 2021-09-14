-- Store Notification Settings
local script = Script()
local NotificationSettings = {
	objectSpawns = true,
	wluSpawns = true
}

function script:IsNotificationEnabled(type)
	return NotificationSettings[type] == true
end

function script:SetNotificationEnabled(type, enabled)
	NotificationSettings[type] = enabled
	self:SetConfigOption("settings.notification." .. type, enabled)
end

function script:ApplyNotificationSettings()
	for k,v in pairs(NotificationSettings) do
		local val = self:GetConfigOption("settings.notification." .. k)
		if val ~= nil then
			NotificationSettings[k] = val
			print(k, val)
		end
	end
end