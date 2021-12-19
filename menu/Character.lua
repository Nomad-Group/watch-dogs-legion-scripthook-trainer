-- Character Creator
local function CharacterMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Character")

	menu:AddButton("Start Character Creator", function(_,_,_,_, idx, speed)
		ScriptHook.SetLocalPlayerCharacterCreatorEnabled(true)
		menu:Deactivate(true)
	end)

	menu:AddButton("Import Character Creation", function(_,_,_,_, idx, speed)
		UI.SimpleTextInput("Import Character Creation", function(success, text)
			if success then
				ScriptHook.SetLocalPlayerCharacterCreation(text)
			end
		end, "Please paste the shared code in here", 255)
	end)

	local savedChars = ScriptHook.GetSavedCharacterCreationsList()
	local snippets = {}
	local ctr = 1

	for name,snippet in pairs(savedChars) do
		table.insert(snippets, snippet)
		ctr = ctr + 1

		menu:AddButton(name, snippet, function(_,_,_, idx)
			ScriptHook.SetLocalPlayerCharacterCreation(snippets[idx - 2], true)
		end)
	end

	return menu
end

table.insert(SimpleTrainerMenuItems, { "Character", "Character Creator, Load Characters", CharacterMenu })