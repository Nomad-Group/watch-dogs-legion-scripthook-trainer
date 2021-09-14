-- weather <id>
local function command_setweather(id)
	local weather = WeatherIDs[id]
	if weather then
		PushEnvironmentWeatherOverride(weather, 1)
		print("Successfully changed weather to "..weather.." (#"..id..")")
	else
		print("Failed to find the given weather")
	end
end

-- Register command
local cmd_teleport = ScriptHook.RegisterCommand("weather", command_setweather)
cmd_teleport:AddArgument("id", false)
cmd_teleport:SetDescription("Change the world weather (e.g. SanFran.Clear.Clear_1)")