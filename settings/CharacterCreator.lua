-- Binds
ScriptHook.RegisterKeyHandler("character-creator", function()
	ScriptHook.SetLocalPlayerCharacterCreatorEnabled(not ScriptHook.IsLocalPlayerCharacterCreatorEnabled())
end)